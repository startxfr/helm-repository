# Install via ArgoCD

To leverage the GitOps features of ArgoCD to deploy a chart, follow the procedure below.

## 0. Requirements

- A running OpenShift cluster with appropriate permissions
- OpenShift client installed: `sudo yum install openshift-client`
- Connected to your cluster: `oc login <cluster_api_url>`

## 1. Deploy ArgoCD project

If GitOps is not enabled in your cluster, deploy it with:

```bash
echo "begin deploying argocd project"
oc process -f https://gitlab.com/sxcm/cli/-/raw/main/src/resources/argocd-project.yml | oc apply -f -
echo "switching to openshift-gitops namespace"
oc project openshift-gitops
echo "deploying secrets links for gitops deployments"
oc secrets link argocd-application-controller startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link argocd-dex-server startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link argocd-operator startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link argocd-redis-ha startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link argocd-server startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link default startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link deployer startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link openshift-gitops-application-controller startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link openshift-gitops-dex-server startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link openshift-gitops-redis-ha startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link openshift-gitops-server startx-registrycreds-docker --for=pull -n openshift-gitops
echo "pause deploying argocd project"
sleep 60
echo "end deploying argocd project"
```

## 2. Deploy ArgoCD control-plane

If GitOps is not enabled in your cluster, run the following after the previous step:

```bash
echo "begin deploying argocd control-plane"
oc process -f https://gitlab.com/sxcm/cli/-/raw/main/src/resources/argocd-deploy-small.yml | oc apply -f -
echo "pause deploying argocd control-plane"
sleep 90
echo "end deploying argocd control-plane"
```

## 3. Check ArgoCD deployments

Wait for all pods in the gitops namespace to be ready:

```bash
oc get pod -n openshift-gitops -w
```

## 4. Deploy cluster-services

We use the Crunchy PostgreSQL operator (`cluster-crunchy`) as a complete example of the standard pattern.

Every `cluster-*` chart is split into three Applications with explicit **sync-waves** to enforce a safe creation and deletion order:

| Application | Wave | Role |
|---|---|---|
| `cluster-crunchy-project` | `1` | Creates the namespace — created first, deleted last |
| `cluster-crunchy-operator` | `2` | Installs the operator — deleted after the database instance is gone |
| `cluster-crunchy-app` | `3` | Deploys the PostgresCluster CR — deleted first so the operator is still alive to process finalizers |

> **Deletion order matters.** Always delete `-app` first and wait for completion before deleting `-operator`, then `-project`. Deleting the operator before its CRs orphans the CR finalizers and leaves the namespace stuck in `Terminating` indefinitely.

### 4.0. Create the AppProject

An AppProject scopes the Applications to specific source repos and destination namespaces.

```bash
cat <<EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-crunchy
  namespace: openshift-gitops
spec:
  description: Configure Crunchy PostgreSQL operator
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-gitops
      server: https://kubernetes.default.svc
    - namespace: openshift-crunchy-pgo
      server: https://kubernetes.default.svc
    - namespace: startx-crunchy
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
EOF
```

### 4.1. Create the namespace (project)

Wave `1` — no `resources-finalizer`: the namespace cleans up naturally once its contents are removed by the other two Applications.

```bash
cat <<EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-crunchy-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-crunchy
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-crunchy
    targetRevision: 21.3.27
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: true
        operator:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

### 4.2. Deploy the operator

Wave `2` — with `resources-finalizer` so ArgoCD cascade-deletes the operator subscription and CSV on removal.

```bash
cat <<EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-crunchy-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "2"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-crunchy
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-crunchy
    targetRevision: 21.3.27
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        operator:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

### 4.3. Deploy the PostgresCluster instance

Wave `3` — with `resources-finalizer` and `ignoreDifferences` on `metadata.finalizers`. The Crunchy operator adds its own finalizers to the `PostgresCluster` CR after creation; ignoring that field prevents permanent OutOfSync.

```bash
cat <<EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-crunchy-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "3"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-crunchy
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-crunchy
    targetRevision: 21.3.27
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        crunchy:
          enabled: true
        operator:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  ignoreDifferences:
    - group: postgres-operator.crunchydata.com
      kind: PostgresCluster
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
```

## 5. Verify sync

```bash
oc get applications -n openshift-gitops | grep cluster-crunchy
```

All three Applications should reach `Synced / Healthy`.

## 6. Safe teardown

Delete in reverse wave order and wait between each step:

```bash
# Delete app first (operator is still running — can process PostgresCluster finalizers)
oc delete application cluster-crunchy-app -n openshift-gitops
oc wait --for=delete application/cluster-crunchy-app -n openshift-gitops --timeout=300s

# Then operator
oc delete application cluster-crunchy-operator -n openshift-gitops
oc wait --for=delete application/cluster-crunchy-operator -n openshift-gitops --timeout=120s

# Finally project (namespace empties naturally)
oc delete application cluster-crunchy-project -n openshift-gitops
```

> **If a namespace gets stuck Terminating** (operator deleted before its CR): patch the CR to remove the orphaned finalizer, then patch the Application to remove `resources-finalizer.argocd.argoproj.io`. See the [CLAUDE.md emergency cleanup section](../../CLAUDE.md) for the exact commands.

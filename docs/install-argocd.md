# ArgoCD deployment

To leverage the gitops feature of ArgoCD to deploy your targeted  chart, you should follow the following procedure.

## 0. Requirements

- Having an running openshift cluster with appropriate permissions
- Install openshift client with `sudo yum install openshift-client`
- Been connected to your cluster with `oc login <mycluster_api_url>`

## 0.1. Deploy ArgoCD project

If gitops is not enabled in your cluster, you could perform it with :

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

## 0.2. Deploy ArgoCD control-plane

If gitops is not enabled in your cluster, you must perform the following procedure ater the previous deployment (project) :

```bash
echo "begin deploying argocd control-plane"
oc process -f https://gitlab.com/sxcm/cli/-/raw/main/src/resources/argocd-deploy-small.yml | oc apply -f -
echo "pause deploying argocd control-plane"
sleep 90
echo "end deploying argocd control-plane"
```

## 0.3. Check ArgoCD deployments

Wait for all pod in your gitops namespace to be ready :

```bash
oc get pod -n openshift-gitops -w
```

## 1. Deploy cluster-services

We will use the crunchy-database operator as an example for a cluster-service deployment.

## 1.1. Create cluster-service project

First we need to create a project for our postgresql instance.

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-project
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "demo-crunchy"
    server: 'https://kubernetes.default.svc'
  project: cluster-admin
  source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "devel"
    helm:
      valueFiles:
      - values-demo.yaml
      parameters:
      - name: project.enabled
        value: "true"
  syncPolicy:
    automated: 
      prune: false
      selfHeal: false
    syncOptions:
      - ApplyOutOfSyncOnly=true
      - CreateNamespace=false
      - Validate=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 5m
EOF
```

## 1.2. Deploy the operator

Then we deploy the operator. Differences are the name `crunchy-operator` and the `operator.enabled` parameter.

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-operator
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "demo-crunchy"
    server: 'https://kubernetes.default.svc'
  project: cluster-admin
  source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "devel"
    helm:
      valueFiles:
      - values-demo.yaml
      parameters:
      - name: operator.enabled
        value: "true"
  syncPolicy:
    automated: 
      prune: false
      selfHeal: false
    syncOptions:
      - ApplyOutOfSyncOnly=true
      - CreateNamespace=false
      - Validate=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 5m
EOF
```

## 1.3. Create a cluster-service instance

Finally we create a crunchy databas instance. Differences are the name `crunchy-instance`, the `cluster.enabled` and `loader.enabled` parameters.

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-instance
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "demo-crunchy"
    server: 'https://kubernetes.default.svc'
  project: cluster-admin
  source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "devel"
    helm:
      valueFiles:
      - values-demo.yaml
      parameters:
      - name: cluster.enabled
        value: "true"
      - name: loader.enabled
        value: "true"
  syncPolicy:
    automated: 
      prune: false
      selfHeal: false
    syncOptions:
      - ApplyOutOfSyncOnly=true
      - CreateNamespace=false
      - Validate=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 5m
EOF
```


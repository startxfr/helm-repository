# ![unifai](https://helm-repository.readthedocs.io/en/latest/img/unifai.svg "UnifAI") UnifAI Helm chart

Deploy [UnifAI](https://github.com/redhat-community-ai-tools/UnifAI), a multi-agent AI platform with a built-in
RAG pipeline, on OpenShift or Kubernetes, with Helm or ArgoCD.

This chart installs two things :

- the **UnifAI operator** (cluster-wide), with its custom resource definitions ;
- one **`UnifaiStack`** resource, from which the operator deploys the whole platform in the release namespace :
  web interface, backend, multi-agent engine, RAG services, identity service, and their datastores (MongoDB,
  Qdrant, RabbitMQ, Redis, Temporal).

It deploys UnifAI release **v0.1.77** ; every UnifAI image is pinned by digest.

## Requirements

|                    | OpenShift (validated)                              | Kubernetes (experimental)                                    |
| ------------------ | -------------------------------------------------- | ------------------------------------------------------------ |
| Version            | Kubernetes 1.30 or later (OpenShift 4.17 or later) | Kubernetes 1.30 or later                                     |
| Architecture       | linux/amd64 nodes                                  | linux/amd64 nodes                                            |
| Storage            | a ReadWriteOnce class and a ReadWriteMany class    | a ReadWriteOnce class and a ReadWriteMany class              |
| Identity           | a Keycloak deployed by the operator, or your own   | your own Keycloak realm (see [Identity](#identity))          |
| Publication        | Routes, created by the operator                    | Ingresses, created by this chart, and a TLS Secret           |
| Rights             | cluster administrator (the operator is cluster-wide) | cluster administrator                                      |

UnifAI has no mode without single sign-on : a Keycloak realm is always required.

Install the operator **once per cluster**. To deploy UnifAI in several namespaces, install this chart again
with `operator.enabled=false`.

## Quick start on OpenShift

```bash
helm repo add unifai https://helm-repository.readthedocs.io/en/latest/repos/stable/
helm repo update

helm install unifai unifai/unifai \
  --namespace unifai --create-namespace \
  --set stack.spec.storage.className=<ReadWriteOnce class> \
  --set stack.spec.storage.sharedClassName=<ReadWriteMany class>
```

Leave the two storage settings out to use the default class of the cluster ; it must then support ReadWriteMany.

The operator deploys the platform in the background. Follow it until the phase is `Ready` :

```bash
oc -n unifai get unifaistack unifai -w
```

Then get the address of the web interface and the password of the `admin` user :

```bash
oc -n unifai get unifaistack unifai -o jsonpath='{.status.endpoints.ui}{"\n"}'
oc -n unifai get secret unifai-generated -o jsonpath='{.data.keycloak-admin-password}' | base64 -d
```

With these defaults the operator also deploys Keycloak (Red Hat build of Keycloak, installed through the
OpenShift operator catalog) and creates the `unifai` realm and the `admin` user.

## Quick start on Kubernetes (experimental)

The operator is developed and released for OpenShift. On plain Kubernetes it has only been run on throwaway
[kind](https://kind.sigs.k8s.io) clusters by its own test suite, without anything reaching it from outside.
This path works around what Kubernetes lacks ; treat it as a starting point and test it on your cluster.

1. Have a Keycloak realm ready, with a confidential client whose redirect URIs allow
   `https://unifai-ui-<namespace>.<domain>/*` and `https://unifai-identity-<namespace>.<domain>/*`.
2. Create the namespace, the client secret and a TLS Secret valid for both hosts :

   ```bash
   kubectl create namespace unifai
   kubectl -n unifai create secret generic unifai-oidc --from-literal=client-secret=<client secret>
   kubectl -n unifai create secret tls unifai-tls --cert=<certificate> --key=<private key>
   ```

3. Copy [values-kubernetes.yaml](https://github.com/startxfr/helm-repository/blob/master/charts/unifai/values-kubernetes.yaml),
   set your domain, Keycloak address, storage classes and Ingress class, then install :

   ```bash
   helm repo add unifai https://helm-repository.readthedocs.io/en/latest/repos/stable/
   helm install unifai unifai/unifai --namespace unifai -f values-kubernetes.yaml
   ```

What that values file does, and why :

| Setting                                         | Reason                                                                                   |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `exposure.type: ingress`                        | the operator only creates OpenShift Routes ; the chart creates Ingresses instead         |
| `exposure.ingress.installRouteCRD: true`        | the operator fails if the Route API does not exist ; a schema-less definition satisfies it |
| `exposure.domain`                               | the operator cannot discover a domain outside OpenShift                                  |
| `exposure.ingress.tlsSecretName`                | UnifAI only generates `https://` addresses                                               |
| `stack.spec.identity.external`                  | the managed Keycloak needs the OpenShift operator catalog                                |
| `stack.spec.exposure.networkPolicy: false`      | the default network policies only admit the OpenShift router                             |
| `uiAnnotations` (backend protocol HTTPS)        | the web interface serves HTTPS on its internal port                                      |

Known limits on Kubernetes : scheduled backups do not run (their jobs rely on the user identifier OpenShift
assigns), and the example Ingress annotations are for ingress-nginx.

## Values files

Example values files shipped with the chart, to use with `helm install -f <file>` :

- **kubernetes** : Example values for a plain Kubernetes cluster (experimental, see README) (see [values-kubernetes.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/unifai/values-kubernetes.yaml))
- **openshift** : Example values for OpenShift : Routes, a Keycloak managed by the operator, explicit storage classes (see [values-openshift.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/unifai/values-openshift.yaml))
- `examples/argocd/` : 4 example manifest(s) (see the ArgoCD or usage sections)

```bash
helm install unifai startx/unifai -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/unifai/values-kubernetes.yaml
```

## Deploy with ArgoCD

Use two Applications, so that the operator is in place before the stack and removed after it. The manifests are
in [examples/argocd](https://github.com/startxfr/helm-repository/tree/master/charts/unifai/examples/argocd) :

```bash
kubectl apply -k https://github.com/startxfr/helm-repository/charts/unifai/examples/argocd
```

```yaml
# Operator : cluster-wide, installed once
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: unifai-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: unifai
  destination:
    server: https://kubernetes.default.svc
    namespace: unifai-operator
  source:
    repoURL: https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com/stable
    chart: unifai
    targetRevision: 21.3.414
    helm:
      values: |
        stack:
          enabled: false
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
---
# Platform : one per namespace
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: unifai-stack
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: unifai
  destination:
    server: https://kubernetes.default.svc
    namespace: unifai
  source:
    repoURL: https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com/stable
    chart: unifai
    targetRevision: 21.3.414
    helm:
      # The definitions belong to the operator Application
      skipCrds: true
      values: |
        operator:
          enabled: false
        stack:
          spec:
            storage:
              className: gp3-csi
              sharedClassName: nfs
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Delete `unifai-stack` first and wait for it to disappear before deleting `unifai-operator` : the operator is
what removes the platform.

Do not name an Application after a UnifAI component (`unifai-ui`, `unifai-rag`, `unifai-mongodb`...) : the
operator uses those names for its own releases in the namespace.

With `exposure.type=ingress`, set `exposure.ingress.createUiServingCert=false` and provide the `unifai-ui-tls`
Secret yourself (for example with cert-manager) : ArgoCD cannot keep a generated certificate stable.

## Configuration

### Chart settings

| Key                                    | Default                 | Description                                                                 |
| -------------------------------------- | ----------------------- | --------------------------------------------------------------------------- |
| `operator.enabled`                     | `true`                  | install the operator ; `false` when it already runs on the cluster          |
| `operator.image`                       | pinned digest           | operator image                                                              |
| `operator.imagePullPolicy`             | `IfNotPresent`          | pull policy of the operator                                                 |
| `operator.imagePullSecrets`            | `[]`                    | pull secrets of the operator                                                |
| `operator.resources`                   | 50m / 192Mi, limit 1Gi  | resources of the operator                                                   |
| `operator.nodeSelector`, `tolerations` | empty                   | scheduling of the operator                                                  |
| `operator.userRoles`                   | `true`                  | create the `unifai-view`, `unifai-edit` and `unifai-admin` ClusterRoles     |
| `operator.metrics.serviceMonitor`      | `false`                 | create a ServiceMonitor (requires the prometheus-operator definitions)      |
| `stack.enabled`                        | `true`                  | create the `UnifaiStack`                                                    |
| `stack.spec`                           | see below               | content of the `UnifaiStack`, passed as is to the operator                  |
| `exposure.type`                        | `route`                 | `route`, `ingress` or `none`                                                |
| `exposure.domain`                      | empty                   | domain of the published hosts ; required with `ingress`                     |
| `exposure.ingress.className`           | empty                   | Ingress class                                                               |
| `exposure.ingress.annotations`         | `{}`                    | annotations of both Ingresses                                               |
| `exposure.ingress.uiAnnotations`       | `{}`                    | annotations of the web interface Ingress                                    |
| `exposure.ingress.tlsSecretName`       | empty                   | TLS Secret of the Ingresses ; required with `ingress`                       |
| `exposure.ingress.installRouteCRD`     | `false`                 | install a schema-less Route definition ; never on OpenShift                 |
| `exposure.ingress.createUiServingCert` | `true`                  | generate the internal certificate of the web interface (`unifai-ui-tls`)    |
| `project.enabled`                      | `false`                 | create the namespace with the optional `project` sub-chart                  |

The `context` block only sets descriptive labels on the objects this chart creates.

### Platform settings (`stack.spec`)

`stack.spec` is the specification of the `UnifaiStack` resource. The full reference is on the cluster :

```bash
kubectl explain unifaistack.spec --recursive
```

The settings most installs need :

| Key                               | Default            | Description                                                                    |
| --------------------------------- | ------------------ | ------------------------------------------------------------------------------ |
| `profile`                         | `dev`              | `dev` (small requests, no autoscaling) or `prod`                               |
| `version`, `images`               | v0.1.77, digests   | UnifAI images ; change them together when upgrading                            |
| `identity.adminUsers`             | `[admin]`          | Keycloak users granted the administrator role                                  |
| `identity.keycloak`               | `{}`               | Keycloak deployed by the operator (OpenShift only)                             |
| `identity.external`               | not set            | your own Keycloak ; replaces `identity.keycloak`                               |
| `storage.className`               | cluster default    | class of the database volumes                                                  |
| `storage.sharedClassName`         | cluster default    | class of the shared volumes ; must support ReadWriteMany                       |
| `storage.sizes`                   | set by the profile | size per volume                                                                |
| `replicas.multiagent`             | not set            | number of multiagent-be pods, 1 to 10 (operator 0.1.77) ; see Upgrade          |
| `rag.gpu`                         | `false`            | give the RAG workers a GPU                                                     |
| `integrations`                    | not set            | Slack, Langfuse, Umami                                                         |
| `backup`                          | not set            | scheduled backups to S3                                                        |
| `deletionPolicy`                  | `Retain`           | `Delete` to remove volumes and generated secrets with the stack                |

### Identity

Choose one of the two.

**Keycloak deployed by the operator** (default, OpenShift only) : nothing to prepare. The operator creates the
`unifai` realm and one user per entry of `identity.adminUsers`.

**Your own Keycloak** : create a confidential client whose redirect URIs allow both UnifAI hosts, store its
secret in the release namespace, and reference it :

```yaml
stack:
  spec:
    identity:
      adminUsers: [alice]
      external:
        url: https://keycloak.example.com
        realm: unifai
        clientId: unifai
        clientSecret:
          name: unifai-oidc
          key: client-secret
```

## Upgrade

```bash
helm repo update
helm show crds unifai/unifai | kubectl apply --server-side -f -
helm upgrade unifai unifai/unifai --namespace unifai --reuse-values
```

Helm never updates custom resource definitions on its own, hence the second command. ArgoCD does.

Since v0.1.75 the orchestrator delegates at most 2 times per item by default (3 before). `MAS_MAX_DELEGATIONS_PER_ITEM`
changes it (`0` = unlimited). `stack.spec.extraEnv` is a map keyed by component, and the cap applies in the Temporal
worker, where the sessions run : set the variable under **both** `multiagent` (API and SSE) and `multiagentWorker`.
Without an override the default 2 applies everywhere.

```yaml
stack:
  spec:
    extraEnv:
      multiagent:
        - name: MAS_MAX_DELEGATIONS_PER_ITEM
          value: "3"
      multiagentWorker:
        - name: MAS_MAX_DELEGATIONS_PER_ITEM
          value: "3"
```

Since v0.1.76 the time a human has to answer a tool approval request is configurable with `MAS_HITL_TIMEOUT_SECONDS`
(seconds, a number greater than 0, default `300`). An approval that is not answered when the delay expires is rejected.
An empty or invalid value (not a number, `0` or negative) keeps the default and logs a warning; an unset variable keeps the default silently. As for the
delegation cap, set it under **both** `multiagent` and `multiagentWorker`, and restart the pods to apply a change. The
chart does not set it : nothing changes unless you add it.

```yaml
stack:
  spec:
    extraEnv:
      multiagent:
        - name: MAS_HITL_TIMEOUT_SECONDS
          value: "600"
      multiagentWorker:
        - name: MAS_HITL_TIMEOUT_SECONDS
          value: "600"
```

### Replicas of the multiagent server (UnifAI v0.1.77)

`stack.spec.replicas.multiagent` sets the number of `multiagent-be` pods (the multiagent API and SSE Deployment, not its
Temporal worker), from 1 to 10. It is the only key accepted for now. The chart does not set it : unset, the count stays
1 and nothing changes. Setting it, even to `1`, upgrades the multiagent-be release once: the pod count follows it and no running pod restarts. The
`dev` profile has no autoscaler and runs exactly that count ; `prod` raises the autoscaler minimum to it (and the
maximum when it is lower). More than one pod needs a ReadWriteMany shared storage (`stack.spec.storage.sharedClassName`).
Reference : `fork/unifai-operator/README.md` of the UnifAI sources (R-570).

```yaml
stack:
  spec:
    replicas:
      multiagent: 2
```

**The UnifaiStack definition changes in v0.1.77** (the `spec.replicas` field is new). Helm installs the definitions of
`crds/` only at `helm install` and never updates them, and this chart ships them there and nowhere else : after a
`helm upgrade` alone the cluster keeps the previous definition, which does not know `replicas`, and the API server drops
the field (or the client rejects it) so nothing scales. Update the definitions **before** the upgrade, with the first
command of this section (`helm show crds unifai/unifai | kubectl apply --server-side -f -`). Without `replicas` the
old definition keeps working, nothing else in the chart depends on it. With ArgoCD the operator Application applies
the definitions (the stack Application sets `skipCrds: true`) : sync it first.

## Uninstall

The operator is what removes the platform, so remove the stack first :

```bash
helm upgrade unifai unifai/unifai --namespace unifai --reuse-values --set stack.enabled=false
kubectl -n unifai wait --for=delete unifaistack/unifai --timeout=15m
helm uninstall unifai --namespace unifai
```

By default the volumes and the generated secrets are kept (`deletionPolicy: Retain`), so that reinstalling
finds the data again. Set `stack.spec.deletionPolicy=Delete` before removing the stack to delete them too.

The custom resource definitions are left in place by Helm. To remove them, and every UnifAI resource of the
cluster with them :

```bash
kubectl get crd -o name | grep unifai.startx.fr | xargs kubectl delete
```

## Troubleshooting

| Symptom                                               | Cause and fix                                                                                   |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| stack phase `Error`, "no OpenShift ingress domain found" | set `exposure.domain`                                                                        |
| stack phase `Error` on a Route object                 | the Route API is missing : set `exposure.ingress.installRouteCRD=true`                          |
| volumes stay `Pending`                                | `storage.sharedClassName` does not support ReadWriteMany                                        |
| web interface pod does not start, missing `unifai-ui-tls` | outside OpenShift that Secret must exist : keep `createUiServingCert=true` or provide it    |
| `helm uninstall` hangs                                | the stack was not removed first ; see [Uninstall](#uninstall)                                   |
| phase `Ready` but login fails                         | `Ready` does not test the identity provider : check the Keycloak address, client and redirect URIs |

The operator reports what it is doing on the resource itself and in its logs :

```bash
kubectl -n unifai describe unifaistack unifai
kubectl -n unifai logs deploy/unifai-operator-controller-manager
```

## History

| Release  | Date       | Description                                                                              |
| -------- | ---------- | ---------------------------------------------------------------------------------------- |
| 21.3.362 | 2026-11-18 | Create chart unifai, replacing cluster-unifai : UnifAI operator v0.1.71 and a UnifaiStack |
| 21.3.363 | 2026-11-18 | Create chart unifai, replacing cluster-unifai : UnifAI operator v0.1.71 and a UnifaiStack |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.393 | 2026-11-21 | unifai: UnifAI v0.1.75 (images pinned by digest); no CRD or RBAC change |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.399 | 2026-11-22 | update: UnifAI v0.1.76 (images pinned by digest), document MAS_HITL_TIMEOUT_SECONDS |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |
| 21.3.412 | 2026-11-22 | full repository release: internal pins on the previous published version (ADR-0006) |
| 21.3.413 | 2026-11-22 | update: UnifAI v0.1.77 (operator image pinned by digest), optional stack.spec.replicas.multiagent, UnifaiStack CRD change |
| 21.3.414 | 2026-11-22 | README: setting stack.spec.replicas upgrades the multiagent-be release without restarting a running pod |

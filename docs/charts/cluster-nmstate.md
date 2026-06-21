# ![cluster-nmstate](https://helm-repository.readthedocs.io/en/latest/img/cluster-nmstate.svg "Cluster Chart : NMState") Cluster Chart : NMState
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--nmstate-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+nmstate+startx)

Configure the NMState network operator for declarative node-level network interface configuration.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-nmstate
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics:

- Deploy the **NMState CR** (`nmstate/nmstate`) to activate the operator daemonset on all nodes
- The operator subscription and namespace are managed separately via the `operator` and `project` sub-charts (both disabled by default)

```bash
# base configuration running default configuration
helm install cluster-nmstate startx/cluster-nmstate
```

#### Full deployment with operator and project

Enable the operator subscription and project namespace alongside the NMState CR:

```bash
helm install cluster-nmstate startx/cluster-nmstate \
  --set project.enabled=true \
  --set operator.enabled=true
```

#### Other available values

- **startx** : NMState operator with full STARTX context (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nmstate/values-startx.yaml))

```bash
helm install cluster-nmstate startx/cluster-nmstate -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nmstate/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-nmstate` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-nmstate
  namespace: openshift-gitops
spec:
  description: Deploy the NMState network operator on OpenShift
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: openshift-nmstate
    - server: https://kubernetes.default.svc
      namespace: '*'
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: operators.coreos.com
      kind: OperatorGroup
    - group: operators.coreos.com
      kind: Subscription
    - group: nmstate.io
      kind: NMState
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-nmstate-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  destination:
    namespace: openshift-nmstate
    server: https://kubernetes.default.svc
  project: cluster-nmstate
  source:
    chart: cluster-nmstate
    helm:
      values: |
        project:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.105
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-nmstate-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: openshift-nmstate
    server: https://kubernetes.default.svc
  project: cluster-nmstate
  source:
    chart: cluster-nmstate
    helm:
      values: |
        operator:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.105
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-nmstate-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: openshift-nmstate
    server: https://kubernetes.default.svc
  project: cluster-nmstate
  source:
    chart: cluster-nmstate
    helm:
      values: |
        nmstate:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.105
  ignoreDifferences:
    - group: nmstate.io
      kind: NMState
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply with:

```bash
kubectl apply -f cluster-nmstate-argocd.yaml -n openshift-gitops
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## Values dictionary

### context values dictionary

| Key                 | Default           | Description                                                  |
| ------------------- | ----------------- | ------------------------------------------------------------ |
| context.scope       | `myscope`         | Name of the global scope for this application                |
| context.cluster     | `default`         | Name of the cluster running this application                 |
| context.environment | `myenv`           | Name of the environment (dev, factory, preprod, prod)        |
| context.component   | `mycomponent`     | Component name of this application                           |
| context.app         | `default-nmstate` | Application name                                             |
| context.version     | `4.21.0`          | Version name of this application                             |

### nmstate values dictionary

| Key             | Default   | Description                                                                    |
| --------------- | --------- | ------------------------------------------------------------------------------ |
| nmstate.enabled | `true`    | Enable the creation of the NMState CR to activate the operator                 |
| nmstate.hooked  | `false`   | Deploy as a Helm/ArgoCD post-sync hook                                         |
| nmstate.name    | `nmstate` | Name of the NMState instance (must be `nmstate` for the operator to reconcile) |

### nncp values dictionary

| Key               | Default                  | Description                                               |
| ----------------- | ------------------------ | --------------------------------------------------------- |
| nncp.enabled      | `false`                  | Enable the deployment of a NodeNetworkConfigurationPolicy |
| nncp.hooked       | `false`                  | Deploy as a Helm/ArgoCD post-sync hook                    |
| nncp.name         | `default-network-policy` | Name of the NodeNetworkConfigurationPolicy                |
| nncp.nodeSelector | `{}`                     | Node selector to target specific nodes (empty = all)      |
| nncp.desiredState | `interfaces: []`         | Desired network state in NMState YAML format              |

## History

| Release | Date       | Description                                             |
| ------- | ---------- | ------------------------------------------------------- |
| 21.3.3  | 2026-06-16 | Initial chart creation for NMState operator on OCP 4.21 |
| 21.3.4  | 2026-06-17 | Improve cluster-nmstate options                         |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository           |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |

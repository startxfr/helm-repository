# ![cluster-nfd](https://helm-repository.readthedocs.io/en/latest/img/cluster-nfd.svg "Cluster Chart : NFD") Cluster Chart : NFD
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--nfd-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+nfd+startx)

This helm chart is used to deploy Node Feature Discovery handled by an operator for discovery of hardware profile and feature and Label nodes with a representation of theses features.

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
helm show chart startx/cluster-nfd
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **openshift-nfd** without constraints
- 1 **operator:** named **nfd** configured with
  - The **stable** channel for community release
  - The **4.11.0** version
  - Deployed under the **openshift-nfd** project
- 1 **NodeFeatureDiscovery:** named **nfd-instance** configured with default example config
- 1 **NodeFeatureRule:** named **my-sample-rule** configured with default example config

```bash
# Create the project
helm install cluster-nfd-project startx/cluster-nfd --set project.enabled=true,operator.enabled=false,nfd.enabled=false
# Deploy the OADP operator
helm install cluster-nfd-operator startx/cluster-nfd --set project.enabled=false,operator.enabled=true,nfd.enabled=false && sleep 10
# Configure default OADP resources
helm install cluster-nfd-instance startx/cluster-nfd --set project.enabled=false,operator.enabled=false,nfd.enabled=true,nfr.enabled=true
```

#### Other available values

- **startx** : NFD operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nfd/values-startx.yaml))

```bash
helm install cluster-nfd startx/cluster-nfd -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nfd/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-nfd` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-nfd
  namespace: openshift-gitops
spec:
  description: Deploy the Node Feature Discovery operator on OpenShift
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: openshift-nfd
    - server: https://kubernetes.default.svc
      namespace: '*'
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: operators.coreos.com
      kind: OperatorGroup
    - group: operators.coreos.com
      kind: Subscription
    - group: nfd.openshift.io
      kind: NodeFeatureDiscovery
    - group: nfd.openshift.io
      kind: NodeFeatureRule
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-nfd-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  destination:
    namespace: openshift-nfd
    server: https://kubernetes.default.svc
  project: cluster-nfd
  source:
    chart: cluster-nfd
    helm:
      values: |
        project:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.68
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
  name: cluster-nfd-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: openshift-nfd
    server: https://kubernetes.default.svc
  project: cluster-nfd
  source:
    chart: cluster-nfd
    helm:
      values: |
        operator:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.68
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-nfd-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: openshift-nfd
    server: https://kubernetes.default.svc
  project: cluster-nfd
  source:
    chart: cluster-nfd
    helm:
      values: |
        nfd:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.68
  ignoreDifferences:
    - group: nfd.openshift.io
      kind: NodeFeatureDiscovery
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply with:

```bash
kubectl apply -f cluster-nfd-argocd.yaml -n openshift-gitops
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## History

| Release | Date       | Description                                       |
| ------- | ---------- | ------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.15 | 2026-03-02 | Prepare upgrading dependency to 19.23.11 |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.7 | 2026-03-02 | Update dependencies to version 20.14.0 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.1 | 2026-03-02 | Prepare release 21.3.x with 21.x dependencies |
| 21.3.3 | 2026-03-02 | Upgrade dependencies to v21.3.0 |
| 21.3.4 | 2026-06-17 | Improve cluster-nfd options |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |

# ![cluster-mustgather](https://helm-repository.readthedocs.io/en/latest/img/cluster-mustgather.svg "Cluster Chart : MustGather") Cluster Chart : MustGather
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--mustgather-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+mustgather+startx)

This helm chart is used to configure MustGather at the cluster level and help you manage attaching this MustGather to an existing case from the redhat support.


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
helm show chart startx/cluster-mustgather
```

### 4. Install this chart

```bash
helm install cluster-mustgather startx/cluster-mustgather
```

## Default values

Complete deployment of a MustGather configuration with the following characteristics:

- 1 **operator** named **must-gather-operator** deployed under **openshift-must-gather-operator**
- 1 **MustGather** report instance configured for a given support case ID
- Optional Red Hat credentials for uploading gathered data

```bash
# base configuration running default configuration
helm install cluster-mustgather startx/cluster-mustgather
```

## Other available values

- **startx** : mustgather cluster wide service configuration using mustgather operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mustgather/values-startx.yaml))

```bash
helm install cluster-mustgather startx/cluster-mustgather -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mustgather/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-mustgather` using two dedicated ArgoCD Applications sharing the same AppProject.
The must-gather operator installs in `openshift-operators` (AllNamespaces); MustGather report instances run in `default-mustgather`:

> The must-gather operator requires AllNamespaces scope to trigger must-gather on any namespace. No dedicated operator namespace is created — the subscription goes into `openshift-operators`.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-mustgather
  namespace: openshift-gitops
spec:
  description: Deploy the MustGather operator on OpenShift
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: openshift-operators
    - server: https://kubernetes.default.svc
      namespace: default-mustgather
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
---
# Wave 5 — MustGather operator subscription in openshift-operators (AllNamespaces)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-mustgather-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-mustgather
  source:
    chart: cluster-mustgather
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: false
        operator:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.67
  destination:
    namespace: openshift-operators
    server: https://kubernetes.default.svc
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Wave 10 — MustGather report instances in default-mustgather
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-mustgather-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-mustgather
  source:
    chart: cluster-mustgather
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        report:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.67
  ignoreDifferences:
    - group: managed.openshift.io
      kind: MustGather
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply with:

```bash
kubectl apply -f cluster-mustgather-argocd.yaml -n openshift-gitops
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
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
| 21.3.4 | 2026-06-17 | Improve cluster-mustgather options |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |

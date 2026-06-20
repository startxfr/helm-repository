# ![cluster-localstorage](https://helm-repository.readthedocs.io/en/latest/img/cluster-localstorage.svg "Cluster Chart : Local storage") Cluster Chart : Storage local
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--localstorage-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+localstorage+startx)

This helm chart is used to configure local storage at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedlocalstorage.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedlocalstorage.io) for
more information on how to use theses resources.

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
helm show chart startx/cluster-localstorage
```

### 4. Install this chart

```bash
helm install cluster-localstorage startx/cluster-localstorage
```

## Default values

Complete deployment of a project with the following characteristics :

Complete deployment of a LocalStorage configuration with the following characteristics :

- 1 **operator** named **local-storage-operator** deployed under **openshift-local-storage**
- 1 **LocalVolume** instance for local storage provisioning
- 1 **LocalVolumeSet** for automatic disk discovery
- 1 **LocalVolumeDiscovery** to discover available disks on nodes

```bash
# base configuration running default configuration
helm install cluster-localstorage startx/cluster-localstorage
```

## Others values availables

- **startx** : Startx local storage cluster wide service configuration using localstorage operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-localstorage/values-startx.yaml))

```bash
helm install cluster-localstorage startx/cluster-localstorage -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-localstorage/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-localstorage
  namespace: openshift-gitops
spec:
  description: Deploy Local Storage operator and configure local volumes
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-local-storage
      server: https://kubernetes.default.svc
    - namespace: openshift-gitops
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
```

### Applications

```yaml
---
# Creates namespace openshift-local-storage
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-localstorage-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-localstorage
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-localstorage
    targetRevision: 21.3.102
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
---
# Deploys local-storage-operator in openshift-local-storage (dedicated namespace, own OperatorGroup)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-localstorage-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-localstorage
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-localstorage
    targetRevision: 21.3.102
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        operator:
          enabled: true
          operatorGroup:
            enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-local-storage
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Configures LocalVolume, LocalVolumeSet and LocalVolumeDiscovery (disabled by default)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-localstorage-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-localstorage
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-localstorage
    targetRevision: 21.3.102
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        operator:
          enabled: false
        localstorage:
          enabled: false
        localstorageset:
          enabled: false
        localstoragediscovery:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-local-storage
  ignoreDifferences:
    - group: local.storage.openshift.io
      kind: LocalVolume
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                                      |
| -------- | ---------- | ---------------------------------------------------------------- |
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
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.12 | 2026-06-18 | Add ArgoCD examples for cluster-localstorage |
| 21.3.12 | 2026-06-18 | Improve cluster-localstorage options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |

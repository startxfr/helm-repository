# ![cluster-odf](https://helm-repository.readthedocs.io/en/latest/img/cluster-odf.svg "Cluster Chart : ODF") Cluster Chart : ODF
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--odf-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+odf+startx)

This helm chart is used to configure Openshift Container Storage at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
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
helm show chart startx/cluster-odf
```

### 4. Install this chart

```bash
helm install cluster-odf startx/cluster-odf
```

## Default values

Complete deployment of a project with the following characteristics :

Complete deployment of an OpenShift Data Foundation (ODF) configuration with the following characteristics :

- 1 **operator** named **odf-operator** deployed under **openshift-storage**
- 1 **StorageSystem** instance for Ceph-based persistent storage
- Optional storage cluster configuration for production-grade block, file and object storage

```bash
# base configuration running default configuration
helm install cluster-odf startx/cluster-odf
```

## Others values availables

- **startx** : Startx ODF cluster wide service configuration using ODF operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-odf/values-startx.yaml))

```bash
helm install cluster-odf startx/cluster-odf -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-odf/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-odf
  namespace: openshift-gitops
spec:
  description: Configure OpenShift Data Foundation operator
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-gitops
      server: https://kubernetes.default.svc
    - namespace: openshift-storage
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
```

### Applications

> **Deletion order**: always delete in reverse creation order - `cluster-odf-app` first (wait for StorageCluster cleanup), then `cluster-odf-operator`, then `cluster-odf-project`. The sync-waves below enforce this order automatically in an App-of-Apps pattern.

```yaml
---
# Wave 1 - created first, deleted LAST (namespace cleanup happens naturally once contents are gone)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-odf-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-odf
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-odf
    targetRevision: 21.3.55
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
# Wave 2 - operator deployed after namespace exists, deleted after StorageCluster is gone
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-odf-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-odf
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-odf
    targetRevision: 21.3.55
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        operator:
          enabled: true
          subscription:
            operator:
              channel: "stable-4.21"
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  # OLM adds olm.providedAPIs annotation and upgradeStrategy after operator install
  ignoreDifferences:
    - group: operators.coreos.com
      kind: OperatorGroup
      name: openshift-storage
      namespace: openshift-storage
      jsonPointers:
        - /metadata/annotations/olm.providedAPIs
        - /spec/upgradeStrategy
    - group: console.openshift.io
      kind: ConsolePlugin
      name: odf-console
      jqPathExpressions:
        - .spec
        - .metadata.annotations
        - .metadata.labels
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Wave 3 - created last, deleted FIRST so the ODF operator is still alive to process StorageCluster finalizers
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-odf-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-odf
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-odf
    targetRevision: 21.3.55
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        odf:
          enabled: true
          nodeLabeler:
            enabled: false
        operator:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  # OCS operator mutates these fields after sync — ignore to keep Application Synced
  ignoreDifferences:
    - group: ocs.openshift.io
      kind: StorageCluster
      jqPathExpressions:
        - .metadata.finalizers
        - .metadata.annotations["uninstall.ocs.openshift.io/cleanup-policy"]
        - .metadata.annotations["uninstall.ocs.openshift.io/mode"]
        - .spec.version
        - .spec.encryption.keyRotation
        - .spec.managedResources
        - .spec.storageDeviceSets[].replica
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

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
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.12 | 2026-06-19 | Improve cluster-odf options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| fix-storagecluster-apiversion | 2026-06-19 | fix-storagecluster-apiversion |
| 21.3.28 | 2026-06-19 | Improve cluster-odf options |
| 21.3.28 | 2026-06-19 | fix-apiversion |
| 21.3.29 | 2026-06-19 | Improve cluster-odf options |
| 21.3.30 | 2026-06-19 | Improve cluster-odf options |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |

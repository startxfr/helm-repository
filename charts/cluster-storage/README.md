# ![cluster-storage](https://helm-repository.readthedocs.io/en/latest/img/cluster-storage.svg "Cluster Chart : Storage") Cluster Chart : Storage
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--storage-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+storage+startx)

This helm chart is used to create a list of storageClass available for the cluster.

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
helm show chart startx/cluster-storage
```

### 4. Install this chart

```bash
helm install cluster-storage startx/cluster-storage
```

## Default values

Deployment of storage classes :

- 1 **storageClass** named **example-gp3-csi** with the following characteristics
  - **provisioner** set to **kubernetes.io/aws-ebs**
  - provisioner **encryption** specific parameters set to **true**
  - storage class **reclaim policy** set to **Delete**
  - storage class **volume expansion enabled**
  - storage class **volume binding mode** set to **WaitForFirstConsumer**

```bash
# base configuration running default configuration
helm install cluster-storage startx/cluster-storage
```

## Others values availables

- **startx** : Startx storage classes running under AWS infrastructure (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage/values-startx.yaml)) creating the following storage classes
  - **startx-aws-generic-retain** (AWS EBS gp3-csi level with encryption and expansion enabled with retain policy)
  - **startx-aws-generic-delete** (AWS EBS gp3-csi level with encryption and expansion enabled with delete policy)
  - **startx-aws-fast-retain** (AWS EBS io1 level without encryption and expansion enabled with retain policy)
  - **startx-aws-fast-delete** (AWS EBS io1 level without encryption and expansion enabled with delete policy)
  - **startx-aws-slow-retain** (AWS EBS sc1 level with encryption and expansion enabled with retain policy)
  - **startx-aws-slow-delete** (AWS EBS sc1 level with encryption and expansion enabled with delete policy)

```bash
helm install cluster-storage startx/cluster-storage -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage/values-startx.yaml
```

- **startx-ocs** : Startx storage classes for OCS infrastructure (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage/values-startx-ocs.yaml)) creating the following storage classes
  - **startx-odf-generic-retain** (OCS provisionned via openshift-storage.rbd.csi.ceph.com in cluster openshift-storage with retain policy and expansion enabled)
  - **startx-odf-generic-delete** (OCS provisionned via openshift-storage.rbd.csi.ceph.com in cluster openshift-storage with delete policy and expansion enabled)
  - **startx-odf-fs-retain** (OCS provisionned via openshift-storage.cephfs.csi.ceph.com in cluster openshift-storage with retain policy)
  - **startx-odf-fs-delete** (OCS provisionned via openshift-storage.cephfs.csi.ceph.com in cluster openshift-storage with delete policy)

```bash
helm install cluster-storage startx/cluster-storage -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage/values-startx-ocs.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-storage
  namespace: openshift-gitops
spec:
  description: Configure cluster storage classes
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
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
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-storage-app
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-storage
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-storage
    targetRevision: 21.3.105
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
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
| 21.3.12 | 2026-06-19 | Add ArgoCD deployment examples |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |

# STARTX helm : cluster-storage

This helm chart is used to create a list of storageClass available for the cluster.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration
state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### Get information about this chart

```bash
helm show chart startx/cluster-storage
```

### Install this chart

```bash
helm install startx/cluster-storage
```

## Default values

Deployment of storage classes :

- 1 **storageClass** named **example-gp2** with the following characteristics
  - **provisioner** set to **kubernetes.io/aws-ebs**
  - provisioner **encryption** specific parameters set to **true**
  - storage class **reclaim policy** set to **Delete**
  - storage class **volume expansion enabled**
  - storage class **volume binding mode** set to **WaitForFirstConsumer**

```bash
# base configuration running default configuration
helm install startx/cluster-storage
```

## Others values availables

- **startx** : Startx storage classes running under AWS infrastructure (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage/values-startx.yaml)) creating the following storage classes
  - **aws-generic-retain** (AWS EBS gp2 level with encryption and expansion enabled with retain policy)
  - **aws-generic-delete** (AWS EBS gp2 level with encryption and expansion enabled with delete policy)
  - **aws-fast-retain** (AWS EBS io1 level without encryption and expansion enabled with retain policy)
  - **aws-fast-delete** (AWS EBS io1 level without encryption and expansion enabled with delete policy)
  - **aws-slow-retain** (AWS EBS sc1 level with encryption and expansion enabled with retain policy)
  - **aws-slow-delete** (AWS EBS sc1 level with encryption and expansion enabled with delete policy)

```bash
helm install startx/cluster-storage -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage/values-startx.yaml
```

- **startx-ocs** : Startx storage classes for OCS infrastructure (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage/values-startx-ocs.yaml)) creating the following storage classes
  - **ocs-generic-retain** (OCS provisionned via openshift-storage.rbd.csi.ceph.com in cluster openshift-storage with retain policy and expansion enabled)
  - **ocs-generic-delete** (OCS provisionned via openshift-storage.rbd.csi.ceph.com in cluster openshift-storage with delete policy and expansion enabled)
  - **ocs-fs-retain** (OCS provisionned via openshift-storage.cephfs.csi.ceph.com in cluster openshift-storage with retain policy)
  - **ocs-fs-delete** (OCS provisionned via openshift-storage.cephfs.csi.ceph.com in cluster openshift-storage with delete policy)

```bash
helm install startx/cluster-storage -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage/values-startx-ocs.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.0   | 2020-10-23 | Initial commit for this helm chart with default value example (removed)
| 0.2.11  | 2020-10-25 | publish stable update for the full repository
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.2.94  | 2020-10-31 | Aligned stable release of all startx charts
| 0.2.96  | 2020-10-31 | Stable version 0.2.96 preparing the 0.3 release
| 0.2.96  | 2020-10-31 | Stable version 0.2.96 preparing 0.3 release
| 0.2.98  | 2020-10-31 | Stable version 0.2.98  preparing 0.3 release
| 0.2.98  | 2020-10-31 | publish stable update for the full repository

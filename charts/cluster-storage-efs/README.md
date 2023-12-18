# Cluster AWS EFS

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
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-storage-efs
```

### 4. Install this chart

```bash
helm install cluster-storage-efs startx/cluster-storage-efs
```

## Default values

Complete deployment of a project with the following characteristics :

xxxx to do xxxxxx

```bash
# base configuration running default configuration
helm install cluster-storage-efs startx/cluster-storage-efs
```

## Others values availables

- **startx** : Startx AWS EFS cluster wide service configuration using EFS operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage-efs/values-startx.yaml))

```bash
helm install cluster-storage-efs startx/cluster-storage-efs -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-storage-efs/values-startx.yaml
```

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 12.36.2 | 2023-09-30 | Create chart cluster-storage-efs from cluster-storage 
| 12.36.2 | 2023-10-01 | Create chart cluster-storage-efs from cluster-storage
| 12.36.9 | 2023-10-01 | publish stable update for the full repository
| 12.36.11 | 2023-10-01 | Improve cluster-storage-efs options
| 12.36.36 | 2023-10-11 | publish stable update for the full repository
| 12.36.49 | 2023-11-13 | publish stable update for the full repository
| 12.36.51 | 2023-11-13 | publish stable update for the full repository
| 12.36.58 | 2023-11-13 | Align all startx dependencies packages to version 12.36.49 stable for OCP 4.12.36
| 12.36.59 | 2023-11-13 | publish stable update for the full repository
| 12.36.63 | 2023-11-13 | publish stable update for the full repository
| 12.36.64 | 2023-11-13 | publish stable update for the full repository
| 12.36.65 | 2023-11-14 | publish stable update for the full repository
| 12.36.66 | 2023-11-14 | Update trunc to 255 for helper
| 12.36.69 | 2023-11-14 | move dependencies to version 12.36.65
| 12.45.0 | 2023-12-08 | Stable version aligned to Openshift version 4.12.45
| 13.26.0 | 2023-12-08 | Unstable version aligned to Openshift version 4.13.26 to prepare the 13.26.x stable release (short lived)
| 13.26.1 | 2023-12-09 | Minimum requirements for kubernetes is 1.26.0 version and upgrade all cluster-xxx charts to latest release for OCP 4.13
| 13.26.2 | 2023-12-09 | upgrade all dependencies charts to version 13.26.0
| 13.26.3 | 2023-12-09 | publish stable update for the full repository
| 14.6.1 | 2023-12-09 | iniFirst release for OCP 4.14 release. Aligned on 4.14.6 release
| 14.6.5 | 2023-12-10 | upgrade all dependencies charts to version 13.26.2
| 14.6.9 | 2023-12-10 | publish stable update for the full repository
| 14.6.11 | 2023-12-10 | upgrade minimum kubeVersion to 1.27.x and startx helm-chart dependencies to version 14.6.5
| 14.6.15 | 2023-12-11 | update packages for OCP 4.14.6
| 14.6.21 | 2023-12-18 | publish stable update for the full repository

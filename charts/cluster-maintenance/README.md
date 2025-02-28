# ![cluster-maintenance](https://helm-repository.readthedocs.io/en/latest/img/cluster-maintenance.svg "Cluster Chart : Maintenance") Cluster Chart : Maintenance
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--maintenance-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+maintenance+startx)

This helm chart is used to deploy the KubeMaintenance operator to help you evict pods based on specific strategies so that the pods can be rescheduled onto more appropriate nodes.

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
helm show chart startx/cluster-maintenance
```

### 4. Install this chart

```bash
helm install cluster-maintenance startx/cluster-maintenance
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-maintenance startx/cluster-maintenance
```

## Others values availables

- **startx** : maintenance operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-maintenance/values-startx.yaml))

```bash
helm install cluster-maintenance startx/cluster-maintenance -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-maintenance/values-startx.yaml
```

## History

| Release  | Date       | Description                                                       |
| -------- | ---------- | ----------------------------------------------------------------- |
| 16.19.15 | 2024-11-11 | Initialize the maintenance cluster-service chart                  |
| 16.19.17 | 2024-11-11 | Added support for the NodeMaintenance CRD
| 16.19.29 | 2024-11-11 | Align all chart to the 16.19.29 release
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release
| 16.19.31 | 2024-12-10 | Align all charts to 19.19.31
| 16.19.43 | 2025-02-27 | publish stable update for the full repository
| 17.14.1 | 2025-02-28 | Initial release for v17.x version

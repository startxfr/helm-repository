# ![cluster-descheduler](https://helm-repository.readthedocs.io/en/latest/img/cluster-descheduler.svg "Cluster Chart : Descheduler") Cluster Chart : Descheduler
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--descheduler-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+descheduler+startx)

This helm chart is used to deploy the KubeDescheduler operator to help you evict pods based on specific strategies so that the pods can be rescheduled onto more appropriate nodes.

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
helm show chart startx/cluster-descheduler
```

### 4. Install this chart

```bash
helm install cluster-descheduler startx/cluster-descheduler
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-descheduler startx/cluster-descheduler
```

## Others values availables

- **startx** : descheduler operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-descheduler/values-startx.yaml))

```bash
helm install cluster-descheduler startx/cluster-descheduler -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-descheduler/values-startx.yaml
```

## History

| Release  | Date       | Description                                                       |
| -------- | ---------- | ----------------------------------------------------------------- |
| 14.6.283 | 2024-05-29 | Initialize the descheduler cluster-service chart                  |
| 14.6.283 | 2024-05-29 | Creation of the cluster-descheduler chart                         |
| 14.6.285 | 2024-05-29 | Move descheduler name to cluster by default                       |
| 14.6.287 | 2024-05-29 | Move descheduler namespace to openshift-kube-descheduler-operator |
| 14.6.293 | 2024-05-29 | Align all charts to release 14.6.293
| 14.6.301 | 2024-05-30 | Helm package are now signed
| 14.6.321 | 2024-06-25 | publish stable update for the full repository
| 14.6.323 | 2024-06-25 | Align all chart to latest release
| 14.6.325 | 2024-06-25 | Adding chart logo in README header
| 14.6.325 | 2024-06-25 | publish stable update for the full repository
| 14.6.331 | 2024-06-25 | update all dependencies to version 14.6.323
| 14.6.335 | 2024-06-26 | publish stable update for the full repository
| 14.6.341 | 2024-06-26 | Update startx dependencies chart to release 14.6.339
| 14.6.343 | 2024-06-26 | publish stable update for the full repository
| 14.6.345 | 2024-06-26 | publish stable update for the full repository
| 14.6.351 | 2024-06-26 | Update all dependencies
| 14.6.353 | 2024-06-26 | Fixed missed dependencies in previous release
| 14.6.367 | 2024-06-29 | Align all startx charts to release 14.6.367
| 14.6.381 | 2024-06-30 | Align all startx charts to release 14.6.381
| 15.27.3 | 2024-11-06 | create init release for version 15.x
| 15.27.5 | 2024-11-06 | publish stable update for the full repository
| 15.27.7 | 2024-11-06 | Align all startx charts dependencies to release 15.27.3
| 15.27.9 | 2024-11-09 | Upgrade the Descheduler operator version to v5.0.1
| 15.27.17 | 2024-11-10 | Release aligned for OCP 4.15.27
| 15.27.21 | 2024-11-10 | Release aligned for OCP 4.15.37

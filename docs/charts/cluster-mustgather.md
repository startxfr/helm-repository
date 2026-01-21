# ![cluster-mustgather](https://helm-repository.readthedocs.io/en/latest/img/cluster-mustgather.svg "Cluster Chart : MustGather") Cluster Chart : MustGather
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--mustgather-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+mustgather+startx)

This helm chart is used to configure MustGather at the cluster level and help you manage attaching this MustGather to an existing case from the redhat support.


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
helm show chart startx/cluster-mustgather
```

### 4. Install this chart

```bash
helm install cluster-mustgather startx/cluster-mustgather
```

## Default values

Complete deployment of a project with the following characteristics :

xxxx to do xxxxxx

```bash
# base configuration running default configuration
helm install cluster-mustgather startx/cluster-mustgather
```

## Others values availables

- **startx** : mustgather cluster wide service configuration using mustgather operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mustgather/values-startx.yaml))

```bash
helm install cluster-mustgather startx/cluster-mustgather -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mustgather/values-startx.yaml
```

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 14.6.61 | 2023-12-22 | Create cluster-mustgather chart
| 14.6.63 | 2023-12-22 | Align all startx helm-chart to version 14.6.63
| 14.6.65 | 2023-12-27 | test with repo stored in s3 public bucket
| 14.6.71 | 2023-12-28 | Move to S3 helm repository
| 14.6.73 | 2023-12-29 | Upgrade all startx chart dependencies to version 14.6.65
| 14.6.75 | 2023-12-29 | Upgrade all startx chart dependencies to version 14.6.71
| 14.6.91 | 2024-01-02 | publish stable update for the full repository
| 14.6.99 | 2024-01-02 | Full stable release of the chart repository
| 14.6.103 | 2024-01-03 | Upgrade all startx chart dependencies to version 14.6.75
| 14.6.105 | 2024-01-03 | publish stable update for the full repository
| 14.6.107 | 2024-01-04 | publish stable update for the full repository
| 14.6.109 | 2024-01-04 | Update all chart dependencies to version 14.6.105
| 14.6.111 | 2024-01-18 | Stable version of the mustgather chart for OCP 4.14
| 14.6.131 | 2024-01-18 | publish stable update for the full repository
| 14.6.133 | 2024-01-18 | Update the documentation with artifacthub badge
| 14.6.135 | 2024-01-18 | debug artifacthub recommandations
| 14.6.137 | 2024-01-18 | publish stable update for the full repository
| 14.6.141 | 2024-02-03 | upgrade of the full startx repository
| 14.6.143 | 2024-02-03 | Align to 14.6.143 chart release
| 14.6.145 | 2024-02-03 | Update all startx dependencies chart to 14.6.141 chart release
| 14.6.149 | 2024-02-03 | Update all startx dependencies chart to 14.6.141 chart release
| 14.6.150 | 2024-02-03 | Stable 14.6.150 release
| 14.6.161 | 2024-02-08 | publish stable update for the full repository
| 14.6.171 | 2024-02-08 | publish stable update for the full repository
| 14.6.189 | 2024-02-08 | publish stable update for the full repository
| 14.6.195 | 2024-02-08 | publish stable update for the full repository
| 14.6.197 | 2024-02-08 | publish stable update for the full repository
| 14.6.201 | 2024-02-08 | publish stable update for the full repository
| 14.6.208 | 2024-03-06 | Align all dependencies to 14.6.208 release
| 14.6.215 | 2024-03-08 | Align all charts to release 14.6.215
| 14.6.231 | 2024-03-19 | Align all charts to release 14.6.231
| 14.6.251 | 2024-03-27 | Align all charts to release 14.6.251
| 14.6.269 | 2024-03-31 | Align all charts to release 14.6.269
| 14.6.281 | 2024-05-20 | Align all charts to release 14.6.281
| 14.6.293 | 2024-05-29 | Align all charts to release 14.6.293
| 14.6.301 | 2024-05-30 | Helm package are now signed
| 14.6.321 | 2024-06-25 | publish stable update for the full repository
| 14.6.323 | 2024-06-25 | Align all chart to latest release
| 14.6.325 | 2024-06-25 | Adding chart logo in README header
| 14.6.325 | 2024-06-25 | publish stable update for the full repository
| 14.6.331 | 2024-06-25 | update all dependencies to version 14.6.323
| 14.6.335 | 2024-06-26 | publish stable update for the full repository
| 14.6.343 | 2024-06-26 | publish stable update for the full repository
| 14.6.345 | 2024-06-26 | publish stable update for the full repository
| 14.6.351 | 2024-06-26 | Update all dependencies
| 14.6.353 | 2024-06-26 | Fixed missed dependencies in previous release
| 14.6.367 | 2024-06-29 | Align all startx charts to release 14.6.367
| 14.6.381 | 2024-06-30 | Align all startx charts to release 14.6.381
| 15.27.3 | 2024-11-06 | create init release for version 15.x
| 15.27.5 | 2024-11-06 | publish stable update for the full repository
| 15.27.7 | 2024-11-06 | Align all startx charts dependencies to release 15.27.3
| 15.27.9 | 2024-11-09 | Upgrade basic startx charts dependencies to release 15.27.8
| 15.27.17 | 2024-11-10 | Release aligned for OCP 4.15.27
| 15.27.21 | 2024-11-10 | Release aligned for OCP 4.15.37
| 16.19.3 | 2024-11-10 | Init release 16.19.1 aligned for OCP 4.16.19
| 16.19.7 | 2024-11-10 | Update all dependencies to version 16.19.4
| 16.19.11 | 2024-11-10 | Update all dependencies to version 16.19.4
| 16.19.15 | 2024-11-10 | publish stable update for the full repository
| 16.19.29 | 2024-11-11 | Align all chart to the 16.19.29 release
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release
| 16.19.31 | 2024-12-10 | Align all charts to 19.19.31
| 16.19.43 | 2025-02-27 | publish stable update for the full repository
| 17.14.1 | 2025-02-28 | Initial release for v17.x version
| 17.14.3 | 2025-02-28 | Temporary release used to prepare dependencies changes
| 17.14.5 | 2025-02-28 | Align all startx helm dependencies to release 17.14.1
| 17.14.11 | 2025-03-05 | Adjust doc to material layout
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version
| 18.11.3 | 2025-04-30 | Prepare dependencies move to version 18.x
| 18.11.5 | 2025-04-30 | move dependencies to version 18.11.1
| 18.11.7 | 2025-04-30 | All dependencies linked to 18.x release
| 18.11.9 | 2025-05-01 | Update must gather operator version naming
| 18.11.19 | 2025-05-02 | Intermediate alignement of all helm charts
| 18.11.21 | 2025-05-02 | Update all basic chart dependencies to version 18.11.15
| 18.11.22 | 2025-05-02 | Add noinfra values in all charts
| 18.11.24 | 2025-05-02 | Align all to stable version
| 18.11.31 | 2025-05-03 | update all dependencies to version 18.11.19
| 18.11.39 | 2025-05-05 | Update icon with startx new theme
| 18.11.51 | 2025-05-06 | publish stable update for the full repository
| 18.11.52 | 2025-05-07 | publish stable update for the full repository
| 18.11.60 | 2025-05-14 | Align all chart to a stable release for OCP 4.18
| 18.11.71 | 2025-11-27 | Align all charts to the same releas

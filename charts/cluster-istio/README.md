# ![cluster-istio](https://helm-repository.readthedocs.io/en/latest/img/cluster-istio.svg "Cluster Chart : Istio") Cluster Chart : Istio
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--istio-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+istio+startx)

This helm chart is used to configure Istio at the cluster level.

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
helm show chart startx/cluster-istio
```

### 4. Install this chart

```bash
helm install cluster-istio startx/cluster-istio
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **openshift-distributed-tracing** without constraints
- 1 **operator:** named **servicemeshoperator** configured with
  - The **stable** channel for community release
  - The **v2.6.7** version
  - Deployed under the **openshift-operators** project
- 1 **operator:** named **jaeger-product** configured with
  - The **stable** channel for community release
  - The **v1.65.0** version
  - Deployed under the **openshift-distributed-tracing** project
- 1 **operator:** named **kiali-ossm** configured with
  - The **stable** channel for community release
  - The **v2.4.4** version
  - Deployed under the **openshift-operators** project
- 1 **operator:** named **loki-operator** configured with
  - The **stable-6.2** channel for community release
  - The **6.2.1** version
  - Deployed under the **openshift-operators-redhat** project
- 1 **operator:** named **elasticsearch-operator** configured with
  - The **stable** channel for community release
  - The **5.8.19** version
  - Deployed under the **openshift-operators-redhat** project


```bash
# Create the project
helm install cluster-gpu-project startx/cluster-gpu --set project.enabled=true,operator.enabled=false,gpu.enabled=false
# Deploy the istio operator
helm install cluster-gpu-operator startx/cluster-gpu --set project.enabled=false,operator.enabled=true,gpu.enabled=false && sleep 10
# Configure default istio ressources
helm install cluster-gpu-instance startx/cluster-gpu --set project.enabled=false,operator.enabled=false,gpu.enabled=true
```

## Others values availables

- **startx** : Startx Istio service configuration using service-mesh operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-startx.yaml))

```bash
helm install cluster-istio startx/cluster-istio -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-startx.yaml
```

## History

| Release  | Date       | Description                                                                                                                  |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------- |
| 0.3.21   | 2020-11-07 | Add ServiceMesh deployment with elastic,kiali and jager dependencies management. Could create a controlPlane and memberroll. |
| 0.3.23   | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information                       |
| 0.3.29   | 2020-11-07 | Improve NOTES output and move to 0.3.25 dependencies                                                                         |
| 0.3.47   | 2020-11-08 | Update dependency to 0.3.45 release                                                                                          |
| 0.3.93   | 2020-11-10 | Move to 0.3.93 dependencies for all cluster-xxx charts in the startx repository                                              |
| 0.3.105  | 2020-11-11 | Update cluster-xxx charts dependencies to 0.3.103 release                                                                    |
| 0.3.117  | 2020-11-12 | Move to 0.3.115 basic chart dependencies                                                                                     |
| 0.3.126  | 2020-11-14 | Move to a servie mesh usage                                                                                                  |
| 0.3.135  | 2020-11-15 | Add multiple value (istio member only) and enable ServiceMeshMember only for this chart                                      |
| 0.3.135  | 2020-11-23 | Improve documentation for all examples charts                                                                                |
| 0.3.141  | 2020-11-24 | publish stable update for the full repository                                                                                |
| 0.3.151  | 2021-01-23 | Upgrade istio to version 2.0.0.2                                                                                             |
| 0.3.151  | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                                                                          |
| 0.3.153  | 2021-01-23 | publish stable update for the full repository                                                                                |
| 0.3.165  | 2021-01-23 | Upgrade all chart dependencies                                                                                               |
| 0.3.167  | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments                                                  |
| 0.3.169  | 2021-01-24 | Move to 0.3.155 dependencies                                                                                                 |
| 0.3.187  | 2021-02-13 | Align cluster chart release to 0.3.187                                                                                       |
| 0.3.191  | 2021-02-13 | Update cluster chart dependencies to 0.3.189                                                                                 |
| 0.3.199  | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts                                                                  |
| 0.3.201  | 2021-02-20 | Update icon and image for charts                                                                                             |
| 0.3.203  | 2021-02-21 | Upgrade chart release informations                                                                                           |
| 0.3.207  | 2021-04-19 | Core chart dependencies moved to v0.3.205                                                                                    |
| 0.3.209  | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                                                                              |
| 0.3.215  | 2021-05-06 | Align all chart to release 0.3.215                                                                                           |
| 0.3.217  | 2021-05-06 | Move to elastic operator version 5.0.2-18 (OCP 4.7 compat)                                                                   |
| 0.3.219  | 2021-05-06 | Move to elastic operator version 5.0.3-6 (OCP 4.7 compat)                                                                    |
| 0.3.225  | 2021-05-10 | Update all chart to use new RBAC naming                                                                                      |
| 0.3.227  | 2021-05-27 | Update elastic operator to 5.0.4-21                                                                                          |
| 0.3.228  | 2021-06-02 | Upgrade servicemesh operator to 2.0.5.1                                                                                      |
| 0.3.305  | 2021-06-04 | publish stable update for the full repository                                                                                |
| 0.3.343  | 2021-06-06 | publish stable update for the full repository                                                                                |
| 0.3.381  | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377                                                 |
| 0.3.390  | 2021-06-12 | Prepare 0.4.0 release                                                                                                        |
| 0.3.423  | 2021-06-17 | Prepare the v0.4 release. Stable aligned version of all charts                                                               |
| 0.3.424  | 2021-06-19 | Update elastic operator to version 5.0.5-11                                                                                  |
| 0.3.431  | 2021-07-05 | Move to dependencies 1.18.0                                                                                                  |
| 0.3.441  | 2021-07-27 | Update elastic operator to version 5.1.0-96                                                                                  |
| 0.3.443  | 2021-07-27 | Update kiali operator to version 1.24.8 and jaeger to 1.20.4                                                                 |
| 0.3.445  | 2021-07-27 | Upgrade servicemesh operator to 2.0.6.2                                                                                      |
| 0.3.480  | 2021-08-03 | publish stable update for the full repository                                                                                |
| 0.3.998  | 2021-08-04 | publish stable update for the full repository                                                                                |
| 0.3.999  | 2021-08-04 | Release stable version 0.3.999 align with ocp 4.7.13                                                                         |
| 7.22.1   | 2021-08-04 | Move to release 7.22.1 to align versionning with ocp release cycle                                                           |
| 7.22.2   | 2021-08-04 | Move helm dependencies to a 7.x.x release model                                                                              |
| 7.22.3   | 2021-08-05 | publish stable update for the full repository                                                                                |
| 7.22.5   | 2021-08-05 | publish stable update for the full repository                                                                                |
| 7.22.6   | 2021-08-05 | Stable version for chart dependencies                                                                                        |
| 7.22.7   | 2021-08-05 | Stable for OCP version 4.7.22                                                                                                |
| 7.22.12  | 2021-09-23 | publish stable update for the full repository                                                                                |
| 7.22.21  | 2021-10-05 | ServiceAccount and ImagePullSecrets managed by project chart                                                                 |
| 7.22.25  | 2021-10-06 | publish stable update for the full repository                                                                                |
| 7.22.27  | 2021-10-06 | publish stable update for the full repository                                                                                |
| 8.13.1   | 2021-10-06 | Stable release for OCP 4.8.13 version                                                                                        |
| 8.13.3   | 2021-10-08 | Improve code execution, syntax and introduce the ACS helm-chart                                                              |
| 8.13.5   | 2021-10-21 | publish stable update for the full repository                                                                                |
| 8.13.7   | 2021-10-21 | publish stable update for the full repository                                                                                |
| 8.13.8   | 2021-10-21 | Adding first draft of json schema                                                                                            |
| 8.13.9   | 2021-10-22 | Adding the schema in chart                                                                                                   |
| 8.13.9   | 2021-10-22 | Adding the schema in chart                                                                                                   |
| 8.13.25  | 2021-11-10 | Solve helm issue in the kubeVersion for kube clusters and upgrade chart dep to version 8.13.23                               |
| 8.13.27  | 2021-11-10 | publish stable update for the full repository                                                                                |
| 8.20.3   | 2021-11-11 | Align all charts to Openshift version 4.8.20                                                                                 |
| 8.20.3   | 2021-11-11 | stable release for all chart for openshift version 4.8.20                                                                    |
| 8.20.5   | 2021-11-12 | Upgrade all appVersion and align chart release                                                                               |
| 8.20.9   | 2021-11-12 | Align all startx chart to version 8.20.9                                                                                     |
| 0.20.11  | 2021-11-12 | Move chart dependencies to version 8.20.5                                                                                    |
| 0.20.33  | 2021-11-14 | publish stable update for the full repository                                                                                |
| 0.20.41  | 2021-11-14 | Aling all dependencies to version 0.20.34                                                                                    |
| 8.20.46  | 2021-11-19 | Transitionnal chart                                                                                                          |
| 8.20.60  | 2021-11-19 | publish stable update for the full repository                                                                                |
| 8.20.66  | 2021-11-20 | Updating limits for context vars in values schema                                                                            |
| 8.20.67  | 2021-11-20 | Update elasticsearch operator to release 5.3.0-67                                                                            |
| 8.20.68  | 2021-11-20 | Update all operators and upgrade to maistra.io v2                                                                            |
| 8.20.70  | 2021-11-20 | publish stable update for the full repository                                                                                |
| 8.20.71  | 2021-11-20 | Align all charts to Openshift version 4.8.21                                                                                 |
| 9.8.1    | 2021-11-20 | Upgrade to Openshift version 4.9.8                                                                                           |
| 9.8.4    | 2021-11-20 | Stable release of chart for Openshift 4.9.8 version                                                                          |
| 9.8.7    | 2021-11-20 | Debug dependencies problem                                                                                                   |
| 9.8.9    | 2021-11-20 | Update startx chart dependencies version to 9.8.8 and schema update                                                          |
| 9.8.15   | 2021-11-20 | Update startx chart dependencies version to 9.8.11                                                                           |
| 9.8.16   | 2021-11-20 | Debug ServiceMeshMember version to maistra.io/v1                                                                             |
| 9.8.19   | 2021-11-20 | Update startx chart dependencies version to 9.8.15 and improve values schema                                                 |
| 9.8.28   | 2021-11-20 | Update the startx chart dependencies to version 9.8.23                                                                       |
| 9.8.39   | 2021-11-21 | Debug version check with more permissive mode                                                                                |
| 9.8.43   | 2021-11-21 | Update the startx chart dependencies to version 9.8.39                                                                       |
| 9.8.45   | 2021-11-21 | Update the values schema limits for context properties                                                                       |
| 9.8.47   | 2021-11-21 | Improve version management for chart                                                                                         |
| 9.8.51   | 2021-11-22 | Update startx chart dependencies to version 9.8.48                                                                           |
| 9.8.52   | 2021-12-07 | Improve quotas management in demo-project                                                                                    |
| 9.8.53   | 2021-12-07 | Debug quotas                                                                                                                 |
| 9.8.67   | 2021-12-18 | Align all charts to release 9.8.67                                                                                           |
| 9.8.68   | 2021-12-18 | Update elasticsearch operator to version 5.3.1-12                                                                            |
| 9.8.68   | 2021-12-18 | Improve cluster-istio options                                                                                                |
| 9.8.71   | 2021-12-18 | Update helm-chart dependencies to version 9.8.59                                                                             |
| 9.8.75   | 2021-12-19 | Align with all other startx chart version to number 9.8.75                                                                   |
| 9.8.76   | 2021-12-19 | Change helm.sh/chart name                                                                                                    |
| 9.8.81   | 2021-12-20 | Update the storage context                                                                                                   |
| 9.8.82   | 2022-02-23 | Upgrate elastic and logging operator to version 5.3.4-13                                                                     |
| 9.8.91   | 2022-03-06 | publish stable update for the full repository                                                                                |
| 9.8.93   | 2022-03-07 | Enable conditionnal loading of charts dependencies                                                                           |
| 9.8.94   | 2022-03-07 | Update the elastic operator to version 5.3.5-20                                                                              |
| 9.8.95   | 2022-04-21 | Update the elastic operator to version 5.4.0-152                                                                             |
| 9.8.109  | 2022-04-26 | Update startx chart dependencies to version 9.8.107                                                                          |
| 9.8.110  | 2022-04-27 | Stable release for all charts                                                                                                |
| 9.8.111  | 2022-04-27 | publish stable update for the full repository                                                                                |
| 9.8.114  | 2022-04-27 | publish stable update for the full repository                                                                                |
| 9.8.215  | 2022-05-06 | Upgrade startx chart dependencies to version 9.8.211                                                                         |
| 9.8.230  | 2022-05-06 | Stable full repository                                                                                                       |
| 9.8.231  | 2022-05-06 | Debug basic chart dependencies                                                                                               |
| 9.8.233  | 2022-05-06 | publish stable update for the full repository                                                                                |
| 9.8.239  | 2022-05-17 | Remove default csv from all charts. global release 9.8.239                                                                   |
| 9.8.253  | 2022-05-29 | Align all charts dependencies to release 9.8.251                                                                             |
| 9.8.277  | 2022-05-31 | publish stable update for the full repository                                                                                |
| 9.15.1   | 2022-06-01 | Align all chart for Openshift 4.9.15                                                                                         |
| 9.15.2   | 2022-06-01 | Align all charts to release 9.15.1                                                                                           |
| 9.15.3   | 2022-06-01 | Align all charts to release 9.15.3                                                                                           |
| 10.12.1  | 2022-06-01 | Align all charts to release 10.12.1                                                                                          |
| 10.12.3  | 2022-06-01 | publish stable update for the full repository                                                                                |
| 10.12.4  | 2022-06-01 | Align all charts to release 10.12.4                                                                                          |
| 10.12.5  | 2022-06-01 | publish stable update for the full repository                                                                                |
| 10.12.22 | 2022-06-04 | Align all chart to release version 10.12.22                                                                                  |
| 10.12.23 | 2022-06-04 | Basi chart dependencies upgraded to version 10.12.5                                                                          |
| 10.12.29 | 2022-06-17 | Align all charts to version 10.12.29                                                                                         |
| 10.12.29 | 2022-06-17 | publish stable update for the full repository                                                                                |
| 10.12.30 | 2022-06-17 | Improved logo and global documentation                                                                                       |
| 10.12.33 | 2022-06-17 | publish stable update for the full repository                                                                                |
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31                                                                                    |
| 10.12.39 | 2022-06-18 | Align all chart to revision 10.12.39                                                                                         |
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41                                                                                         |
| 10.12.46 | 2022-06-18 | publish stable update for the full repository                                                                                |
| 10.12.49 | 2022-06-18 | publish stable update for the full repository                                                                                |
| 10.12.53 | 2022-06-18 | publish stable update for the full repository                                                                                |
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts                                                                                           |
| 10.12.72 | 2022-07-02 | Common release                                                                                                               |
| 10.12.77 | 2022-07-02 | Stable for clients                                                                                                           |
| 10.12.81 | 2022-07-02 | publish stable update for the full repository                                                                                |
| 10.12.97 | 2022-07-03 | publish stable update for the full repository                                                                                |
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart                                                                                     |
| 11.5.3   | 2022-09-17 | Align all STARTX charts to release 11.5.3                                                                                    |
| 11.7.1   | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release                                                             |
| 11.7.3   | 2022-10-02 | publish stable update for the full repository                                                                                |
| 11.7.9   | 2022-10-02 | publish stable update for the full repository                                                                                |
| 11.7.10 | 2022-10-02 | Stable release for all packages
| 11.7.11 | 2022-10-02 | publish stable update for the full repository
| 11.7.15 | 2022-10-02 | publish stable update for the full repository
| 11.7.17 | 2022-10-02 | publish stable update for the full repository
| 11.7.31 | 2022-10-29 | publish stable update for the full repository
| 11.7.33 | 2022-10-29 | Update all startx packages to release 11.7.33
| 11.7.41 | 2022-11-02 | publish stable update for the full repository
| 11.7.61 | 2022-11-30 | publish stable update for the full repository
| 11.7.62 | 2022-11-30 | Debug console links and notifications
| 11.7.63 | 2022-11-30 | publish stable update for the full repository
| 11.7.67 | 2022-11-30 | Debug depedencies on sub charts
| 11.7.69 | 2022-11-30 | Finished dependencies stabilization
| 11.7.73 | 2022-12-04 | Align all packages to release 11.7.73
| 11.7.75 | 2022-12-04 | publish stable update for the full repository
| 11.7.77 | 2022-12-05 | publish stable update for the full repository
| 11.7.87 | 2023-02-15 | publish stable update for the full repository
| 11.7.88 | 2023-02-15 | publish stable update for the full repository
| 11.7.91 | 2023-02-16 | publish stable update for the full repository
| 11.7.93 | 2023-02-16 | align dependencies to version 11.7.89
| 11.7.97 | 2023-02-19 | publish stable update for the full repository
| 11.28.3 | 2023-02-19 | Upgrade to 1.39.0-3 jaeger, 1.57.5 kiali and 2.3.1 servicemesh operator release
| 11.28.11 | 2023-02-19 | publish stable update for the full repository
| 11.28.15 | 2023-02-19 | publish stable update for the full repository
| 11.28.16 | 2023-02-19 | publish stable update for the full repository
| 11.28.19 | 2023-02-19 | publish stable update for the full repository
| 11.28.21 | 2023-02-19 | Upgrade all dependencies packages to release 11.28.15
| 11.28.23 | 2023-02-21 | publish stable update for the full repository
| 11.28.27 | 2023-02-21 | All chart aligned to release 11.28.27
| 11.28.29 | 2023-02-21 | publish stable update for the full repository
| 11.28.35 | 2023-02-21 | publish stable update for the full repository
| 11.28.49 | 2023-02-21 | publish stable update for the full repository
| 11.28.59 | 2023-02-21 | publish stable update for the full repository
| 11.28.60 | 2023-02-21 | publish stable update for the full repository
| 11.28.67 | 2023-02-23 | publish stable update for the full repository
| 11.28.69 | 2023-03-07 | publish stable update for the full repository
| 11.28.89 | 2023-04-01 | publish stable update for the full repository
| 11.28.93 | 2023-04-20 | publish stable update for the full repository
| 11.28.95 | 2023-04-21 | publish stable update for the full repository
| 11.28.99 | 2023-04-21 | publish stable update for the full repository
| 11.28.103 | 2023-05-04 | publish stable update for the full repository
| 11.28.127 | 2023-06-12 | publish stable update for the full repository
| 11.28.128 | 2023-06-12 | publish stable update for the full repository
| 11.28.129 | 2023-06-13 | publish stable update for the full repository
| 11.28.201 | 2023-07-06 | publish stable update for the full repository
| 11.28.207 | 2023-07-06 | publish stable update for the full repository
| 11.28.230 | 2023-08-18 | Align all helm chart to release 11.28.230 stable release
| 11.30.0 | 2023-08-18 | Align all helm chart to release 11.30.0 stable for OCP 4.11.30
| 11.40.0 | 2023-08-18 | Align all helm chart to release 11.40.0 stable for OCP 4.11.40
| 11.47.0 | 2023-08-18 | Align all helm chart to release 11.47.0 stable for OCP 4.11.47
| 11.47.1 | 2023-08-18 | Update appVersion in Chart.yml
| 12.0.0 | 2023-08-18 | Align all helm chart to release 12.0.0 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.1 | 2023-08-18 | Align all helm chart to release 12.0.1 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.5 | 2023-08-18 | publish stable update for the full repository
| 12.0.7 | 2023-08-18 | Upgrade to 5.7.4 Elasticsearch operator release
| 12.0.8 | 2023-08-18 | Upgrade to 1.42.0-5 Jaeger, 1.65.7 Kiali and 2.4.2 Istio operator release
| 12.0.11 | 2023-08-18 | publish stable update for the full repository
| 12.0.12 | 2023-09-28 | Upgrade to 1.47.0-2 Jaeger operator release
| 12.30.1 | 2023-09-29 | release 12.30.1 aligned and tested with OCP 4.12.30
| 12.36.1 | 2023-09-29 | release 12.36.0 aligned with OCP 4.12.36 (unstable)
| 12.36.2 | 2023-09-29 | Update distributed tracing namespace
| 12.36.9 | 2023-10-01 | publish stable update for the full repository
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
| 14.6.22 | 2023-12-18 | stable si good
| 14.6.27 | 2023-12-19 | publish stable update for the full repository
| 14.6.29 | 2023-12-19 | publish stable update for the full repository
| 14.6.31 | 2023-12-19 | move to kubeversion min 1.25.0
| 14.6.33 | 2023-12-19 | Move dependencies to github-pages
| 14.6.35 | 2023-12-20 | publish stable update for the full repository
| 14.6.45 | 2023-12-22 | publish stable update for the full repository
| 14.6.46 | 2023-12-22 | publish stable update for the full repository
| 14.6.55 | 2023-12-22 | align all dependencies chart to 14.6.45
| 14.6.59 | 2023-12-22 | move back dependencies to version 14.6.35
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
| 14.6.131 | 2024-01-18 | publish stable update for the full repository
| 14.6.133 | 2024-01-18 | Update the documentation with artifacthub badge
| 14.6.135 | 2024-01-18 | debug artifacthub recommandations
| 14.6.137 | 2024-01-18 | publish stable update for the full repository
| 14.6.141 | 2024-02-03 | upgrade of the full startx repository
| 14.6.143 | 2024-02-03 | Align to 14.6.143 chart release
| 14.6.145 | 2024-02-03 | Update all startx dependencies chart to 14.6.141 chart release
| 14.6.149 | 2024-02-03 | Update all startx dependencies chart to 14.6.141 chart release
| 14.6.150 | 2024-02-03 | Stable 14.6.150 release
| 14.6.151 | 2024-02-08 | Adding support for placement into infra node
| 14.6.153 | 2024-02-08 | Adding support for placement into infra node
| 14.6.161 | 2024-02-08 | publish stable update for the full repository
| 14.6.163 | 2024-02-08 | Adding support for manual config of the alertManager
| 14.6.171 | 2024-02-08 | publish stable update for the full repository
| 14.6.189 | 2024-02-08 | publish stable update for the full repository
| 14.6.195 | 2024-02-08 | publish stable update for the full repository
| 14.6.197 | 2024-02-08 | publish stable update for the full repository
| 14.6.201 | 2024-02-08 | publish stable update for the full repository
| 14.6.203 | 2024-02-09 | Remove the NoExecute from the infra toleration
| 14.6.205 | 2024-02-09 | Improve cluster-istio options
| 14.6.208 | 2024-03-06 | Align all dependencies to 14.6.208 release
| 14.6.215 | 2024-03-08 | Align all charts to release 14.6.215
| 14.6.231 | 2024-03-19 | Align all charts to release 14.6.231
| 14.6.233 | 2024-03-23 | Adding support for serviceMesh version
| 14.6.251 | 2024-03-27 | Align all charts to release 14.6.251
| 14.6.269 | 2024-03-31 | Align all charts to release 14.6.269
| 14.6.281 | 2024-05-20 | Align all charts to release 14.6.281
| 14.6.283 | 2024-05-21 | Move default limits for ephemeral-storage to 500Mi
| 14.6.293 | 2024-05-29 | Align all charts to release 14.6.293
| 14.6.301 | 2024-05-30 | Helm package are now signed
| 14.6.303 | 2024-06-24 | Stop eviction with 1Gi limits for prometheus epemeral-storage
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
| 15.27.9 | 2024-11-09 | Upgrade the Istio version to v2.6.2, Jaeger version to v1.57.0-10-0.1730817420, Kiali version to v1.89.6 and ElasticSearch version to v5.8.14
| 15.27.17 | 2024-11-10 | Release aligned for OCP 4.15.27
| 15.27.21 | 2024-11-10 | Release aligned for OCP 4.15.37
| 16.19.3 | 2024-11-10 | Init release 16.19.1 aligned for OCP 4.16.19
| 16.19.7 | 2024-11-10 | Update all dependencies to version 16.19.4
| 16.19.11 | 2024-11-10 | Update all dependencies to version 16.19.4
| 16.19.15 | 2024-11-10 | publish stable update for the full repository
| 16.19.17 | 2024-11-11 | Adding support for the loki operator
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
| 18.11.9 | 2025-05-01 | Upddate operator servicemesh to version 2.6.7 and related operators
| 18.11.11 | 2025-05-01 | Update all operators version context
| 18.11.19 | 2025-05-02 | Intermediate alignement of all helm charts
| 18.11.21 | 2025-05-02 | Update all basic chart dependencies to version 18.11.15
| 18.11.22 | 2025-05-02 | Add noinfra values in all charts
| 18.11.24 | 2025-05-02 | Align all to stable version
| 18.11.31 | 2025-05-03 | update all dependencies to version 18.11.19
| 18.11.39 | 2025-05-05 | Update icon with startx new theme
| 18.11.51 | 2025-05-06 | publish stable update for the full repository
| 18.11.52 | 2025-05-07 | publish stable update for the full repository
| 18.11.60 | 2025-05-14 | Align all chart to a stable release for OCP 4.18

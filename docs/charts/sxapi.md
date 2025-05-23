# ![sxapi](https://helm-repository.readthedocs.io/en/latest/img/sxapi.svg "Basic Chart : SXAPI") Basic Chart : SXAPI
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_sxapi-83E22B.svg)](https://artifacthub.io/packages/search?ts_query_web=sxapi+startx)

This helm chart is used to deploy a lightweight micro-service based on
the [sxapi engine](https://sxapi-core.readthedocs.io). The deployment is exposed into the cluster
and could be exposed outside by using various exposition method (ingress, route or nodePort).

You can configure the behavior of you micro-service directly into your values.yaml file and versionning
it will allow you to keep track of your application states.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use STARTX helm chart.

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
helm show chart startx/sxapi
```

### 4. Install this chart

```bash
helm install sxapi startx/sxapi
```

## Deploy this helm chart on kubernetes

### 1. Connect to your kubernetes cluster

```bash
kubectl login -t <token> <cluster-url>
```

### 2. Install the STARTX helm repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable/
```

### 3. Information about this chart

```bash
helm show chart startx/sxapi
```

### 4. Install sxapi chart

```bash
helm install sxapi startx/sxapi
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)                   |
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | sxapi     | Application name (functionnal tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### sxapi values dictionary

| Key                   | Default    | Description                                           |
| --------------------- | ---------- | ----------------------------------------------------- |
| sxapi.service.enabled | false      | Enable service for this application                   |
| sxapi.version         | 0.3.63     | Sxapi image version to run                            |
| sxapi.profile         | prod:start | Profile to run inside the container                   |
| sxapi.debug           | true       | Enable debuging of the container                      |
| sxapi.replicas        | 1          | Define the number of replicas for this sxapi instance |
| sxapi.data            | string     | Files to load into the application                    |

## Values files

### Default values file

The [values.yaml example file](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values.yaml) define a deployment with the following characteristics :

- 1 **service** named **sxapi** load balancing to pod deployed
- 1 **deployment** named **sxapi** deploying **1 pod** from version **0.3.63** sxapi image running the **prod:start** command with :
  - debug disabled
  - **/** : homepage with html content
  - **/health** : health page
  - **/info** : description of the micro-service
  - **/ping** : return a pong message
- 2 **configMap** for application instance configuration
  - **lib** : Versionned content of the sxapi configuration file and related content
  - **app** : Environment variable describing the application deployed in version _0.0.1_

```bash
# base configuration running default configuration
helm install sxapi startx/sxapi
```

### Dev values file (values-dev.yaml)

The [values-dev.yaml example file](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-dev.yaml) define a deployment with the following characteristics :

- 1 **service** named **sxapi** load balancing to pod deployed
- 1 **deployment** named **sxapi** deploying **1 pod** from version **latest** sxapi image running the **dev:start** command with :
  - debug enabled
  - **/** : homepage with html content
  - **/health** : health page
  - **/info** : description of the micro-service
  - **/ping** : return a pong message
- 2 **configMap** for application instance configuration
  - **lib** : Versionned content of the sxapi configuration file and related content
  - **app** : Environment variable describing the application deployed in version _0.0.2-devel_

```bash
# base configuration running dev configuration
helm install sxapi-dev startx/sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-dev.yaml
```

### Test values file (values-test.yaml)

The [values-test.yaml example file](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-test.yaml) define a deployment with the following characteristics :

- 1 **service** named **sxapi** load balancing to pod deployed
- 1 **deployment** named **sxapi** deploying **1 pod** from version **testing** sxapi image running the **prod:start** command with :
  - debug enabled
  - **/** : homepage with html content
  - **/health** : health page
  - **/info** : description of the micro-service
  - **/ping** : return a pong message
- 2 **configMap** for application instance configuration
  - **lib** : Versionned content of the sxapi configuration file and related content
  - **app** : Environment variable describing the application deployed in version _0.0.1-testing_

```bash
# base configuration running dev configuration
helm install sxapi-test startx/sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-test.yaml
```

### Pre-prod-v1 values file (values-pprod-v1.yaml)

The [values-pprod-v1.yaml example file](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-pprod-v1.yaml) define a deployment with the following characteristics :

- 1 **service** named **sxapi** load balancing to pod deployed
- 1 **deployment** named **sxapi** deploying **1 pod** from version **0.3.58** sxapi image running the **prod:start** command with :
  - debug disabled
  - **/** : homepage with html content
  - **/health** : health page
  - **/info** : description of the micro-service
- 2 **configMap** for application instance configuration
  - **lib** : Versionned content of the sxapi configuration file and related content
  - **app** : Environment variable describing the application deployed in version _0.0.1_

```bash
# base configuration running dev configuration
helm install sxapi-pprod-v1 startx/sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-pprod-v1.yaml
```

### Prod-v1 values file (values-prod-v1.yaml)

The [values-prod-v1.yaml example file](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-prod-v1.yaml) define a deployment with the following characteristics :

- 1 **service** named **sxapi** load balancing to pod deployed
- 1 **deployment** named **sxapi** deploying **1 pod** from version **0.3.58** sxapi image running the **prod:start** command with :
  - debug disabled
  - **/** : homepage with html content
  - **/health** : health page
  - **/info** : description of the micro-service
- 2 **configMap** for application instance configuration
  - **lib** : Versionned content of the sxapi configuration file and related content
  - **app** : Environment variable describing the application deployed in version _0.0.1_

```bash
# base configuration running dev configuration
helm install sxapi-prod-v1 startx/sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-prod-v1.yaml
```

### Pre-prod-v2 values file (values-pprod-v2.yaml)

The [values-pprod-v2.yaml example file](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-pprod-v2.yaml) define a deployment with the following characteristics :

- 1 **service** named **sxapi** load balancing to pod deployed
- 1 **deployment** named **sxapi** deploying **1 pod** from version **0.3.63** sxapi image running the **prod:start** command with :
  - debug disabled
  - **/** : homepage with html content
  - **/health** : health page
  - **/info** : description of the micro-service
  - **/ping** : return a pong message
- 2 **configMap** for application instance configuration
  - **lib** : Versionned content of the sxapi configuration file and related content
  - **app** : Environment variable describing the application deployed in version _0.0.2_

```bash
# base configuration running dev configuration
helm install sxapi-pprod-v2 startx/sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-pprod-v2.yaml
```

## History

### Version 6.x

| Release | Date       | Description                                                                                            |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 0.2.51  | 2020-10-31 | Initial commit for this chart with default and dev value examples                                      |
| 0.2.99  | 2020-10-31 | Prepare release 0.3.0                                                                                  |
| 0.3.0   | 2020-10-31 | Stable 0.3 release                                                                                     |
| 0.3.1   | 2020-11-01 | Move to go templates for notes generation and move app content to value property sxapi.data            |
| 0.3.3   | 2020-11-01 | Test new scope for note template helper                                                                |
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21                                                      |
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information |
| 0.3.51  | 2020-11-08 | Improve sxapi options                                                                                  |
| 0.3.65  | 2020-11-09 | Align sxapi to same release as basic helm chart in startx repository                                   |
| 0.3.81  | 2020-11-10 | Improve sxapi options                                                                                  |
| 0.3.119 | 2020-11-13 | Add route support with expose proerties in the values files                                            |
| 0.3.131 | 2020-11-14 | Debug route apiVersion                                                                                 |
| 0.3.135 | 2020-11-23 | Improve documentation for all examples charts                                                          |
| 0.3.141 | 2020-11-24 | publish stable update for the full repository                                                          |
| 0.3.142 | 2021-01-23 | Update for OCP 4.6.13                                                                                  |
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                                                    |
| 0.3.153 | 2021-01-23 | publish stable update for the full repository                                                          |
| 0.3.155 | 2021-01-23 | Align sxapi chart to 0.3.155 release                                                                   |
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies                                                                         |
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments                            |
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies                                                                           |
| 0.3.171 | 2021-01-24 | Align basic chart release to 0.3.171                                                                   |
| 0.3.187 | 2021-02-13 | Align basic chart release to 0.3.187                                                                   |
| 0.3.189 | 2021-02-13 | Align all basic charts to 0.3.189                                                                      |
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189                                                           |
| 0.3.193 | 2021-02-20 | Stable base helm-chart                                                                                 |
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts                                            |
| 0.3.201 | 2021-02-20 | Update icon and image for charts                                                                       |
| 0.3.203 | 2021-02-21 | Upgrade chart release informations                                                                     |
| 0.3.205 | 2021-04-19 | Align release of core charts                                                                           |
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205                                                              |
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                                                        |
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215                                                                     |
| 0.3.217 | 2021-05-10 | Align basic chart to release 0.3.217                                                                   |
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming                                                                |
| 0.3.305 | 2021-06-04 | publish stable update for the full repository                                                          |
| 0.3.343 | 2021-06-06 | publish stable update for the full repository                                                          |
| 0.3.381 | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377                           |
| 0.3.390 | 2021-06-12 | Prepare 0.4.0 release                                                                                  |
| 0.3.423 | 2021-06-17 | Prepare the v0.4 release. Stable aligned version of all charts                                         |
| 0.3.425 | 2021-07-03 | Debug route and service definitions                                                                    |
| 0.3.431 | 2021-07-05 | Move to dependencies 1.18.0                                                                            |
| 0.3.480 | 2021-08-03 | publish stable update for the full repository                                                          |
| 0.3.998 | 2021-08-04 | publish stable update for the full repository                                                          |
| 0.3.999 | 2021-08-04 | Release stable version 0.3.999 align with ocp 4.7.13                                                   |

### Version 7.x

| Release | Date       | Description                                                        |
| ------- | ---------- | ------------------------------------------------------------------ |
| 7.22.1  | 2021-08-04 | Move to release 7.22.1 to align versionning with ocp release cycle |
| 7.22.2  | 2021-08-04 | Move helm dependencies to a 7.x.x release model                    |
| 7.22.3  | 2021-08-05 | publish stable update for the full repository                      |
| 7.22.5  | 2021-08-05 | publish stable update for the full repository                      |
| 7.22.6  | 2021-08-05 | Stable version for chart dependencies                              |
| 7.22.7  | 2021-08-05 | Stable for OCP version 4.7.22                                      |
| 7.22.12 | 2021-09-23 | publish stable update for the full repository                      |
| 7.22.15 | 2021-10-05 | Align core charts to release 7.22.15                               |
| 7.22.21 | 2021-10-05 | ServiceAccount and ImagePullSecrets managed by project chart       |
| 7.22.23 | 2021-10-06 | Align basic charts to version 7.22.23                              |
| 7.22.25 | 2021-10-06 | publish stable update for the full repository                      |
| 7.22.27 | 2021-10-06 | publish stable update for the full repository                      |

### Version 8.x

| Release | Date       | Description                                                                                    |
| ------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 8.13.1  | 2021-10-06 | Stable release for OCP 4.8.13 version                                                          |
| 8.13.3  | 2021-10-08 | Improve code execution, syntax and introduce the ACS helm-chart                                |
| 8.13.5  | 2021-10-21 | publish stable update for the full repository                                                  |
| 8.13.7  | 2021-10-21 | publish stable update for the full repository                                                  |
| 8.13.8  | 2021-10-21 | Adding first draft of json schema                                                              |
| 8.13.9  | 2021-10-22 | Adding the schema in chart                                                                     |
| 8.13.9  | 2021-10-22 | Improve artfifacthub annotation                                                                |
| 8.13.10 | 2021-10-22 | Improve artfifacthub annotation                                                                |
| 8.13.13 | 2021-10-30 | Improve the values.schema.json                                                                 |
| 8.13.14 | 2021-10-31 | Adding support for LoadBalancer, NodePort and ingress external access                          |
| 8.13.15 | 2021-10-31 | Improve ci/cd workflow capactities                                                             |
| 8.13.16 | 2021-10-31 | Improve sxapi options                                                                          |
| 8.13.21 | 2021-11-01 | Align basic charts to version 8.13.21                                                          |
| 8.13.23 | 2021-11-10 | Solve helm issue in the kubeVersion for kube clusters                                          |
| 8.13.25 | 2021-11-10 | Solve helm issue in the kubeVersion for kube clusters and upgrade chart dep to version 8.13.23 |
| 8.13.27 | 2021-11-10 | publish stable update for the full repository                                                  |
| 8.20.3  | 2021-11-11 | Align all charts to Openshift version 4.8.20                                                   |
| 8.20.2  | 2021-11-11 | stable release for basic chart for Openshift version 4.8.20                                    |
| 8.20.5  | 2021-11-12 | Upgrade all appVersion and align chart release                                                 |
| 8.20.9  | 2021-11-12 | Align all startx chart to version 8.20.9                                                       |
| 0.20.11 | 2021-11-12 | Move chart dependencies to version 8.20.5                                                      |
| 0.20.33 | 2021-11-14 | publish stable update for the full repository                                                  |
| 0.20.34 | 2021-11-14 | Stable for basic chart                                                                         |
| 0.20.41 | 2021-11-14 | Aling all dependencies to version 0.20.34                                                      |
| 8.20.45 | 2021-11-19 | Stable version for sxapi chart                                                                 |
| 8.20.46 | 2021-11-19 | Transitionnal chart                                                                            |
| 8.20.55 | 2021-11-19 | Stable release for basic charts                                                                |
| 8.20.60 | 2021-11-19 | publish stable update for the full repository                                                  |
| 8.20.63 | 2021-11-20 | Updating values schema                                                                         |
| 8.20.66 | 2021-11-20 | Updating limits for context vars in values schema                                              |
| 8.20.70 | 2021-11-20 | publish stable update for the full repository                                                  |
| 8.20.71 | 2021-11-20 | Align all charts to Openshift version 4.8.21                                                   |


### Version 9.x

| Release | Date       | Description                                                                   |
| ------- | ---------- | ----------------------------------------------------------------------------- |
| 9.8.1   | 2021-11-20 | Upgrade to Openshift version 4.9.8                                            |
| 9.8.4   | 2021-11-20 | Stable release of chart for Openshift 4.9.8 version                           |
| 9.8.7   | 2021-11-20 | Debug dependencies problem                                                    |
| 9.8.8   | 2021-11-20 | Update schema limit to 30 characters for version name                         |
| 9.8.9   | 2021-11-20 | Update startx chart dependencies version to 9.8.8 and schema update           |
| 9.9.11  | 2021-11-20 | Update the context.xxx limit to 25 characters in values schema                |
| 9.8.11  | 2021-11-20 | Update the context.xxx limit to 25 characters in values schema                |
| 9.8.15  | 2021-11-20 | Update startx chart dependencies version to 9.8.11                            |
| 9.8.19  | 2021-11-20 | Update startx chart dependencies version to 9.8.15 and improve values schema  |
| 9.8.23  | 2021-11-20 | Version check in value schema support v as a prefix to the version identifier |
| 9.8.28  | 2021-11-20 | Update the startx chart dependencies to version 9.8.23                        |
| 9.8.31  | 2021-11-21 | Align with all other chart version number 9.8.31                              |
| 9.8.39  | 2021-11-21 | Debug version check with more permissive mode                                 |
| 9.8.43  | 2021-11-21 | Update the startx chart dependencies to version 9.8.39                        |
| 9.8.45  | 2021-11-21 | Update the values schema limits for context properties                        |
| 9.8.47  | 2021-11-21 | Improve version management for chart                                          |
| 9.8.48  | 2021-11-22 | Update sxapi to version 0.3.63 with many security updates                     |
| 9.8.49  | 2021-11-22 | Align with all other basic chart version to number 9.8.48 (blank release)     |
| 9.8.51  | 2021-11-22 | Update startx chart dependencies to version 9.8.48                            |
| 9.8.59  | 2021-12-18 | Improve global label management                                               |
| 9.8.67  | 2021-12-18 | Align all charts to release 9.8.67                                            |
| 9.8.69  | 2021-12-18 | Refactor label and annotation go template library                             |
| 9.8.71  | 2021-12-18 | Update helm-chart dependencies to version 9.8.59                              |
| 9.8.72  | 2021-12-19 | Remove app.kubernetes.io/name from default label                              |
| 9.8.75  | 2021-12-19 | Align with all other startx chart version to number 9.8.75                    |
| 9.8.76  | 2021-12-19 | Change helm.sh/chart name                                                     |
| 9.8.81  | 2021-12-20 | Update the storage context                                                    |
| 9.8.91  | 2022-03-06 | publish stable update for the full repository                                 |
| 9.8.93  | 2022-03-07 | Enable conditionnal loading of charts dependencies                            |
| 9.8.107 | 2022-04-26 | Upgrade startx chart dependencies to version 9.8.107                          |
| 9.8.109 | 2022-04-26 | Update startx chart dependencies to version 9.8.107                           |
| 9.8.110 | 2022-04-27 | Stable release for all charts                                                 |
| 9.8.111 | 2022-05-06 | Upgrade startx chart dependencies to version 9.8.111                          |
| 9.8.211 | 2022-05-06 | Upgrade startx chart dependencies to version 9.8.211                          |
| 9.8.215 | 2022-05-06 | Upgrade startx chart dependencies to version 9.8.211                          |
| 9.8.230 | 2022-05-06 | Stable full repository                                                        |
| 9.8.231 | 2022-05-06 | Debug basic chart dependencies                                                |
| 9.8.233 | 2022-05-06 | publish stable update for the full repository                                 |
| 9.8.234 | 2022-05-17 | Align chart release to version 9.8.234                                        |
| 9.8.239 | 2022-05-17 | Remove default csv from all charts. global release 9.8.239                    |
| 9.8.251 | 2022-05-29 | Align basic charts to release 9.8.251                                         |
| 9.8.253 | 2022-05-29 | Align all charts dependencies to release 9.8.251                              |
| 9.8.277 | 2022-05-31 | publish stable update for the full repository                                 |
| 9.8.278 | 2022-05-31 | Improve sxapi options                                                         |
| 9.15.1  | 2022-06-01 | Align all chart for Openshift 4.9.15                                          |
| 9.15.2  | 2022-06-01 | Align all charts to release 9.15.1                                            |
| 9.15.3  | 2022-06-01 | Align all charts to release 9.15.3                                            |


### Version 10.x

| Release  | Date       | Description                                         |
| -------- | ---------- | --------------------------------------------------- |
| 10.12.1  | 2022-06-01 | Align all charts to release 10.12.1                 |
| 10.12.3  | 2022-06-01 | publish stable update for the full repository       |
| 10.12.4  | 2022-06-01 | Align all charts to release 10.12.4                 |
| 10.12.5  | 2022-06-01 | publish stable update for the full repository       |
| 10.12.22 | 2022-06-04 | Align all chart to release version 10.12.22         |
| 10.12.23 | 2022-06-04 | Basi chart dependencies upgraded to version 10.12.5 |
| 10.12.29 | 2022-06-17 | publish stable update for the full repository       |
| 10.12.30 | 2022-06-17 | Improved logo and global documentation              |
| 10.12.31 | 2022-06-17 | align basic charts                                  |
| 10.12.33 | 2022-06-17 | publish stable update for the full repository       |
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31           |
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41                |
| 10.12.46 | 2022-06-18 | publish stable update for the full repository       |
| 10.12.49 | 2022-06-18 | publish stable update for the full repository       |
| 10.12.53 | 2022-06-18 | publish stable update for the full repository       |
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts                  |
| 10.12.72 | 2022-07-02 | Common release                                      |
| 10.12.77 | 2022-07-02 | Stable for clients                                  |
| 10.12.81 | 2022-07-02 | publish stable update for the full repository       |
| 10.12.97 | 2022-07-03 | publish stable update for the full repository       |
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart            |


### Version 11.x

| Release   | Date       | Description                                                      |
| --------- | ---------- | ---------------------------------------------------------------- |
| 11.5.3    | 2022-09-17 | Align all STARTX charts to release 11.5.3                        |
| 11.5.5    | 2022-09-17 | Released but must be tested release                              |
| 11.7.1    | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release |
| 11.7.3    | 2022-10-02 | publish stable update for the full repository                    |
| 11.7.9    | 2022-10-02 | publish stable update for the full repository                    |
| 11.7.10   | 2022-10-02 | Stable release for all packages                                  |
| 11.7.11   | 2022-10-02 | publish stable update for the full repository                    |
| 11.7.15   | 2022-10-02 | publish stable update for the full repository                    |
| 11.7.17   | 2022-10-02 | publish stable update for the full repository                    |
| 11.7.31   | 2022-10-29 | publish stable update for the full repository                    |
| 11.7.33   | 2022-10-29 | Update all startx packages to release 11.7.33                    |
| 11.7.41   | 2022-11-02 | publish stable update for the full repository                    |
| 11.7.61   | 2022-11-30 | publish stable update for the full repository                    |
| 11.7.62   | 2022-11-30 | Debug console links and notifications                            |
| 11.7.63   | 2022-11-30 | publish stable update for the full repository                    |
| 11.7.67   | 2022-11-30 | Debug depedencies on sub charts                                  |
| 11.7.69   | 2022-11-30 | Finished dependencies stabilization                              |
| 11.7.73   | 2022-12-04 | Align all packages to release 11.7.73                            |
| 11.7.75   | 2022-12-04 | publish stable update for the full repository                    |
| 11.7.77   | 2022-12-05 | publish stable update for the full repository                    |
| 11.7.87   | 2023-02-15 | publish stable update for the full repository                    |
| 11.7.88   | 2023-02-15 | publish stable update for the full repository                    |
| 11.7.89   | 2023-02-16 | Align basic charts to version 11.7.89                            |
| 11.7.91   | 2023-02-16 | publish stable update for the full repository                    |
| 11.7.93   | 2023-02-16 | align dependencies to version 11.7.89                            |
| 11.7.97   | 2023-02-19 | publish stable update for the full repository                    |
| 11.28.1   | 2023-02-19 | Improve sxapi options                                            |
| 11.28.7   | 2023-02-19 | Align all packages to release 11.28.7                            |
| 11.28.11  | 2023-02-19 | publish stable update for the full repository                    |
| 11.28.15  | 2023-02-19 | publish stable update for the full repository                    |
| 11.28.16  | 2023-02-19 | publish stable update for the full repository                    |
| 11.28.19  | 2023-02-19 | publish stable update for the full repository                    |
| 11.28.21  | 2023-02-19 | Upgrade all dependencies packages to release 11.28.15            |
| 11.28.23  | 2023-02-21 | publish stable update for the full repository                    |
| 11.28.25  | 2023-02-21 | Align basic chart packages to release 11.28.25                   |
| 11.28.27  | 2023-02-21 | All chart aligned to release 11.28.27                            |
| 11.28.29  | 2023-02-21 | publish stable update for the full repository                    |
| 11.28.35  | 2023-02-21 | publish stable update for the full repository                    |
| 11.28.49  | 2023-02-21 | publish stable update for the full repository                    |
| 11.28.59  | 2023-02-21 | publish stable update for the full repository                    |
| 11.28.60  | 2023-02-21 | publish stable update for the full repository                    |
| 11.28.67  | 2023-02-23 | publish stable update for the full repository                    |
| 11.28.69  | 2023-03-07 | publish stable update for the full repository                    |
| 11.28.89  | 2023-04-01 | publish stable update for the full repository                    |
| 11.28.93  | 2023-04-20 | publish stable update for the full repository                    |
| 11.28.99  | 2023-04-21 | publish stable update for the full repository                    |
| 11.28.103 | 2023-05-04 | publish stable update for the full repository                    |
| 11.28.127 | 2023-06-12 | publish stable update for the full repository                    |
| 11.28.128 | 2023-06-12 | publish stable update for the full repository                    |
| 11.28.129 | 2023-06-13 | publish stable update for the full repository                    |
| 11.28.201 | 2023-07-06 | publish stable update for the full repository                    |
| 11.28.207 | 2023-07-06 | publish stable update for the full repository                    |
| 11.28.230 | 2023-08-18 | Align all helm chart to release 11.28.230 stable release         |
| 11.30.0   | 2023-08-18 | Align all helm chart to release 11.30.0 stable for OCP 4.11.30   |
| 11.40.0   | 2023-08-18 | Align all helm chart to release 11.40.0 stable for OCP 4.11.40   |
| 11.47.0   | 2023-08-18 | Align all helm chart to release 11.47.0 stable for OCP 4.11.47   |
| 11.47.1   | 2023-08-18 | Update appVersion in Chart.yml                                   |


### Version 12.x

| Release  | Date       | Description                                                                           |
| -------- | ---------- | ------------------------------------------------------------------------------------- |
| 12.0.0   | 2023-08-18 | Align all helm chart to release 12.0.0 transitionnal for OCP 4.12.0 target (unstable) |
| 12.0.1   | 2023-08-18 | Align all helm chart to release 12.0.1 transitionnal for OCP 4.12.0 target (unstable) |
| 12.0.5   | 2023-08-18 | publish stable update for the full repository                                         |
| 12.0.11  | 2023-08-18 | publish stable update for the full repository                                         |
| 12.30.1  | 2023-09-29 | release 12.30.1 aligned and tested with OCP 4.12.30                                   |
| 12.36.1  | 2023-09-29 | release 12.36.0 aligned with OCP 4.12.36 (unstable)                                   |
| 12.36.9  | 2023-10-01 | publish stable update for the full repository                                         |
| 12.36.36 | 2023-10-11 | publish stable update for the full repository                                         |
| 12.36.49 | 2023-11-13 | publish stable update for the full repository                                         |
| 12.36.51 | 2023-11-13 | publish stable update for the full repository                                         |
| 12.36.58 | 2023-11-13 | Align all startx dependencies packages to version 12.36.49 stable for OCP 4.12.36     |
| 12.36.59 | 2023-11-13 | publish stable update for the full repository                                         |
| 12.36.63 | 2023-11-13 | publish stable update for the full repository                                         |
| 12.36.64 | 2023-11-13 | publish stable update for the full repository                                         |
| 12.36.65 | 2023-11-14 | publish stable update for the full repository                                         |
| 12.36.66 | 2023-11-14 | Update trunc to 255 for helper                                                        |
| 12.36.69 | 2023-11-14 | move dependencies to version 12.36.65                                                 |
| 12.45.0  | 2023-12-08 | Stable version aligned to Openshift version 4.12.45                                   |


### Version 13.x

| Release | Date       | Description                                                                                                             |
| ------- | ---------- | ----------------------------------------------------------------------------------------------------------------------- |
| 13.26.0 | 2023-12-08 | Unstable version aligned to Openshift version 4.13.26 to prepare the 13.26.x stable release (short lived)               |
| 13.26.1 | 2023-12-09 | Minimum requirements for kubernetes is 1.26.0 version and upgrade all cluster-xxx charts to latest release for OCP 4.13 |
| 13.26.2 | 2023-12-09 | upgrade all dependencies charts to version 13.26.0                                                                      |
| 13.26.3 | 2023-12-09 | publish stable update for the full repository                                                                           |


### Version 14.x

| Release  | Date       | Description                                                                                |
| -------- | ---------- | ------------------------------------------------------------------------------------------ |
| 14.6.1   | 2023-12-09 | iniFirst release for OCP 4.14 release. Aligned on 4.14.6 release                           |
| 14.6.5   | 2023-12-10 | upgrade all dependencies charts to version 13.26.2                                         |
| 14.6.9   | 2023-12-10 | publish stable update for the full repository                                              |
| 14.6.11  | 2023-12-10 | upgrade minimum kubeVersion to 1.27.x and startx helm-chart dependencies to version 14.6.5 |
| 14.6.15  | 2023-12-11 | update packages for OCP 4.14.6                                                             |
| 14.6.21  | 2023-12-18 | publish stable update for the full repository                                              |
| 14.6.22  | 2023-12-18 | stable si good                                                                             |
| 14.6.27  | 2023-12-19 | publish stable update for the full repository                                              |
| 14.6.29  | 2023-12-19 | publish stable update for the full repository                                              |
| 14.6.31  | 2023-12-19 | move to kubeversion min 1.25.0                                                             |
| 14.6.33  | 2023-12-19 | Move dependencies to github-pages                                                          |
| 14.6.35  | 2023-12-20 | publish stable update for the full repository                                              |
| 14.6.39  | 2023-12-22 | align basic chart on 14.6.39 release                                                       |
| 14.6.40  | 2023-12-22 | align basic operators                                                                      |
| 14.6.45  | 2023-12-22 | publish stable update for the full repository                                              |
| 14.6.46  | 2023-12-22 | publish stable update for the full repository                                              |
| 14.6.55  | 2023-12-22 | align all dependencies chart to 14.6.45                                                    |
| 14.6.59  | 2023-12-22 | move back dependencies to version 14.6.35                                                  |
| 14.6.63  | 2023-12-22 | Align all startx helm-chart to version 14.6.63                                             |
| 14.6.65  | 2023-12-27 | test with repo stored in s3 public bucket                                                  |
| 14.6.71  | 2023-12-28 | Move to S3 helm repository                                                                 |
| 14.6.73  | 2023-12-29 | Upgrade all startx chart dependencies to version 14.6.65                                   |
| 14.6.75  | 2023-12-29 | Upgrade all startx chart dependencies to version 14.6.71                                   |
| 14.6.91  | 2024-01-02 | publish stable update for the full repository                                              |
| 14.6.99  | 2024-01-02 | Full stable release of the chart repository                                                |
| 14.6.103 | 2024-01-03 | Upgrade all startx chart dependencies to version 14.6.75                                   |
| 14.6.105 | 2024-01-03 | publish stable update for the full repository                                              |
| 14.6.107 | 2024-01-04 | publish stable update for the full repository                                              |
| 14.6.109 | 2024-01-04 | Update all chart dependencies to version 14.6.105                                          |
| 14.6.111 | 2024-01-18 | align basic chart to 14.6.111 version because of the operator chart update
| 14.6.131 | 2024-01-18 | publish stable update for the full repository
| 14.6.133 | 2024-01-18 | Update the documentation with artifacthub badge
| 14.6.135 | 2024-01-18 | debug artifacthub recommandations
| 14.6.137 | 2024-01-18 | publish stable update for the full repository
| 14.6.139 | 2024-02-03 | Align to 14.6.139 basic chart release
| 14.6.141 | 2024-02-03 | upgrade of the full startx repository
| 14.6.143 | 2024-02-03 | Align to 14.6.143 chart release
| 14.6.149 | 2024-02-03 | Update all startx dependencies chart to 14.6.141 chart release
| 14.6.150 | 2024-02-03 | Stable 14.6.150 release
| 14.6.161 | 2024-02-08 | publish stable update for the full repository
| 14.6.171 | 2024-02-08 | publish stable update for the full repository
| 14.6.179 | 2024-02-08 | Align all basic chart to release 14.6.179
| 14.6.187 | 2024-02-08 | Disable default example additional labels and annotations
| 14.6.189 | 2024-02-08 | publish stable update for the full repository
| 14.6.191 | 2024-02-08 | Improve sxapi options
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
| 14.6.310 | 2024-06-25 | Align all basic chart to release 14.6.310
| 14.6.321 | 2024-06-25 | publish stable update for the full repository
| 14.6.323 | 2024-06-25 | Align all chart to latest release
| 14.6.325 | 2024-06-25 | publish stable update for the full repository
| 14.6.331 | 2024-06-25 | update all dependencies to version 14.6.323
| 14.6.335 | 2024-06-26 | publish stable update for the full repository
| 14.6.339 | 2024-06-26 | Align basic chart release
| 14.6.343 | 2024-06-26 | publish stable update for the full repository
| 14.6.345 | 2024-06-26 | publish stable update for the full repository
| 14.6.351 | 2024-06-26 | Update all dependencies
| 14.6.353 | 2024-06-26 | Fixed missed dependencies in previous release
| 14.6.367 | 2024-06-29 | Align all startx charts to release 14.6.367
| 14.6.381 | 2024-06-30 | Align all startx charts to release 14.6.381
| 15.27.3 | 2024-11-06 | create init release for version 15.x
| 15.27.5 | 2024-11-06 | publish stable update for the full repository
| 15.27.7 | 2024-11-06 | Align all startx charts dependencies to release 15.27.3
| 15.27.8 | 2024-11-08 | Align all basic charts to release 15.27.8
| 15.27.17 | 2024-11-10 | Release aligned for OCP 4.15.27
| 15.27.21 | 2024-11-10 | Release aligned for OCP 4.15.37
| 16.19.3 | 2024-11-10 | Init release 16.19.1 aligned for OCP 4.16.19
| 16.19.4 | 2024-11-10 | stable basic charts to prepare dependencies
| 16.19.11 | 2024-11-10 | Update all dependencies to version 16.19.4
| 16.19.15 | 2024-11-10 | publish stable update for the full repository
| 16.19.29 | 2024-11-11 | Align all chart to the 16.19.29 release
| 16.19.31 | 2024-12-10 | Align all charts to 19.19.31
| 16.19.43 | 2025-02-27 | publish stable update for the full repository
| 17.14.1 | 2025-02-28 | Initial release for v17.x version
| 17.14.3 | 2025-02-28 | Temporary release used to prepare dependencies changes
| 17.14.5 | 2025-02-28 | Align all startx helm dependencies to release 17.14.1
| 17.14.11 | 2025-03-05 | Adjust doc to material layout
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version
| 18.11.1 | 2025-04-30 | first release of the basic operators
| 18.11.3 | 2025-04-30 | Prepare dependencies move to version 18.x
| 18.11.5 | 2025-04-30 | move dependencies to version 18.11.1
| 18.11.7 | 2025-04-30 | All dependencies linked to 18.x release
| 18.11.8 | 2025-05-02 | Align to version 18.11.8 for basic charts
| 18.11.15 | 2025-05-02 | Intermediate common release for basic charts
| 18.11.19 | 2025-05-02 | Intermediate alignement of all helm charts
| 18.11.21 | 2025-05-02 | Update all basic chart dependencies to version 18.11.15
| 18.11.22 | 2025-05-02 | Add noinfra values in all charts
| 18.11.24 | 2025-05-02 | Align all to stable version
| 18.11.31 | 2025-05-03 | update all dependencies to version 18.11.19
| 18.11.39 | 2025-05-05 | Update icon with startx new theme
| 18.11.51 | 2025-05-06 | publish stable update for the full repository
| 18.11.52 | 2025-05-07 | publish stable update for the full repository
| 18.11.60 | 2025-05-14 | Align all chart to a stable release for OCP 4.18

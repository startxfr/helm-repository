# Example sxapi

This helm chart is used to create a deployment of a small an simple micro-service based on [sxapi helm chart](https://startxfr.github.io/helm-repository/charts/sxapi)

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/example-sxapi
```

### 4. Install this chart

```bash
helm install startx/example-sxapi
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

### example-sxapi values dictionary

| Key                   | Default    | Description                                           |
| --------------------- | ---------- | ----------------------------------------------------- |
| sxapi.service.enabled | false      | Enable service for this application                   |
| sxapi.version         | 0.3.57     | Sxapi image version to run                            |
| sxapi.profile         | prod:start | Profile to run inside the container                   |
| sxapi.debug           | true       | Enable debuging of the container                      |
| sxapi.replicas        | 1          | Define the number of replicas for this sxapi instance |
| sxapi.data            | string     | Files to load into the application                    |

## Values files

### Default values file (values.yaml)

Complete deployment of an sxapi application with the following characteristics :

- 1 **service** named **example-sxapi** load balancing to pod deployed
- 1 **deployment** named **example-sxapi** deploying **1 pod** from version **0.3.57** sxapi image running the **prod:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running default configuration
helm install startx/example-sxapi
```

### Development values file (values-dev.yaml)

Complete deployment of a sxapi development application with the following characteristics :

- 1 **service** named **example-sxapi-dev** load balancing to pod deployed
- 1 **deployment** named **example-sxapi-dev** deploying **1 pod** from version **0.3.57** sxapi image running the **dev:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-dev.yaml
```

### Version 0.0.1 values file (values-v0.0.1.yaml)

Complete deployment of a sxapi production application (v0.0.1) with the following characteristics :

- 1 **service** named **example-sxapi-prod** load balancing to pod deployed
- 1 **deployment** named **example-sxapi-prod** deploying **1 pod** from version **0.3.52** sxapi image running the **prod:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-v0.0.1.yaml
```

### Version 0.0.2 values file (values-v0.0.2.yaml)

Complete deployment of a sxapi production application (v0.0.2) with the following characteristics :

- 1 **service** named **example-sxapi-prod** load balancing to pod deployed
- 1 **deployment** named **example-sxapi-prod** deploying **1 pod** from version **0.3.57** sxapi image running the **prod:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-v0.0.2.yaml
```

## History

| Release | Date       | Description                                                                                            |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 0.2.11  | 2020-10-25 | Initial commit for this helm chart with default value example                                          |
| 0.3.0   | 2020-10-31 | Stable 0.3 release                                                                                     |
| 0.3.3   | 2020-11-01 | Update sxapi chart dependency to 0.3.1 and moving application data to value file                       |
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21                                                      |
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information |
| 0.3.93  | 2020-11-10 | Move to 0.3.93 dependencies for all cluster-xxx charts in the startx repository                        |
| 0.3.105 | 2020-11-11 | Update cluster-xxx charts dependencies to 0.3.103 release                                              |
| 0.3.117 | 2020-11-12 | Move to 0.3.115 basic chart dependencies                                                               |
| 0.3.135 | 2020-11-23 | Improve documentation for all examples charts                                                          |
| 0.3.141 | 2020-11-24 | publish stable update for the full repository                                                          |
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                                                    |
| 0.3.153 | 2021-01-23 | publish stable update for the full repository                                                          |
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies                                                                         |
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments                            |
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies                                                                           |
| 0.3.173 | 2021-01-24 | Move all dependencies to 0.3.171 and improve cluster-logging component                                 |
| 0.3.187 | 2021-02-13 | Align example chart release to 0.3.187                                                                 |
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189                                                           |
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts                                            |
| 0.3.201 | 2021-02-20 | Update icon and image for charts                                                                       |
| 0.3.203 | 2021-02-21 | Upgrade chart release informations                                                                     |
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205                                                              |
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                                                        |
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215                                                                     |
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming                                                                |
| 0.3.227 | 2021-05-29 | Debug naming of config map                                                                             |
| 0.3.305 | 2021-06-04 | publish stable update for the full repository                                                          |
| 0.3.343 | 2021-06-06 | publish stable update for the full repository                                                          |
| 0.3.381 | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377                           |
| 0.3.390 | 2021-06-12 | Prepare 0.4.0 release
| 0.3.423 | 2021-06-17 | Prepare the v0.4 release. Stable aligned version of all charts
| 0.3.431 | 2021-07-05 | Move to dependencies 1.18.0

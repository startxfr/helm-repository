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
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | sxapi     | Application name (functional tenant, default use Chart name)                     |
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

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `sxapi` using a single ArgoCD Application sharing a dedicated AppProject.
The chart deploys a lightweight nodejs micro-service into the target namespace:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/sxapi/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles the microservice whenever the chart or values drift from the desired state.

## History

### Version 6.x

| Release | Date       | Description                                                                                            |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------ |
### Version 7.x

| Release | Date       | Description                                                        |
| ------- | ---------- | ------------------------------------------------------------------ |
### Version 8.x

| Release | Date       | Description                                                                                    |
| ------- | ---------- | ---------------------------------------------------------------------------------------------- |
### Version 9.x

| Release | Date       | Description                                                                   |
| ------- | ---------- | ----------------------------------------------------------------------------- |
### Version 10.x

| Release  | Date       | Description                                         |
| -------- | ---------- | --------------------------------------------------- |
### Version 11.x

| Release   | Date       | Description                                                      |
| --------- | ---------- | ---------------------------------------------------------------- |
### Version 12.x

| Release  | Date       | Description                                                                           |
| -------- | ---------- | ------------------------------------------------------------------------------------- |
### Version 13.x

| Release | Date       | Description                                                                                                             |
| ------- | ---------- | ----------------------------------------------------------------------------------------------------------------------- |
### Version 14.x

| Release  | Date       | Description                                                                                |
| -------- | ---------- | ------------------------------------------------------------------------------------------ |
| 16.19.43 | 2025-02-27 | publish stable update for the full repository |
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
| 21.3.21 | 2026-06-19 | release basic version |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.70 | 2026-06-20 | Improve doc and argocd examples |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.69 | 2026-06-20 | Improve sxapi options |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |

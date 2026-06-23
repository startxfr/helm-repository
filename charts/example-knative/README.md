# ![example-knative](https://helm-repository.readthedocs.io/en/latest/img/example-knative.svg "Example Chart : KNative") Example Chart : KNative
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_example--knative-E28A2B.svg)](https://artifacthub.io/packages/search?ts_query_web=example+knative+startx)

This helm chart is used to create various serverless application based on [knative helm chart](https://helm-repository.readthedocs.io/en/latest/charts/cluster-knative/).

This chart is part of the [example-xxx startx helm chart series](https://helm-repository.readthedocs.io#examples-helm-charts) focused on deploying various kind of application consuming the cluster services deployed using the [cluster-xxx charts](https://helm-repository.readthedocs.io#cluster-helm-charts).

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
helm show chart startx/example-knative
```

### 4. Install this chart

```bash
helm install example-knative startx/example-knative
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | knative   | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### example-knative values dictionary

| Key                     | Default    | Description                                             |
| ----------------------- | ---------- | ------------------------------------------------------- |
| knative.service.enabled | false      | Enable service for this application                     |
| knative.version         | 0.3.63     | Sxapi image version to run                              |
| knative.profile         | prod:start | Profile to run inside the container                     |
| knative.debug           | true       | Enable debuging of the container                        |
| knative.replicas        | 1          | Define the number of replicas for this knative instance |
| knative.data            | string     | Files to load into the application                      |

## Values files

### Default values file (values.yaml)

Serverless service with the following characteristics (deployment is disable) :

- 1 **knative service** named **webserver** in namespace **default** deploying image **quay.io/startx/php:latest** with restricted resources

```bash
# base configuration running default configuration
helm install example-knative startx/example-knative
```

### Development values file (values-demo-sxapi-knative.yaml)

Complete deployment of a knative development application with the following characteristics :

- 1 **knative service** named **example-sxapi-knative** in namespace **demo-sxapi** deploying image **startx/sxapi:latest** with restricted resources and debug enabled

```bash
# base configuration running  demo sxapi with a knative configuration
helm install example-knative-sxapi startx/example-knative -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-knative/values-demo-sxapi-knative.yaml
```

### Development values file (values-demo-knative-helloworld-go.yaml)

Complete deployment of a knative development application with the following characteristics :

- 1 **knative service** named **example-helloworld-go** in namespace **demo-knative** deploying image **gcr.io/knative-samples/helloworld-go** with restricted resources

```bash
# base configuration running  demo sxapi with a knative configuration
helm install example-knative-helloworld-go startx/example-knative -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-knative/values-demo-knative-helloworld-go.yaml
```

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
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
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |
| 21.3.167 | 2026-06-23 | publish stable update for the full repository |
| 21.3.181 | 2026-06-23 | publish stable update for the full repository |

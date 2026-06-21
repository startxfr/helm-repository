# ![sxapi](https://helm-repository.readthedocs.io/en/latest/img/example-sxapi.svg "Example Chart : SXAPI") Example Chart : SXAPI
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_example--sxapi-E28A2B.svg)](https://artifacthub.io/packages/search?ts_query_web=example+sxapi+startx)

This helm chart is used to create a deployment of a small an simple micro-service based on [sxapi helm chart](https://helm-repository.readthedocs.io/en/latest/charts/sxapi).

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
helm show chart startx/example-sxapi
```

### 4. Install this chart

```bash
helm install example-sxapi startx/example-sxapi
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

### example-sxapi values dictionary

| Key                   | Default    | Description                                           |
| --------------------- | ---------- | ----------------------------------------------------- |
| sxapi.service.enabled | false      | Enable service for this application                   |
| sxapi.version         | 0.3.63     | Sxapi image version to run                            |
| sxapi.profile         | prod:start | Profile to run inside the container                   |
| sxapi.debug           | true       | Enable debuging of the container                      |
| sxapi.replicas        | 1          | Define the number of replicas for this sxapi instance |
| sxapi.data            | string     | Files to load into the application                    |

## Values files

### Default values file (values.yaml)

Complete deployment of an sxapi application with the following characteristics :

- 1 **service** named **example-sxapi** load balancing to pod deployed
- 1 **deployment** named **example-sxapi** deploying **1 pod** from version **0.3.63** sxapi image running the **prod:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running default configuration
helm install example-sxapi startx/example-sxapi
```

### Development values file (values-dev.yaml)

Complete deployment of a sxapi development application with the following characteristics :

- 1 **service** named **example-sxapi-dev** load balancing to pod deployed
- 1 **deployment** named **example-sxapi-dev** deploying **1 pod** from version **0.3.63** sxapi image running the **dev:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install example-sxapi-dev startx/example-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-dev.yaml
```

### Version 0.0.1 values file (values-v0.0.1.yaml)

Complete deployment of a sxapi production application (v0.0.1) with the following characteristics :

- 1 **service** named **example-sxapi-prod** load balancing to pod deployed
- 1 **deployment** named **example-sxapi-prod** deploying **1 pod** from version **0.3.63** sxapi image running the **prod:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running tekton v0.0.1 configuration
helm install example-sxapi-v0.0.1 startx/example-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-v0.0.1.yaml
```

### Version 0.0.2 values file (values-v0.0.2.yaml)

Complete deployment of a sxapi production application (v0.0.2) with the following characteristics :

- 1 **service** named **example-sxapi-prod** load balancing to pod deployed
- 1 **deployment** named **example-sxapi-prod** deploying **1 pod** from version **0.3.63** sxapi image running the **prod:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running tekton v0.0.2 configuration
helm install example-sxapi-v0.0.2 startx/example-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-v0.0.2.yaml
```

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
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
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |

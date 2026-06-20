# ![example-chaos](https://helm-repository.readthedocs.io/en/latest/img/example-chaos.svg "Example Chart : Chaos") Example Chart : Chaos
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_example--chaos-E28A2B.svg)](https://artifacthub.io/packages/search?ts_query_web=example+chaos+startx)

This helm chart is used to deploy a chaos testing suit composed of chaos mesh and kraken test suite.

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
helm show chart startx/example-chaos
```

### 4. Install this chart

```bash
helm install example-chaos startx/example-chaos
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | example-chaos     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### example-chaos values dictionary

| Key      | Default       | Description                                                      |
| -------- | ------------- | ---------------------------------------------------------------- |
| image    | fedora:latest | Image to run into the pod                                        |
| command  | /bin/sx       | Command to run inside the container                              |
| args     | run           | argunments to pass to the command exectuted inside the container |
| debug    | true          | Enable debuging of the container                                 |
| replicas | 1             | Define the number of replicas for this sxapi instance            |

## Values files

### Default values file (values.yaml)

Simple chaos of a container image with the following characteristics :

- 1 **chaos** named **example-chaos** of **1 pod** running **quay.io/startx/fedora:latest** image
- 1 **service** named **example-chaos**

```bash
# base configuration running default configuration
helm install example-chaos startx/example-chaos
```

### Demo values file (values-demo.yaml)

chaos of an demo container image with the following characteristics :

- 1 **pod** named **demo-helm-chaos** of **2 pods** running **quay.io/startx/apache:latest** image
- 1 **service** named **demo-helm-chaos**

```bash
# Configuration running demo example configuration
helm install example-chaos startx/example-chaos -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-demo.yaml
```

### Apache values file (values-apache.yaml)

chaos of an apache container image with the following characteristics :

- 1 **pod** named **example-chaos-apache** of **2 pods** running **quay.io/startx/apache:latest** image
- 1 **service** named **example-chaos-apache**

```bash
# Configuration running apache example configuration
helm install example-chaos startx/example-chaos -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-apache.yaml
```

### MariaDB values file (values-mariadb.yaml)

chaos of an mariadb container image with the following characteristics :

- 1 **pod** named **example-chaos-mariadb** of **2 pods** running **quay.io/startx/mariadb:latest** image
- 1 **service** named **example-chaos-mariadb**

```bash
# Configuration running mariadb example configuration
helm install example-chaos startx/example-chaos -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-mariadb.yaml
```

## History

| Release  | Date       | Description                                                             |
| -------- | ---------- | ----------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
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

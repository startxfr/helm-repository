# Example chaos

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
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
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
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)                   |
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | sxapi     | Application name (functionnal tenant, default use Chart name)                     |
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

| Release | Date       | Description                                                                                            |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 10.12.5 | 2022-06-03 | Initial commit for this helm chart with default value example
| 10.12.6 | 2022-06-03 | Create first release of chaos
| 10.12.7 | 2022-06-03 | Stable version with startx values
| 10.12.8 | 2022-06-04 | dding the kraken.ci and mesh
| 10.12.9 | 2022-06-04 | Improve example-chaos options
| 10.13.0 | 2022-06-04 | Improved SCC
| 10.12.22 | 2022-06-04 | Align all chart to release version 10.12.22
| 10.12.23 | 2022-06-04 | Basi chart dependencies upgraded to version 10.12.5
| 10.12.24 | 2022-06-05 | Add litmus and monkey support
| 10.12.25 | 2022-06-05 | Update kubemonkey to version 1.4.1 with v1 support for rbac api
| 10.12.6 | 2022-06-11 | Move kraken to krkn with pipeline and job support. Add cerberus support
| 10.12.7 | 2022-06-11 | Improve example-chaos options
| 10.12.8 | 2022-06-11 | debug project dependencies
| 10.12.29 | 2022-06-17 | Align all charts to version 10.12.29
| 10.12.29 | 2022-06-17 | publish stable update for the full repository
| 10.12.30 | 2022-06-17 | Improved logo and global documentation
| 10.12.33 | 2022-06-17 | publish stable update for the full repository
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41
| 10.12.46 | 2022-06-18 | publish stable update for the full repository
| 10.12.49 | 2022-06-18 | publish stable update for the full repository
| 10.12.53 | 2022-06-18 | publish stable update for the full repository
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts
| 10.12.72 | 2022-07-02 | Common release
| 10.12.77 | 2022-07-02 | Stable for clients
| 10.12.81 | 2022-07-02 | publish stable update for the full repository
| 10.12.97 | 2022-07-03 | publish stable update for the full repository
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart
| 11.5.3 | 2022-09-17 | Align all STARTX charts to release 11.5.3
| 11.7.1 | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release
| 11.7.3 | 2022-10-02 | publish stable update for the full repository
| 11.7.4 | 2022-10-02 | publish stable update for the full repository
| 11.7.5 | 2022-10-02 | publish stable update for the full repository
| 11.7.9 | 2022-10-02 | publish stable update for the full repository

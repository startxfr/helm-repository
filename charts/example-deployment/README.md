# Example deployment

This helm chart is used to create a deployment of various application images according to the values file.

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
helm show chart startx/example-deployment
```

### 4. Install this chart

```bash
helm install startx/example-deployment
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description
| ------------------- | --------- | -----------------------------------------------------
| context.scope       | default   | Name of the global scope for this application (organisational tenant)
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod)
| context.component   | demo      | Component name of this application (logical tenant)
| context.app         | sxapi     | Application name (functionnal tenant, default use Chart name)
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)

### example-deployment values dictionary

| Key       | Default       | Description
| --------- | ------------- | -----------------------------------------------------
| image     | fedora:latest | Image to run into the pod
| command   | /bin/sx       | Command to run inside the container
| args      | run           | argunments to pass to the command exectuted inside the container
| debug     | true          | Enable debuging of the container
| replicas  | 1             | Define the number of replicas for this sxapi instance

## Values files

### Default values file (values.yaml)

Simple deployment of a container image with the following characteristics :

- 1 **deployment** named **example-deployment** of **1 pod** running **quay.io/startx/fedora:latest** image
- 1 **service** named **example-deployment**

```bash
# base configuration running default configuration
helm install startx/example-deployment
```

### Demo values file (values-demo.yaml)

Deployment of an demo container image with the following characteristics :

- 1 **pod** named **demo-helm-deployment** of **2 pods**  running **quay.io/startx/apache:latest** image
- 1 **service** named **demo-helm-deployment**

```bash
# Configuration running demo example configuration
helm install startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-demo.yaml
```

### Apache values file (values-apache.yaml)

Deployment of an apache container image with the following characteristics :

- 1 **pod** named **example-deployment-apache** of **2 pods**  running **quay.io/startx/apache:latest** image
- 1 **service** named **example-deployment-apache**

```bash
# Configuration running apache example configuration
helm install startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-apache.yaml
```

### MariaDB values file (values-mariadb.yaml)

Deployment of an mariadb container image with the following characteristics :

- 1 **pod** named **example-deployment-mariadb** of **2 pods**  running **quay.io/startx/mariadb:latest** image
- 1 **service** named **example-deployment-mariadb**

```bash
# Configuration running mariadb example configuration
helm install startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-mariadb.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.0.1   | 2020-09-14 | Initial commit for this helm chart with default value example (removed)
| 0.1.22  | 2020-10-23 | Improve documentation for example-deployment (removed)
| 0.2.11  | 2020-10-25 | publish stable update for the full repository
| 0.2.34  | 2020-10-30 | Update note and chart description
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.93  | 2020-11-10 | Move to 0.3.93 dependencies for all cluster-xxx charts in the startx repository
| 0.3.105 | 2020-11-11 | Update cluster-xxx charts dependencies to 0.3.103 release
| 0.3.117 | 2020-11-12 | Move to 0.3.115 basic chart dependencies
| 0.3.135 | 2020-11-23 | Improve documentation for all examples charts
| 0.3.141 | 2020-11-24 | publish stable update for the full repository
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13
| 0.3.153 | 2021-01-23 | publish stable update for the full repository
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies
| 0.3.187 | 2021-02-13 | Align example chart release to 0.3.187
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts
| 0.3.201 | 2021-02-20 | Update icon and image for charts
| 0.3.203 | 2021-02-21 | Upgrade chart release informations
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming
| 0.3.303 | 2021-06-02 | Update documentation and align all charts to release 0.3.303
| 0.3.311 | 2021-06-03 | Align example chart to 0.3.311
| 0.3.305 | 2021-06-04 | publish stable update for the full repository

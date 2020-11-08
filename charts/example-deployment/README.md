# STARTX helm : example-deployment

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
| 0.3.33  | 2020-11-07 | publish stable update for the full repository
| 0.3.34  | 2020-11-08 | Improve example-deployment options

# Example deployment

This helm chart is used to deploya postgresql database ready to use for the fruitapp demo.

This chart is part of the [example-fruitapp-xxx startx helm chart series](https://helm-repository.readthedocs.io#examples-helm-charts) focused on deploying various kind of application consuming the cluster services deployed using the [cluster-xxx charts](https://helm-repository.readthedocs.io#cluster-helm-charts).

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
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/example-fruitapp-frontend
```

### 4. Install this chart

```bash
helm install startx/example-fruitapp-frontend
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

### example-fruitapp-frontend values dictionary

| Key      | Default       | Description                                                      |
| -------- | ------------- | ---------------------------------------------------------------- |
| image    | fedora:latest | Image to run into the pod                                        |
| command  | /bin/sx       | Command to run inside the container                              |
| args     | run           | argunments to pass to the command exectuted inside the container |
| debug    | true          | Enable debuging of the container                                 |
| replicas | 1             | Define the number of replicas for this sxapi instance            |

## Values files 

### Default values file (values.yaml)

Simple deployment of a container image with the following characteristics :

- 1 **deployment** named **example-fruitapp-frontend** of **1 pod** running **quay.io/startx/fedora:latest** image
- 1 **service** named **example-fruitapp-frontend**

```bash
# base configuration running default configuration
helm install startx/example-fruitapp-frontend
```

### Demo values file (values-demo.yaml)

Deployment of an demo container image with the following characteristics :

- 1 **pod** named **demo-helm-deployment** of **2 pods** running **quay.io/startx/apache:latest** image
- 1 **service** named **demo-helm-deployment**

```bash
# Configuration running demo example configuration
helm install startx/example-fruitapp-frontend -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-demo.yaml
```

### Apache values file (values-apache.yaml)

Deployment of an apache container image with the following characteristics :

- 1 **pod** named **example-fruitapp-frontend-apache** of **2 pods** running **quay.io/startx/apache:latest** image
- 1 **service** named **example-fruitapp-frontend-apache**

```bash
# Configuration running apache example configuration
helm install startx/example-fruitapp-frontend -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-apache.yaml
```

### MariaDB values file (values-mariadb.yaml)

Deployment of an mariadb container image with the following characteristics :

- 1 **pod** named **example-fruitapp-frontend-mariadb** of **2 pods** running **quay.io/startx/mariadb:latest** image
- 1 **service** named **example-fruitapp-frontend-mariadb**

```bash
# Configuration running mariadb example configuration
helm install startx/example-fruitapp-frontend -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-mariadb.yaml
```

## History

| Release | Date       | Description                                                                                            |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 9.8.239 | 2022-05-28 | Initial commit for this helm chart with default value example 

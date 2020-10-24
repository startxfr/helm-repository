# STARTX helm : example-deployment

This helm chart is used to create a deployment of various application images according to the values file.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### Get information about this chart

```bash
helm show chart startx/example-deployment
```

### Install this chart

```bash
helm install startx/example-deployment
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **service** named **example-deployment** load balancing to pod deployed
- 1 **deployment** named **example-deployment** deploying **1 pod** from image **startx/apache:latest**

```bash
# base configuration running default configuration
helm install startx/example-deployment
```

## Others values availables

- **demo** : Deployment of 2 apache pod (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-demo.yaml))

```bash
helm install startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-demo.yaml
```

- **apache** : Deployment of 2 apache pod (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-apache.yaml))

```bash
helm install startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-apache.yaml
```

- **mariadb** : Deployment of 1 mariadb pod (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-mariadb.yaml))

```bash
helm install startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-mariadb.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.0.1   | 2020-10-01 | Initial commit
| 0.1.0   | 2020-10-07 | Release 0.1 stable release for all charts
| 0.1.22  | 2020-10-23 | Improve documentation
| 0.2.0  | 2020-10-24 | Improve cluster-rbac options

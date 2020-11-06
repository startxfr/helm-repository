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
| 0.0.1   | 2020-09-14 | Initial commit for this helm chart with default value example (removed)
| 0.1.22  | 2020-10-23 | Improve documentation for example-deployment (removed)
| 0.2.11  | 2020-10-25 | publish stable update for the full repository
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release
| 0.2.34  | 2020-10-30 | Update note and chart description
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.2.999 | 2020-10-31 | publish stable update for the full repository
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.17  | 2020-11-01 | Synchronize releases for all chart in the startx repository
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21

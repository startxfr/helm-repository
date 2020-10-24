# STARTX helm : example-pod

This helm chart is used to create a simple pod with various application images according to the values file.

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
helm show chart startx/example-pod
```

### Install this chart

```bash
helm install startx/example-pod
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **pod** named **example-pod** from image **startx/fedora:latest**

```bash
# base configuration running default configuration
helm install startx/example-pod
```

## Others values availables

- **demo** : Deployment of 1 fedora pod (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-pod/values-demo.yaml))

```bash
helm install startx/example-pod -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-pod/values-demo.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.0.1   | 2020-10-01 | Initial commit
| 0.1.0   | 2020-10-07 | Release 0.1 stable release for all charts
| 0.1.18  | 2020-10-23 | Improve documentation
| 0.2.0   | 2020-10-24 | Improve cluster-rbac options
| 0.2.1  | 2020-10-24 | publish stable update for the full repository
| 0.2.2  | 2020-10-24 | Repository update with all chart release
| 0.2.5  | 2020-10-24 | Unstable repository global update
| 0.2.7  | 2020-10-24 | Unstable repository release
| 0.2.9  | 2020-10-24 | Update demo charts

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
| 0.1.0   | 2020-10-07 | Initial commit for this helm chart with default value example (removed)
| 0.1.18  | 2020-10-23 | Improve documentation for example-pod (removed)
| 0.2.11  | 2020-10-25 | publish stable update for the full repository
| 0.2.34  | 2020-10-30 | Update note and chart description (removed)
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.33  | 2020-11-07 | publish stable update for the full repository
| 0.3.34  | 2020-11-08 | Improve example-pod options

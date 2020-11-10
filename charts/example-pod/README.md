# STARTX helm : example-pod

This helm chart is used to create a simple pod with various application images according to the values file.

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
helm show chart startx/example-pod
```

### 4. Install this chart

```bash
helm install startx/example-pod
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

### example-pod values dictionary

| Key       | Default       | Description
| --------- | ------------- | -----------------------------------------------------
| image     | fedora:latest | Image to run into the pod
| command   | /bin/sx       | Command to run inside the container
| args      | run           | argunments to pass to the command exectuted inside the container
| debug     | true          | Enable debuging of the container


## Values files

### Default values file (values.yaml)

Simple pod deployment of a container image with the following characteristics :

- 1 **pod** named **example-pod** running **quay.io/startx/fedora:latest** image

```bash
# base configuration running default configuration
helm install startx/example-pod
```

### Development values file (values-demo.yaml)

Demo pod deployment of a container image with the following characteristics :

- 1 **pod** named **demo-helm-pod** running **quay.io/startx/fedora:latest** image

```bash
# base configuration running demo configuration
helm install startx/example-pod -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-demo.yaml
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
| 0.3.50  | 2020-11-08 | publish stable update for the full repository
| 0.3.53  | 2020-11-08 | publish stable update for the full repository
| 0.3.59  | 2020-11-08 | publish stable update for the full repository
| 0.3.61  | 2020-11-09 | Improve repository documentation and new chart for kubevirt management
| 0.3.73  | 2020-11-10 | publish stable update for the full repository
| 0.3.77  | 2020-11-10 | publish stable update for the full repository
| 0.3.83  | 2020-11-10 | publish stable update for the full repository
| 0.3.93  | 2020-11-10 | Move to 0.3.93 dependencies for all cluster-xxx charts in the startx repository

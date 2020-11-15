# STARTX helm : example-imagestreams

This helm chart is used to used to load imagestreams into a given namespace.

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
helm show chart startx/example-imagestreams
```

### 4. Install this chart

```bash
helm install startx/example-imagestreams
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

### example-imagestreams values dictionary

| Key       | Default       | Description
| --------- | ------------- | -----------------------------------------------------
| image     | fedora:latest | Image to run into the imagestreams
| command   | /bin/sx       | Command to run inside the container
| args      | run           | argunments to pass to the command exectuted inside the container
| debug     | true          | Enable debuging of the container

## Values files

### Default values file (values.yaml)

Simple imagestreams deployment of a container image with the following characteristics :

- 1 **imagestreams** named **example-imagestreams** running **quay.io/startx/fedora:latest** image

```bash
# base configuration running default configuration
helm install startx/example-imagestreams
```

### Development values file (values-demo.yaml)

Demo imagestreams deployment of a container image with the following characteristics :

- 1 **imagestreams** named **demo-helm-imagestreams** running **quay.io/startx/fedora:latest** image

```bash
# base configuration running demo configuration
helm install startx/example-imagestreams -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-demo.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.133 | 2020-11-15 | Create chart example-imagestreams from example-imagestreams
| 0.3.135 | 2020-11-15 | Add support for loading startx and sxv4 images streams into the openshift catalog

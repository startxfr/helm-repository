# STARTX helm : example-knative

This helm chart is used to create various serverless application based on [knative helm chart](https://startxfr.github.io/helm-repository/charts/knative)

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
helm show chart startx/example-knative
```

### 4. Install this chart

```bash
helm install startx/example-knative
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description
| ------------------- | --------- | -----------------------------------------------------
| context.scope       | default   | Name of the global scope for this application (organisational tenant)
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod)
| context.component   | demo      | Component name of this application (logical tenant)
| context.app         | knative     | Application name (functionnal tenant, default use Chart name)
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)

### example-knative values dictionary

| Key                   | Default    | Description
| --------------------- | ---------- | -----------------------------------------------------
| knative.service.enabled | false      | Enable service for this application
| knative.version         | 0.3.53     | Sxapi image version to run
| knative.profile         | prod:start | Profile to run inside the container
| knative.debug           | true       | Enable debuging of the container
| knative.replicas        | 1          | Define the number of replicas for this knative instance
| knative.data            | string     | Files to load into the application

## Values files

### Default values file (values.yaml)

Serverless service with the following characteristics (deployment is disable) :

- 1 **knative service** named **webserver** in namespace **default** deploying image **quay.io/startx/php:latest** with restricted ressources

```bash
# base configuration running default configuration
helm install startx/example-knative
```

### Development values file (values-demo-sxapi-knative.yaml)

Complete deployment of a knative development application with the following characteristics :

- 1 **knative service** named **example-sxapi-knative** in namespace **demo-sxapi** deploying image **startx/sxapi:latest** with restricted ressources and debug enabled

```bash
# base configuration running  demo sxapi with a knative configuration
helm install startx/example-knative -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-knative/values-demo-sxapi-knative.yaml
```

### Development values file (values-demo-knative-helloworld-go.yaml)

Complete deployment of a knative development application with the following characteristics :

- 1 **knative service** named **example-helloworld-go** in namespace **demo-knative** deploying image **gcr.io/knative-samples/helloworld-go** with restricted ressources

```bash
# base configuration running  demo sxapi with a knative configuration
helm install startx/example-knative -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-knative/values-demo-knative-helloworld-go.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.133  | 2020-11-15 | Create chart example-knative from example-knative

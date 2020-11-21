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

Complete deployment of an knative application with the following characteristics :

- 1 **service** named **example-knative** load balancing to pod deployed
- 1 **deployment** named **example-knative** deploying **1 pod** from version **0.3.53** knative image running the **prod:start** command with debug disabled
- 2 **configMap** holding knative configuration and pod environment variable context

```bash
# base configuration running default configuration
helm install startx/example-knative
```

### Development values file (values-dev.yaml)

Complete deployment of a knative development application with the following characteristics :

- 1 **service** named **example-knative-dev** load balancing to pod deployed
- 1 **deployment** named **example-knative-dev** deploying **1 pod** from version **0.3.53** knative image running the **dev:start** command with debug disabled
- 2 **configMap** holding knative configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-knative -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-knative/values-dev.yaml
```

### Version 0.0.1 values file (values-v0.0.1.yaml)

Complete deployment of a knative production application (v0.0.1) with the following characteristics :

- 1 **service** named **example-knative-prod** load balancing to pod deployed
- 1 **deployment** named **example-knative-prod** deploying **1 pod** from version **0.3.52** knative image running the **prod:start** command with debug disabled
- 2 **configMap** holding knative configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-knative -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-knative/values-v0.0.1.yaml
```

### Version 0.0.2 values file (values-v0.0.2.yaml)

Complete deployment of a knative production application (v0.0.2) with the following characteristics :

- 1 **service** named **example-knative-prod** load balancing to pod deployed
- 1 **deployment** named **example-knative-prod** deploying **1 pod** from version **0.3.53** knative image running the **prod:start** command with debug disabled
- 2 **configMap** holding knative configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-knative -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-knative/values-v0.0.2.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.133  | 2020-11-15 | Create chart example-knative from example-knative

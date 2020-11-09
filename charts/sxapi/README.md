# STARTX helm : sxapi

This helm chart is used to create a deployment of a small an simple micro-service based on 
sxapi engine running under nodejs engine.

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
helm show chart startx/sxapi
```

### 4. Install this chart

```bash
helm install startx/sxapi
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

### sxapi values dictionary

| Key                   | Default    | Description
| --------------------- | ---------- | -----------------------------------------------------
| sxapi.service.enabled | false      | Enable service for this application
| sxapi.version         | 0.3.53     | Sxapi image version to run
| sxapi.profile         | prod:start | Profile to run inside the container
| sxapi.debug           | true       | Enable debuging of the container
| sxapi.replicas        | 1          | Define the number of replicas for this sxapi instance
| sxapi.data            | string     | Files to load into the application

## Values files

### Default values file (values.yaml)

Complete deployment of a project with the following characteristics :

- 1 **service** named **sxapi** load balancing to pod deployed
- 1 **deployment** named **sxapi** deploying **1 pod** from version **0.3.53** sxapi image running the **prod:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running default configuration
helm install startx/sxapi
```

### Dev values file (values-dev.yaml)

Complete deployment of a project with the following characteristics :

- 1 **service** named **sxapi** load balancing to pod deployed
- 1 **deployment** named **sxapi** deploying **1 pod** from version **0.3.53** sxapi image running the **dev:start** command with debug enabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running dev configuration
helm install startx/sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-dev.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.51  | 2020-10-31 | Initial commit for this chart with default and dev value examples
| 0.2.99  | 2020-10-31 | Prepare release 0.3.0
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.1   | 2020-11-01 | Move to go templates for notes generation and move app content to value property sxapi.data
| 0.3.3   | 2020-11-01 | Test new scope for note template helper
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.45  | 2020-11-08 | Align all basic helm chart to 0.3.45 release
| 0.3.50  | 2020-11-08 | publish stable update for the full repository
| 0.3.51  | 2020-11-08 | Improve sxapi options
| 0.3.53  | 2020-11-08 | publish stable update for the full repository
| 0.3.57  | 2020-11-08 | Improve sxapi options
| 0.3.59  | 2020-11-08 | publish stable update for the full repository
| 0.3.61  | 2020-11-09 | Improve repository documentation and new chart for kubevirt management
| 0.3.65  | 2020-11-09 | Align sxapi to same release as basic helm chart in startx repository

# STARTX helm : example-php

This helm chart is used to create a deployment of a small an simple micro-service based on [php helm chart](https://startxfr.github.io/helm-repository/charts/php)

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
helm show chart startx/example-php
```

### 4. Install this chart

```bash
helm install startx/example-php
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description
| ------------------- | --------- | -----------------------------------------------------
| context.scope       | default   | Name of the global scope for this application (organisational tenant)
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod)
| context.component   | demo      | Component name of this application (logical tenant)
| context.app         | php     | Application name (functionnal tenant, default use Chart name)
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)

### example-php values dictionary

| Key                   | Default    | Description
| --------------------- | ---------- | -----------------------------------------------------
| php.service.enabled | false      | Enable service for this application
| php.version         | 0.3.53     | Sxapi image version to run
| php.profile         | prod:start | Profile to run inside the container
| php.debug           | true       | Enable debuging of the container
| php.replicas        | 1          | Define the number of replicas for this php instance
| php.data            | string     | Files to load into the application

## Values files

### Default values file (values.yaml)

Complete deployment of an php application with the following characteristics :

- 1 **service** named **example-php** load balancing to pod deployed
- 1 **deployment** named **example-php** deploying **1 pod** from version **0.3.53** php image running the **prod:start** command with debug disabled
- 2 **configMap** holding php configuration and pod environment variable context

```bash
# base configuration running default configuration
helm install startx/example-php
```

### Development values file (values-dev.yaml)

Complete deployment of a php development application with the following characteristics :

- 1 **service** named **example-php-dev** load balancing to pod deployed
- 1 **deployment** named **example-php-dev** deploying **1 pod** from version **0.3.53** php image running the **dev:start** command with debug disabled
- 2 **configMap** holding php configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-php -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-php/values-dev.yaml
```

### Version 0.0.1 values file (values-v0.0.1.yaml)

Complete deployment of a php production application (v0.0.1) with the following characteristics :

- 1 **service** named **example-php-prod** load balancing to pod deployed
- 1 **deployment** named **example-php-prod** deploying **1 pod** from version **0.3.52** php image running the **prod:start** command with debug disabled
- 2 **configMap** holding php configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-php -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-php/values-v0.0.1.yaml
```

### Version 0.0.2 values file (values-v0.0.2.yaml)

Complete deployment of a php production application (v0.0.2) with the following characteristics :

- 1 **service** named **example-php-prod** load balancing to pod deployed
- 1 **deployment** named **example-php-prod** deploying **1 pod** from version **0.3.53** php image running the **prod:start** command with debug disabled
- 2 **configMap** holding php configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-php -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-php/values-v0.0.2.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.11  | 2020-10-25 | Initial commit for this helm chart with default value example
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.3   | 2020-11-01 | Update php chart dependency to 0.3.1 and moving application data to value file
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
| 0.3.97  | 2020-11-11 | publish stable update for the full repository
| 0.3.101  | 2020-11-11 | publish stable update for the full repository
| 0.3.105  | 2020-11-11 | Update cluster-xxx charts dependencies to 0.3.103 release
| 0.3.109  | 2020-11-12 | publish stable update for the full repository
| 0.3.117  | 2020-11-12 | Move to 0.3.115 basic chart dependencies
| 0.3.117  | 2020-11-13 | Create chart example-php from example-php
| 0.3.121  | 2020-11-14 | Add full example of php application deployed with content served from configmaps
| 0.3.125  | 2020-11-14 | publish stable update for the full repository
| 0.3.133  | 2020-11-14 | publish stable update for the full repository

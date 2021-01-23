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

### Development values file (values-demo-hpa.yaml)

Complete deployment of a php demo application for stress test (used in HPA test) with the following characteristics :

- 1 **service** named **hpa-app** load balancing to pod deployed
- 1 **deployment** named **hpa-app** deploying **2 pod** from version **alpine3** php image running with debug disabled
- 2 **configMap** holding php configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-php -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-php/values-demo-hpa.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.117  | 2020-11-13 | Create chart example-php from example-php
| 0.3.121  | 2020-11-14 | Add full example of php application deployed with content served from configmaps
| 0.3.135  | 2020-11-23 | Improve documentation for all examples charts
| 0.3.141 | 2020-11-24 | publish stable update for the full repository
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13
| 0.3.153 | 2021-01-23 | publish stable update for the full repository

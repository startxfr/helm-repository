# Example couchbase

This helm chart is used to create a deployment of a small PHP webserver based on [startx apache PHP image](https://quay.io/startx/couchbase)

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
helm show chart startx/example-couchbase
```

### 4. Install this chart

```bash
helm install startx/example-couchbase
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)                   |
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | couchbase | Application name (functionnal tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### example-couchbase values dictionary

| Key                       | Default    | Description                                               |
| ------------------------- | ---------- | --------------------------------------------------------- |
| couchbase.service.enabled | false      | Enable service for this application                       |
| couchbase.version         | 0.3.57     | Sxapi image version to run                                |
| couchbase.profile         | prod:start | Profile to run inside the container                       |
| couchbase.debug           | true       | Enable debuging of the container                          |
| couchbase.replicas        | 1          | Define the number of replicas for this couchbase instance |
| couchbase.data            | string     | Files to load into the application                        |

## Values files

### Default values file (values.yaml)

Complete deployment of an couchbase application with the following characteristics :

- 1 **service** named **example-couchbase** load balancing to pod deployed
- 1 **deployment** named **example-couchbase** deploying **1 pod** from version **0.3.57** couchbase image running the **prod:start** command with debug disabled
- 2 **configMap** holding couchbase configuration and pod environment variable context

```bash
# base configuration running default configuration
helm install startx/example-couchbase
```

### Development values file (values-demo-hpa.yaml)

Complete deployment of a couchbase demo application for stress test (used in HPA test) with the following characteristics :

- 1 **service** named **hpa-app** load balancing to pod deployed
- 1 **deployment** named **hpa-app** deploying **2 pod** from version **alpine3** couchbase image running with debug disabled
- 2 **configMap** holding couchbase configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/example-couchbase -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-couchbase/values-demo-hpa.yaml
```

## History

| Release | Date       | Description                                                                  |
| ------- | ---------- | ---------------------------------------------------------------------------- |
| 0.3.203 | 2021-02-22 | Create chart example-couchbase from example-sxapi                            |
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205                                    |
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                              |
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215                                           |
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming                                      |
| 0.3.305 | 2021-06-04 | publish stable update for the full repository                                |
| 0.3.343 | 2021-06-06 | publish stable update for the full repository                                |
| 0.3.381 | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377 |
| 0.3.390 | 2021-06-12 | Prepare 0.4.0 release
| 0.3.423 | 2021-06-17 | Prepare the v0.4 release. Stable aligned version of all charts
| 0.3.431 | 2021-07-05 | Move to dependencies 1.18.0
| 0.3.480 | 2021-08-03 | publish stable update for the full repository
| 0.3.998 | 2021-08-04 | publish stable update for the full repository

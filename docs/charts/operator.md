# ![operator](https://helm-repository.readthedocs.io/en/latest/img/operator.svg "Basic Chart : Operator") Basic Chart : Operator
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_operator-83E22B.svg)](https://artifacthub.io/packages/search?ts_query_web=operator+startx)

This helm chart is used to configure various operator using subscription (openshift) or CRD (k8s) resources.

This chart is part of the [basic-xxx startx helm chart series](https://helm-repository.readthedocs.io#basic-helm-charts) used by [cluster-xxx charts](https://helm-repository.readthedocs.io#cluster-helm-charts) and [example-xxx charts](https://helm-repository.readthedocs.io#examples-helm-charts).

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable/
```

### 3. Get information about this chart

```bash
helm show chart startx/operator
```

### 4. Install this chart

```bash
helm install operator startx/operator
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | operator  | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### operator values dictionary

| Key                                    | Default               | Description                                                                 |
| -------------------------------------- | --------------------- | --------------------------------------------------------------------------- |
| subscription.enabled                   | true                  | Enable deployment of the subscription                                       |
| subscription.name                      | default               | name of the subscription (mandatory)                                        |
| subscription.namespace                 | default               | namespace of the subscription                                               |
| subscription.version                   | v0.1.0                | version of the operator to deploy (mandatory)                               |
| subscription.operator                  | object                | Configuration of the CRW operator                                           |
| subscription.operator.channel          | latest                | The CRW channel to use                                                      |
| subscription.operator.name             | default               | name of the operator (if not set, use the subscription name)                |
| subscription.operator.csv              | default               | name of the CSV (if not set, use the subscription name)                     |
| subscription.operator.source.name      | redhat-operators      | name of the operator source                                                 |
| subscription.operator.source.namespace | openshift-marketplace | Namespace of the operator source                                            |
| operatorGroup.enabled                  | true                  | Enable deployment of an operatorGroup for the subscription                  |
| operatorGroup.name                     | default               | name of the operatorGroup (if not set, use the subscription name)           |
| operatorGroup.namespace                | default               | namespace of the operatorGroup (if not set, use the subscription namespace) |
| operatorGroup.providedAPIs             | default.local         | ist of the provided APIs (mandatory if enabled)                             |

## Values files

### Default values file (values.yaml)

Complete deployment of an operator with the following characteristics :

- 1 **subscription** named **codeready-workspaces** in namespace **openshift-workspaces**
  - operator named **codeready-workspaces**
  - version **2.3.0** of **crwoperator** CSV
  - source is **redhat-operators** from **openshift-marketplace** namespace
- 1 **operatorGroup** named **codeready-workspaces** in namespace **openshift-workspaces**

```bash
# base configuration running default configuration
helm install operator-workspaces startx/operator
```

### Tekton v1.0.1 values file (values-tekton-1.0.1.yaml)

Complete deployment of a tekton v1.0.1 operator with the following characteristics :

- 1 **subscription** named **openshift-pipelines-operator-rh** in namespace **openshift-workspaces**
  - operator named **openshift-pipelines-operator-rh**
  - version **1.0.1** of **openshift-pipelines-operator** CSV
  - source is **redhat-operators** from **openshift-marketplace** namespace

```bash
# base configuration running tekton v1.0.1 configuration
helm install operator-pipelines startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-tekton-1.0.1.yaml
```

### CRW v2.3.0 values file (values-crw-2.3.0.yaml)

Complete deployment of a CRW v2.3.0 operator with the following characteristics :

- 1 **subscription** named **codeready-workspaces** in namespace **openshift-workspaces**
  - operator named **codeready-workspaces**
  - version **2.3.0** of **crwoperator** CSV
  - source is **redhat-operators** from **openshift-marketplace** namespace
- 1 **operatorGroup** named **codeready-workspaces** in namespace **openshift-workspaces**

```bash
# base configuration running CRW v2.3.0 configuration
helm install operator-workspaces startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-crw-2.3.0.yaml
```

### 3scale v0.6.0 values file (values-3scale-0.6.0.yaml)

Complete deployment of a 3scale v0.6.0 operator with the following characteristics :

- 1 **subscription** named **3scale-operator** in namespace **startx-3scale**
  - operator named **3scale-operator**
  - version **0.6.0** of **3scale-operator** CSV
  - source is **redhat-operators** from **openshift-marketplace** namespace
- 1 **operatorGroup** named **3scale-operator** in namespace **startx-3scale**

```bash
# base configuration running 3scale v0.6.0 configuration
helm install operator-3scale startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-3scale-0.6.0.yaml
```

## History

| Release  | Date       | Description                                                                                                                   |
| -------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 16.19.43 | 2025-02-27 | publish stable update for the full repository |
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.15 | 2026-03-02 | Prepare upgrading dependency to 19.23.11 |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.7 | 2026-03-02 | Update dependencies to version 20.14.0 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.1 | 2026-03-02 | Prepare release 21.3.x with 21.x dependencies |
| 21.3.3 | 2026-03-02 | Upgrade dependencies to v21.3.0 |
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.21 | 2026-06-19 | release basic version |

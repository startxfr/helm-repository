# STARTX helm : operator

This helm chart is used to configure various operator using subscription (openshift) or CRD (k8s) ressources.

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
helm show chart startx/operator
```

### 4. Install this chart

```bash
helm install startx/operator
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description
| ------------------- | --------- | -----------------------------------------------------
| context.scope       | default   | Name of the global scope for this application (organisational tenant)
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod)
| context.component   | demo      | Component name of this application (logical tenant)
| context.app         | operator   | Application name (functionnal tenant, default use Chart name)
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)

### operator values dictionary

| Key                                    | Default               | Description
| -------------------------------------- | --------------------- | -----------------------------------------------------
| subscription.enabled                   | true                  | Enable deployment of the subscription
| subscription.name                      | default               | name of the subscription (mandatory)
| subscription.namespace                 | default               | namespace of the subscription
| subscription.version                   | v0.1.0                | version of the operator to deploy (mandatory)
| subscription.operator                  | object                | Configuration of the CRW operator
| subscription.operator.channel          | latest                | The CRW channel to use
| subscription.operator.name             | default               | name of the operator (if not set, use the subscription name)
| subscription.operator.csv              | default               | name of the CSV (if not set, use the subscription name)
| subscription.operator.source.name      | redhat-operators      | name of the operator source
| subscription.operator.source.namespace | openshift-marketplace | Namespace of the operator source
| operatorGroup.enabled                  | true                  | Enable deployment of an operatorGroup for the subscription
| operatorGroup.name                     | default               | name of the operatorGroup (if not set, use the subscription name)
| operatorGroup.namespace                | default               | namespace of the operatorGroup (if not set, use the subscription namespace)
| operatorGroup.providedAPIs             | default.local         | ist of the provided APIs (mandatory if enabled)

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
helm install startx/operator
```

### Tekton v1.0.1 values file (values-tekton-1.0.1.yaml)

Complete deployment of a tekton v1.0.1 operator with the following characteristics :

- 1 **subscription** named **openshift-pipelines-operator-rh** in namespace **openshift-workspaces**
  - operator named **openshift-pipelines-operator-rh**
  - version **1.0.1** of **openshift-pipelines-operator** CSV
  - source is **redhat-operators** from **openshift-marketplace** namespace

```bash
# base configuration running tekton v1.0.1 configuration
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-tekton-1.0.1.yaml
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
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-crw-2.3.0.yaml
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
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-3scale-0.6.0.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.36  | 2020-10-31 | Initial commit for this helm chart with default value example
| 0.2.37  | 2020-10-31 | Enable subscription and operatorGroup creation and add values file for tekton-1.0.1, crw-2.3.0 and scale-0.6.0 deployment
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.1   | 2020-11-01 | Move to go templates for notes generation
| 0.3.3   | 2020-11-01 | Test new scope for note template helper
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.29  | 2020-11-07 | Improve helm hook ordering cordinated with higher cluster-xxx helm chart depending on this chart
| 0.3.45  | 2020-11-08 | Align all basic helm chart to 0.3.45 release
| 0.3.50  | 2020-11-08 | publish stable update for the full repository
| 0.3.51  | 2020-11-08 | Improve operator options
| 0.3.53  | 2020-11-08 | publish stable update for the full repository
| 0.3.57  | 2020-11-08 | Improve operator options

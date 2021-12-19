# Cluster Vault

This helm chart is used to create a deployment of a vault-config provided by the Red Hat Community of Practice.
This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deployment pod but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io)  for
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
helm show chart startx/cluster-vault-config
```

### 4. Install this chart

```bash
helm install startx/cluster-vault-config
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)                   |
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | sxapi     | Application name (functionnal tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |


#### route values example

```yaml
route:
  enabled: true
```

### project values dictionary

The **project property** scope the [project helm chart](https://helm-repository.readthedocs.io/en/latest/charts/project) dependency. You can find
more information on the availables options you can set under this **project** property on the [project helm chart documentation](https://helm-repository.readthedocs.io/en/latest/charts/project) or by reading the [source code](https://github.com/startxfr/helm-repository/tree/master/charts/project).

#### project values example

```yaml
# example of a project creation with this helm chart
project:
  enabled: true
  context:
    scope: default
    cluster: default
    environment: dev
    component: infra
    app: default-vault-config
  project:
    enabled: true
    type: project
    name: default-vault-config
    display_name: Operator VAULT
    description: Vault storage & control plane configured by startx
  rbac: 
    enabled: true
    user: 
    - id: vault-config-sa-edit
      name: "system:serviceaccount:default-vault-config:{{ .Release.name }}"
      role: edit
    - id: vault-config-agent-injector-sa-admin
      name: "system:serviceaccount:default-vault-config:{{ .Release.name }}-agent-injector"
      role: admin


### vault values dictionary

The **vault property** scope the [vault-config helm chart](https://helm-repository.readthedocs.io/en/latest/charts/cluster-vault-config) dependency. You can find
more information on the availables options you can set under this **vault** property on the [vault-config helm chart documentation](https://helm-repository.readthedocs.io/en/latest/charts/cluster-vault-config) or by reading the [source code](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-vault).

#### vault values example

```yaml
# example of a vault-config creation with this helm chart

```

## Values files

### Default values file (values.yaml)

Configuration of default properties all disabled by default. This mean no resource will be created unless overwriting default parameters. Default configuration have the following characteristics :

- 1 **project** named **default-vault-config**
- 1 **operatorGroup** named **vault-config** to enable codeready operator in the project
- 1 **subscription** named **vault-config** to deploy codeready operator in the project with the following characteristics
  - operator name is **vault-config**
  - operator version is **2.3.0**
  - operator catalog is **redhat-operators** located in **openshift-marketplace**
- 1 **cheCluster** named **vault-config** to deploy cheCluster in the project with the following characteristics
  - storage class **gp2**
  - storage size defined to **1Gi**

```bash
# base configuration running default configuration
helm install startx/cluster-vault-config
```

### Default values file (values-startx.yaml)

Configuration of startx properties with the following characteristics :

- 1 **project** named **openshift-vault-config** (disabled by default)
- 1 **operatorGroup** named **vault-config** (disabled by default)
- 1 **subscription** named **vault-config** (disabled by default)
  - operator name is **vault-config**
  - operator version is **2.3.0**
  - operator catalog is **redhat-operators** located in **openshift-marketplace**
- 1 **cheCluster** named **vault-config** to deploy cheCluster in the project with the following characteristics
  - storage class **aws-generic-retain**
  - storage size defined to **2Gi**

```bash
# base configuration running startx configuration
helm install startx/cluster-vault-config -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-vault-config/values-startx.yaml
```

## History

| Release | Date       | Description                                                                                            |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 8.20.66 | 2021-11-20 | Updating limits for context vars in values schema
| 8.20.70 | 2021-11-20 | publish stable update for the full repository
| 8.20.71 | 2021-11-20 | Align all charts to Openshift version 4.8.21
| 9.8.1 | 2021-11-20 | Upgrade to Openshift version 4.9.8
| 9.8.4 | 2021-11-20 | Stable release of chart for Openshift 4.9.8 version
| 9.8.7 | 2021-11-20 | Debug dependencies problem
| 9.8.9 | 2021-11-20 | Update startx chart dependencies version to 9.8.8 and schema update
| 9.8.15 | 2021-11-20 | Update startx chart dependencies version to 9.8.11
| 9.8.19 | 2021-11-20 | Update startx chart dependencies version to 9.8.15 and improve values schema
| 9.8.28 | 2021-11-20 | Update the startx chart dependencies to version 9.8.23
| 9.8.39 | 2021-11-21 | Debug version check with more permissive mode
| 9.8.43 | 2021-11-21 | Update the startx chart dependencies to version 9.8.39
| 9.8.45 | 2021-11-21 | Update the values schema limits for context properties
| 9.8.47 | 2021-11-21 | Improve version management for chart
| 9.8.51 | 2021-11-22 | Update startx chart dependencies to version 9.8.48
| 9.8.67 | 2021-12-18 | Align all charts to release 9.8.67
| 9.8.71 | 2021-12-18 | Update helm-chart dependencies to version 9.8.59
| 9.8.75 | 2021-12-19 | Align with all other startx chart version to number 9.8.75
| 9.8.76 | 2021-12-19 | Change helm.sh/chart name

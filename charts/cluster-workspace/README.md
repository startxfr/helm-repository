# Cluster workspace

This helm chart is used to configure code ready workspace via it's operator and deploy a cheCluster.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

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
helm show chart startx/cluster-workspace
```

### 4. Install this chart

```bash
helm install startx/cluster-workspace
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

### cheCluster values dictionary

| Key                     | Default              | Description                                         |
| ----------------------- | -------------------- | --------------------------------------------------- |
| cheCluster              | {}                   | Object holding the cheCluster instance to configure |
| cheCluster.enabled      | true                 | Enable the creation of the cheCluster               |
| cheCluster.hooked       | true                 | Activate the manager as a helm hook                 |
| cheCluster.name         | codeready-workspaces | name of the che cluster                             |
| cheCluster.storageClass | gp2                  | Storage class to use for persistance                |
| cheCluster.storageSize  | 1Gi                  | Size of the PVC used for storage persistance        |

#### cheCluster values example

```yaml
cheCluster:
  enabled: true
  hooked: true
  name: "codeready-workspaces"
  storageClass: "gp2"
  storageSize: "1Gi"
```

### project values dictionary

The **project property** scope the [project helm chart](https://startxfr.github.io/helm-repository/charts/project) dependency. You can find
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
    app: default-workspaces
  project:
    enabled: true
    type: project
    name: workspaces-operator
    display_name: Operator WORKSPACES
    description: CodeReady Workspace configured by STARTX
```

### operator values dictionary

The **operator property** scope the [operator helm chart](https://startxfr.github.io/helm-repository/charts/operator) dependency. You can find
more information on the availables options you can set under this **operator** property on the [operator helm chart documentation](https://helm-repository.readthedocs.io/en/latest/charts/operator) or by reading the [source code](https://github.com/startxfr/helm-repository/tree/master/charts/operator).

#### operator values example

```yaml
# example of a operator creation with this helm chart
operator:
  enabled: true
  context:
    scope: default
    cluster: default
    environment: dev
    component: infra
    app: default-workspaces
  subscription:
    enabled: true
    hooked: true
    name: "codeready-workspaces"
    namespace: "workspaces-operator"
    version: "v2.3.0"
    operator:
      channel: latest
      name: codeready-workspaces
      csv: crwoperator
      source:
        name: redhat-operators
        namespace: example-marketplace
  operatorGroup:
    enabled: true
    hooked: true
    name: "codeready-workspaces"
    namespace: "workspaces-operator"
    providedAPIs: "CheCluster.v1.org.eclipse.che"
```

## Values files

### Default values file (values.yaml)

Configuration of default properties all disabled by default. This mean no resource will be created unless overwriting default parameters. Default configuration have the following characteristics :

- 1 **project** named **default-workspaces**
- 1 **operatorGroup** named **codeready-workspaces** to enable codeready operator in the project
- 1 **subscription** named **codeready-workspaces** to deploy codeready operator in the project with the following characteristics
  - operator name is **codeready-workspaces**
  - operator version is **2.3.0**
  - operator catalog is **redhat-operators** located in **openshift-marketplace**
- 1 **cheCluster** named **codeready-workspaces** to deploy cheCluster in the project with the following characteristics
  - storage class **gp2**
  - storage size defined to **1Gi**

```bash
# base configuration running default configuration
helm install startx/cluster-workspace
```

### Default values file (values-startx.yaml)

Configuration of startx properties with the following characteristics :

- 1 **project** named **openshift-workspaces** (disabled by default)
- 1 **operatorGroup** named **codeready-workspaces** (disabled by default)
- 1 **subscription** named **codeready-workspaces** (disabled by default)
  - operator name is **codeready-workspaces**
  - operator version is **2.3.0**
  - operator catalog is **redhat-operators** located in **openshift-marketplace**
- 1 **cheCluster** named **codeready-workspaces** to deploy cheCluster in the project with the following characteristics
  - storage class **aws-generic-retain**
  - storage size defined to **2Gi**

```bash
# base configuration running startx configuration
helm install startx/cluster-workspace -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-workspace/values-startx.yaml
```

## History

| Release | Date       | Description                                                                                            |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 0.2.12  | 2020-10-25 | Initial commit for this helm chart with default value example (removed)                                |
| 0.2.15  | 2020-10-26 | Improve cluster-workspace operator config                                                              |
| 0.2.51  | 2020-10-31 | Common release for all chart                                                                           |
| 0.3.0   | 2020-10-31 | Stable 0.3 release                                                                                     |
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21                                                      |
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information |
| 0.3.29  | 2020-11-07 | Improve NOTES output and move to 0.3.25 dependencies                                                   |
| 0.3.37  | 2020-11-07 | Improve helm hook ordering cordinated with dependencies                                                |
| 0.3.47  | 2020-11-08 | Update dependency to 0.3.45 release                                                                    |
| 0.3.93  | 2020-11-10 | Move to 0.3.93 dependencies for all cluster-xxx charts in the startx repository                        |
| 0.3.105 | 2020-11-11 | Update cluster-xxx charts dependencies to 0.3.103 release                                              |
| 0.3.117 | 2020-11-12 | Move to 0.3.115 basic chart dependencies                                                               |
| 0.3.135 | 2020-11-23 | Improve documentation for all examples charts                                                          |
| 0.3.141 | 2020-11-24 | publish stable update for the full repository                                                          |
| 0.3.151 | 2021-01-23 | Upgrade to CRW version 2.5.1                                                                           |
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                                                    |
| 0.3.153 | 2021-01-23 | publish stable update for the full repository                                                          |
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies                                                                         |
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments                            |
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies                                                                           |
| 0.3.187 | 2021-02-13 | Align cluster chart release to 0.3.187                                                                 || 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts
| 0.3.201 | 2021-02-20 | Update icon and image for charts
| 0.3.203 | 2021-02-21 | Upgrade chart release informations
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming
| 0.3.226 | 2021-05-31 | Add demo-che example values
| 0.3.227 | 2021-06-02 | Upgrade to CRW version 2.8.0
| 0.3.303 | 2021-06-02 | Update documentation and align all charts to release 0.3.303
| 0.3.311 | 2021-06-03 | | 03.311 | 2021-06-03 | Align cluster chart to version 0.3.311
| 0.3.305 | 2021-06-04 | publish stable update for the full repository

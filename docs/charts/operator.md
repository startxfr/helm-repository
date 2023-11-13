# Basic operator

This helm chart is used to configure various operator using subscription (openshift) or CRD (k8s) ressources.

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
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
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
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)                   |
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | operator  | Application name (functionnal tenant, default use Chart name)                     |
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
| 0.2.36   | 2020-10-31 | Initial commit for this helm chart with default value example                                                                 |
| 0.2.37   | 2020-10-31 | Enable subscription and operatorGroup creation and add values file for tekton-1.0.1, crw-2.3.0 and scale-0.6.0 deployment     |
| 0.2.51   | 2020-10-31 | Common release for all chart                                                                                                  |
| 0.3.0    | 2020-10-31 | Stable 0.3 release                                                                                                            |
| 0.3.1    | 2020-11-01 | Move to go templates for notes generation                                                                                     |
| 0.3.3    | 2020-11-01 | Test new scope for note template helper                                                                                       |
| 0.3.21   | 2020-11-06 | Align all charts on the repository release 0.3.21                                                                             |
| 0.3.23   | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information                        |
| 0.3.29   | 2020-11-07 | Improve helm hook ordering cordinated with higher cluster-xxx helm chart depending on this chart                              |
| 0.3.65   | 2020-11-09 | Add hooked option to enable/disable use of helm hook (default is disabled)                                                    |
| 0.3.115  | 2020-11-12 | Release basic chart stability updates                                                                                         |
| 0.3.117  | 2020-11-12 | Move to 0.3.115 basic chart dependencies                                                                                      |
| 0.3.119  | 2020-11-14 | Add target option for the operator group to define if targetNamespace should be local to the project or global (no namespace) |
| 0.3.131  | 2020-11-14 | Stable values examples                                                                                                        |
| 0.3.135  | 2020-11-23 | Improve documentation for all examples charts                                                                                 |
| 0.3.141  | 2020-11-24 | publish stable update for the full repository                                                                                 |
| 0.3.142  | 2021-01-23 | Update for OCP 4.6.13                                                                                                         |
| 0.3.151  | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                                                                           |
| 0.3.153  | 2021-01-23 | publish stable update for the full repository                                                                                 |
| 0.3.155  | 2021-01-23 | Align operator chart to 0.3.155 release                                                                                       |
| 0.3.165  | 2021-01-23 | Upgrade all chart dependencies                                                                                                |
| 0.3.167  | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments                                                   |
| 0.3.169  | 2021-01-24 | Move to 0.3.155 dependencies                                                                                                  |
| 0.3.171  | 2021-01-24 | Align basic chart release to 0.3.171                                                                                          |
| 0.3.187  | 2021-02-13 | Align basic chart release to 0.3.187                                                                                          |
| 0.3.189  | 2021-02-13 | Align all basic charts to 0.3.189                                                                                             |
| 0.3.191  | 2021-02-13 | Update cluster chart dependencies to 0.3.189                                                                                  |
| 0.3.193  | 2021-02-20 | Stable base helm-chart                                                                                                        |
| 0.3.199  | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts                                                                   |
| 0.3.201  | 2021-02-20 | Update icon and image for charts                                                                                              |
| 0.3.203  | 2021-02-21 | Upgrade chart release informations                                                                                            |
| 0.3.205  | 2021-04-19 | Align release of core charts                                                                                                  |
| 0.3.207  | 2021-04-19 | Core chart dependencies moved to v0.3.205                                                                                     |
| 0.3.209  | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                                                                               |
| 0.3.215  | 2021-05-06 | Align all chart to release 0.3.215                                                                                            |
| 0.3.217  | 2021-05-10 | Align basic chart to release 0.3.217                                                                                          |
| 0.3.225  | 2021-05-10 | Update all chart to use new RBAC naming                                                                                       |
| 0.3.303  | 2021-06-02 | Update documentation and align all charts to release 0.3.303                                                                  |
| 0.3.301  | 2021-06-03 | Stable basic chart aligned to 0.3.301                                                                                         |
| 0.3.305  | 2021-06-04 | publish stable update for the full repository                                                                                 |
| 0.3.343  | 2021-06-06 | publish stable update for the full repository                                                                                 |
| 0.3.381  | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377                                                  |
| 0.3.390  | 2021-06-12 | Prepare 0.4.0 release                                                                                                         |
| 0.3.423  | 2021-06-17 | Prepare the v0.4 release. Stable aligned version of all charts                                                                |
| 0.3.431  | 2021-07-05 | Move to dependencies 1.18.0                                                                                                   |
| 0.3.480  | 2021-08-03 | publish stable update for the full repository                                                                                 |
| 0.3.998  | 2021-08-04 | publish stable update for the full repository                                                                                 |
| 0.3.999  | 2021-08-04 | Release stable version 0.3.999 align with ocp 4.7.13                                                                          |
| 7.22.1   | 2021-08-04 | Move to release 7.22.1 to align versionning with ocp release cycle                                                            |
| 7.22.2   | 2021-08-04 | Move helm dependencies to a 7.x.x release model                                                                               |
| 7.22.3   | 2021-08-05 | publish stable update for the full repository                                                                                 |
| 7.22.5   | 2021-08-05 | publish stable update for the full repository                                                                                 |
| 7.22.6   | 2021-08-05 | Stable version for chart dependencies                                                                                         |
| 7.22.7   | 2021-08-05 | Stable for OCP version 4.7.22                                                                                                 |
| 7.22.12  | 2021-09-23 | publish stable update for the full repository                                                                                 |
| 7.22.15  | 2021-10-05 | Align core charts to release 7.22.15                                                                                          |
| 7.22.21  | 2021-10-05 | ServiceAccount and ImagePullSecrets managed by project chart                                                                  |
| 7.22.23  | 2021-10-06 | Align basic charts to version 7.22.23                                                                                         |
| 7.22.25  | 2021-10-06 | publish stable update for the full repository                                                                                 |
| 7.22.27  | 2021-10-06 | publish stable update for the full repository                                                                                 |
| 8.13.1   | 2021-10-06 | Stable release for OCP 4.8.13 version                                                                                         |
| 8.13.3   | 2021-10-08 | Improve code execution, syntax and introduce the ACS helm-chart                                                               |
| 8.13.5   | 2021-10-21 | publish stable update for the full repository                                                                                 |
| 8.13.7   | 2021-10-21 | publish stable update for the full repository                                                                                 |
| 8.13.8   | 2021-10-21 | Adding first draft of json schema                                                                                             |
| 8.13.9   | 2021-10-22 | Adding the schema in chart                                                                                                    |
| 8.13.16  | 2021-10-31 | Add the schema                                                                                                                |
| 8.13.17  | 2021-10-31 | value.schema.json fully support all options                                                                                   |
| 8.13.21  | 2021-11-01 | Align basic charts to version 8.13.21                                                                                         |
| 8.13.23  | 2021-11-10 | Solve helm issue in the kubeVersion for kube clusters                                                                         |
| 8.13.25  | 2021-11-10 | Solve helm issue in the kubeVersion for kube clusters and upgrade chart dep to version 8.13.23                                |
| 8.13.27  | 2021-11-10 | publish stable update for the full repository                                                                                 |
| 8.20.3   | 2021-11-11 | Align all charts to Openshift version 4.8.20                                                                                  |
| 8.20.2   | 2021-11-11 | stable release for basic chart for Openshift version 4.8.20                                                                   |
| 8.20.5   | 2021-11-12 | Upgrade all appVersion and align chart release                                                                                |
| 8.20.9   | 2021-11-12 | Align all startx chart to version 8.20.9                                                                                      |
| 8.20.11  | 2021-11-12 | Move chart dependencies to version 8.20.5                                                                                     |
| 8.20.33  | 2021-11-14 | publish stable update for the full repository                                                                                 |
| 8.20.34  | 2021-11-14 | Stable for basic chart                                                                                                        |
| 8.20.41  | 2021-11-14 | Aling all dependencies to version 8.20.34                                                                                     |
| 8.20.45  | 2021-11-19 | Stable version for operator chart                                                                                             |
| 8.20.46  | 2021-11-19 | Transitionnal chart                                                                                                           |
| 8.20.55  | 2021-11-19 | Stable release for basic charts                                                                                               |
| 8.20.60  | 2021-11-19 | publish stable update for the full repository                                                                                 |
| 8.20.63  | 2021-11-20 | Updating values schema                                                                                                        |
| 8.20.66  | 2021-11-20 | Updating limits for context vars in values schema                                                                             |
| 8.20.70  | 2021-11-20 | publish stable update for the full repository                                                                                 |
| 8.20.71  | 2021-11-20 | Align all charts to Openshift version 4.8.21                                                                                  |
| 9.8.1    | 2021-11-20 | Upgrade to Openshift version 4.9.8                                                                                            |
| 9.8.4    | 2021-11-20 | Stable release of chart for Openshift 4.9.8 version                                                                           |
| 9.8.7    | 2021-11-20 | Debug dependencies problem                                                                                                    |
| 9.8.8    | 2021-11-20 | Update schema limit to 30 characters for version name                                                                         |
| 9.8.9    | 2021-11-20 | Update startx chart dependencies version to 9.8.8 and schema update                                                           |
| 9.9.11   | 2021-11-20 | Update the context.xxx limit to 25 characters in values schema                                                                |
| 9.8.11   | 2021-11-20 | Update the context.xxx limit to 25 characters in values schema                                                                |
| 9.8.15   | 2021-11-20 | Update startx chart dependencies version to 9.8.11                                                                            |
| 9.8.19   | 2021-11-20 | Update startx chart dependencies version to 9.8.15 and improve values schema                                                  |
| 9.8.23   | 2021-11-20 | Version check in value schema support v as a prefix to the version identifier                                                 |
| 9.8.28   | 2021-11-20 | Update the startx chart dependencies to version 9.8.23                                                                        |
| 9.8.31   | 2021-11-21 | Align with all other chart version number 9.8.31                                                                              |
| 9.8.39   | 2021-11-21 | Debug version check with more permissive mode                                                                                 |
| 9.8.43   | 2021-11-21 | Update the startx chart dependencies to version 9.8.39                                                                        |
| 9.8.45   | 2021-11-21 | Update the values schema limits for context properties                                                                        |
| 9.8.47   | 2021-11-21 | Improve version management for chart                                                                                          |
| 9.8.48   | 2021-11-22 | Align with all other basic chart version to number 9.8.48                                                                     |
| 9.8.51   | 2021-11-22 | Update startx chart dependencies to version 9.8.48                                                                            |
| 9.8.52   | 2021-11-22 | Move to a cluster wide operator group scope for codeready-workspace values                                                    |
| 9.8.53   | 2021-12-06 | Add values-crw-2.13.100 for codeready-workspace                                                                               |
| 9.8.54   | 2021-12-06 | Disable hooked subscription mode for codeready-workspaces values                                                              |
| 9.8.59   | 2021-12-18 | Improve global label management                                                                                               |
| 9.8.67   | 2021-12-18 | Align all charts to release 9.8.67                                                                                            |
| 9.8.69   | 2021-12-18 | Refactor label and annotation go template library                                                                             |
| 9.8.71   | 2021-12-18 | Update helm-chart dependencies to version 9.8.59                                                                              |
| 9.8.72   | 2021-12-19 | Remove app.kubernetes.io/name from default label                                                                              |
| 9.8.75   | 2021-12-19 | Align with all other startx chart version to number 9.8.75                                                                    |
| 9.8.76   | 2021-12-19 | Change helm.sh/chart name                                                                                                     |
| 9.8.81   | 2021-12-20 | Update the storage context                                                                                                    |
| 9.8.91   | 2022-03-06 | publish stable update for the full repository                                                                                 |
| 9.8.93   | 2022-03-07 | Enable conditionnal loading of charts dependencies                                                                            |
| 9.8.107  | 2022-04-26 | Upgrade startx chart dependencies to version 9.8.107                                                                          |
| 9.8.109  | 2022-04-26 | Update startx chart dependencies to version 9.8.107                                                                           |
| 9.8.110  | 2022-04-27 | Stable release for all charts                                                                                                 |
| 9.8.111  | 2022-05-06 | Add support for the installPlanApproval                                                                                       |
| 9.8.211  | 2022-05-06 | Upgrade startx chart dependencies to version 9.8.211                                                                          |
| 9.8.215  | 2022-05-06 | Upgrade startx chart dependencies to version 9.8.211                                                                          |
| 9.8.230  | 2022-05-06 | Stable full repository                                                                                                        |
| 9.8.231  | 2022-05-06 | Debug basic chart dependencies                                                                                                |
| 9.8.233  | 2022-05-06 | publish stable update for the full repository                                                                                 |
| 9.8.234  | 2022-05-17 | Make csv properties optionnal. When used, will push a startingCSV property                                                    |
| 9.8.239  | 2022-05-17 | Remove default csv from all charts. global release 9.8.239                                                                    |
| 9.8.251  | 2022-05-29 | Align basic charts to release 9.8.251                                                                                         |
| 9.8.253  | 2022-05-29 | Align all charts dependencies to release 9.8.251                                                                              |
| 9.8.277  | 2022-05-31 | publish stable update for the full repository                                                                                 |
| 9.8.278  | 2022-05-31 | Improve operator options                                                                                                      |
| 9.15.1   | 2022-06-01 | Align all chart for Openshift 4.9.15                                                                                          |
| 9.15.2   | 2022-06-01 | Align all charts to release 9.15.1                                                                                            |
| 9.15.3   | 2022-06-01 | Align all charts to release 9.15.3                                                                                            |
| 10.12.1  | 2022-06-01 | Align all charts to release 10.12.1                                                                                           |
| 10.12.3  | 2022-06-01 | publish stable update for the full repository                                                                                 |
| 10.12.4  | 2022-06-01 | Align all charts to release 10.12.4                                                                                           |
| 10.12.5  | 2022-06-01 | publish stable update for the full repository                                                                                 |
| 10.12.22 | 2022-06-04 | Align all chart to release version 10.12.22                                                                                   |
| 10.12.23 | 2022-06-04 | Basi chart dependencies upgraded to version 10.12.5                                                                           |
| 10.12.29 | 2022-06-17 | publish stable update for the full repository                                                                                 |
| 10.12.30 | 2022-06-17 | Improved logo and global documentation                                                                                        |
| 10.12.31 | 2022-06-17 | align basic charts                                                                                                            |
| 10.12.33 | 2022-06-17 | publish stable update for the full repository                                                                                 |
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31                                                                                     |
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41                                                                                          |
| 10.12.46 | 2022-06-18 | publish stable update for the full repository                                                                                 |
| 10.12.49 | 2022-06-18 | publish stable update for the full repository                                                                                 |
| 10.12.53 | 2022-06-18 | publish stable update for the full repository                                                                                 |
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts                                                                                            |
| 10.12.72 | 2022-07-02 | Common release                                                                                                                |
| 10.12.77 | 2022-07-02 | Stable for clients                                                                                                            |
| 10.12.81 | 2022-07-02 | publish stable update for the full repository                                                                                 |
| 10.12.97 | 2022-07-03 | publish stable update for the full repository                                                                                 |
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart                                                                                      |
| 11.5.3   | 2022-09-17 | Align all STARTX charts to release 11.5.3                                                                                     |
| 11.7.1   | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release                                                              |
| 11.7.3   | 2022-10-02 | publish stable update for the full repository                                                                                 |
| 11.7.9   | 2022-10-02 | publish stable update for the full repository                                                                                 |
| 11.7.10 | 2022-10-02 | Stable release for all packages
| 11.7.11 | 2022-10-02 | publish stable update for the full repository
| 11.7.15 | 2022-10-02 | publish stable update for the full repository
| 11.7.17 | 2022-10-02 | publish stable update for the full repository
| 11.7.31 | 2022-10-29 | publish stable update for the full repository
| 11.7.33 | 2022-10-29 | Update all startx packages to release 11.7.33
| 11.7.41 | 2022-11-02 | publish stable update for the full repository
| 11.7.61 | 2022-11-30 | publish stable update for the full repository
| 11.7.62 | 2022-11-30 | Debug console links and notifications
| 11.7.63 | 2022-11-30 | publish stable update for the full repository
| 11.7.67 | 2022-11-30 | Debug depedencies on sub charts
| 11.7.69 | 2022-11-30 | Finished dependencies stabilization
| 11.7.73 | 2022-12-04 | Align all packages to release 11.7.73
| 11.7.75 | 2022-12-04 | publish stable update for the full repository
| 11.7.77 | 2022-12-05 | publish stable update for the full repository
| 11.7.87 | 2023-02-15 | publish stable update for the full repository
| 11.7.88 | 2023-02-15 | publish stable update for the full repository
| 11.7.89 | 2023-02-16 | Align basic charts to version 11.7.89
| 11.7.91 | 2023-02-16 | publish stable update for the full repository
| 11.7.93 | 2023-02-16 | align dependencies to version 11.7.89
| 11.7.97 | 2023-02-19 | publish stable update for the full repository
| 11.28.1 | 2023-02-19 | Upgrade workspace and tekton examples
| 11.28.7 | 2023-02-19 | Align all packages to release 11.28.7
| 11.28.11 | 2023-02-19 | publish stable update for the full repository
| 11.28.15 | 2023-02-19 | publish stable update for the full repository
| 11.28.16 | 2023-02-19 | publish stable update for the full repository
| 11.28.19 | 2023-02-19 | publish stable update for the full repository
| 11.28.21 | 2023-02-19 | Upgrade all dependencies packages to release 11.28.15
| 11.28.23 | 2023-02-21 | publish stable update for the full repository
| 11.28.25 | 2023-02-21 | Align basic chart packages to release 11.28.25
| 11.28.27 | 2023-02-21 | All chart aligned to release 11.28.27
| 11.28.29 | 2023-02-21 | publish stable update for the full repository
| 11.28.35 | 2023-02-21 | publish stable update for the full repository
| 11.28.49 | 2023-02-21 | publish stable update for the full repository
| 11.28.59 | 2023-02-21 | publish stable update for the full repository
| 11.28.60 | 2023-02-21 | publish stable update for the full repository
| 11.28.67 | 2023-02-23 | publish stable update for the full repository
| 11.28.69 | 2023-03-07 | publish stable update for the full repository
| 11.28.89 | 2023-04-01 | publish stable update for the full repository
| 11.28.93 | 2023-04-20 | publish stable update for the full repository
| 11.28.99 | 2023-04-21 | publish stable update for the full repository
| 11.28.103 | 2023-05-04 | publish stable update for the full repository
| 11.28.127 | 2023-06-12 | publish stable update for the full repository
| 11.28.128 | 2023-06-12 | publish stable update for the full repository
| 11.28.129 | 2023-06-13 | publish stable update for the full repository
| 11.28.201 | 2023-07-06 | publish stable update for the full repository
| 11.28.207 | 2023-07-06 | publish stable update for the full repository
| 11.28.230 | 2023-08-18 | Align all helm chart to release 11.28.230 stable release
| 11.30.0 | 2023-08-18 | Align all helm chart to release 11.30.0 stable for OCP 4.11.30
| 11.40.0 | 2023-08-18 | Align all helm chart to release 11.40.0 stable for OCP 4.11.40
| 11.47.0 | 2023-08-18 | Align all helm chart to release 11.47.0 stable for OCP 4.11.47
| 11.47.1 | 2023-08-18 | Update appVersion in Chart.yml
| 12.0.0 | 2023-08-18 | Align all helm chart to release 12.0.0 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.1 | 2023-08-18 | Align all helm chart to release 12.0.1 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.5 | 2023-08-18 | publish stable update for the full repository
| 12.0.11 | 2023-08-18 | publish stable update for the full repository
| 12.30.1 | 2023-09-29 | release 12.30.1 aligned and tested with OCP 4.12.30
| 12.36.1 | 2023-09-29 | release 12.36.0 aligned with OCP 4.12.36 (unstable)
| 12.36.9 | 2023-10-01 | publish stable update for the full repository
| 12.36.36 | 2023-10-11 | publish stable update for the full repository
| 12.36.49 | 2023-11-13 | publish stable update for the full repository
| 12.36.51 | 2023-11-13 | publish stable update for the full repository
| 12.36.58 | 2023-11-13 | Align all startx dependencies packages to version 12.36.49 stable for OCP 4.12.36
| 12.36.59 | 2023-11-13 | publish stable update for the full repository
| 12.36.63 | 2023-11-13 | publish stable update for the full repository
| 12.36.64 | 2023-11-13 | publish stable update for the full repository

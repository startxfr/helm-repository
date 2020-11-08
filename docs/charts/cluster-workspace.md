# STARTX helm : cluster-workspace

This helm chart is used to configure code ready workspace via it's operator and deploy a cheCluster.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration
state orchestrated by gitops tools like ArgoCD.

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

## Default values

Deployment of codeready-workspace environment with :

- 1 **project** named **openshift-workspaces** with the following characteristics
  - **rbac** set to **view** for group **dev**
  - no limitRange
  - no Quotas
  - no NetworkPolicy
- 1 **operatorGroup** named **openshift-workspaces** to enable codeready operator
- 1 **subscription** named **codeready-workspaces** to deploy codeready operator with the following characteristics
  - operator name is **codeready-workspaces**
  - operator version is **2.3.0**
  - operator catalog is **redhat-operators** located in **openshift-marketplace**
- 1 **cheCluster** named **codeready-workspaces** with the following characteristics
  - storage class **gp2**
  - storage size defined to **1Gi**

```bash
# base configuration running default configuration
helm install startx/cluster-workspace
```

## Others values availables

- **startx** : Startx codeready-workspace configuration for Startx clusters (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-workspace/values-startx.yaml)) deploying the following environment
  - 1 **project** named **openshift-workspaces** with the following characteristics
    - **rbac** set to **view** for group **dev**
    - no limitRange
    - no Quotas
    - no NetworkPolicy
  - 1 **operatorGroup** named **openshift-workspaces** to enable codeready operator
  - 1 **subscription** named **codeready-workspaces** to deploy codeready operator with the following characteristics
    - operator name is **codeready-workspaces**
    - operator version is **2.3.0**
    - operator catalog is **redhat-operators** located in **openshift-marketplace**
  - 1 **cheCluster** named **codeready-workspaces** with the following characteristics
    - storage class **aws-generic-retain**
    - storage size defined to **1Gi**

```bash
helm install startx/cluster-workspace -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-workspace/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.12  | 2020-10-25 | Initial commit for this helm chart with default value example (removed)
| 0.2.15  | 2020-10-26 | Improve cluster-workspace operator config
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.29  | 2020-11-07 | Improve NOTES output and move to 0.3.25 dependencies
| 0.3.37  | 2020-11-07 | Improve helm hook ordering cordinated with dependencies
| 0.3.38  | 2020-11-08 | Improve cluster-workspace options
| 0.3.39  | 2020-11-08 | Improve cluster-workspace options
| 0.3.40  | 2020-11-08 | Improve cluster-workspace options
| 0.3.45  | 2020-11-08 | Align all helm charts to version 0.3.45
| 0.3.47  | 2020-11-08 | publish stable update for the full repository

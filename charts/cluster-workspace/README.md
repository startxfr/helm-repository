# STARTX helm : cluster-workspace

This helm chart is used to configure code ready workspace via it's operator and deploy a cheCluster.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration
state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### Get information about this chart

```bash
helm show chart startx/cluster-workspace
```

### Install this chart

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
| 0.0.1   | 2020-09-14 | Initial commit for this repository
| 0.3.0   | 2020-10-25 | Create cluster-workspace chart
| 0.2.11  | 2020-10-25 | publish stable update for the full repository
| 0.2.12  | 2020-10-25 | Add cluster-workspace project dependencies
| 0.2.15  | 2020-10-26 | Improve cluster-workspace operator config
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release
| 0.2.35  | 2020-10-26 | Move to startx/project version 0.2.33

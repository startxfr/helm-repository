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
| 0.0.1   | 2020-10-01 | Initial commit
| 0.1.0   | 2020-10-07 | Release 0.1 stable release for all charts
| 0.1.14  | 2020-10-23 | Improve documentation
| 0.2.0   | 2020-10-24 | Stable startx helm base config
| 0.2.1   | 2020-10-24 | publish stable update for the full repository
| 0.2.2   | 2020-10-24 | Repository update with all chart release
| 0.2.5   | 2020-10-24 | Unstable repository global update
| 0.2.7   | 2020-10-24 | Unstable repository release
| 0.2.9   | 2020-10-24 | Update demo charts
| 0.3.0  | 2020-10-25 | Improve cluster-workspace options
| 0.2.11  | 2020-10-25 | publish stable update for the full repository
| 0.2.12  | 2020-10-25 | Improve cluster-workspace options
| 0.2.13  | 2020-10-25 | Improve cluster-workspace options
| 0.2.14  | 2020-10-26 | Improve cluster-workspace options
| 0.2.15  | 2020-10-26 | Improve cluster-workspace options
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22

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
| 0.2.12  | 2020-10-25 | Initial commit for this helm chart with default value example (removed)
| 0.2.15  | 2020-10-26 | Improve cluster-workspace operator config
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release
| 0.2.35  | 2020-10-26 | Move to startx/project version 0.2.33
| 0.2.36  | 2020-10-31 | Move operator management to the helm chart startx/operator dependency (removed)
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.2.94  | 2020-10-31 | Aligned stable release of all startx charts
| 0.2.96  | 2020-10-31 | Stable version 0.2.96 preparing the 0.3 release
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.5   | 2020-11-01 | Update dependency to 0.3.3 release and improve Note display
| 0.3.17  | 2020-11-01 | Synchronize releases for all chart in the startx repository
| 0.3.20  | 2020-11-06 | Add v prefix to the operator version
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information

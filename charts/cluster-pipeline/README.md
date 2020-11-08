# STARTX helm : cluster-pipeline

This helm chart is used to configure tekton via it's operator.
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
helm show chart startx/cluster-pipeline
```

### 4. Install this chart

```bash
helm install startx/cluster-pipeline
```

## Default values

Deployment of tekton :

- 1 **subscription** named **openshift-pipelines-operator-rh** to deploy codeready operator with the following characteristics
  - operator name is **openshift-pipelines-operator-rh**
  - operator version is **openshift-pipelines-operator.v1.0.1**
  - operator catalog is **redhat-operators** located in **openshift-marketplace**

```bash
# base configuration running default configuration
helm install startx/cluster-pipeline
```

## Others values availables

- **startx** : Startx tekton configuration for Startx clusters (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-pipeline/values-startx.yaml)) deploying the following environment
  - 1 **subscription** named **openshift-pipelines-operator-rh** to deploy codeready operator with the following characteristics
    - operator name is **openshift-pipelines-operator-rh**
    - operator version is **openshift-pipelines-operator.v1.0.1**
    - operator catalog is **redhat-operators** located in **openshift-marketplace**

```bash
helm install startx/cluster-pipeline -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-pipeline/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.13  | 2020-10-25 | Initial commit for this helm chart with default value example (removed)
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.29  | 2020-11-07 | Improve NOTES output and move to 0.3.25 dependencies
| 0.3.34  | 2020-11-08 | Improve cluster-pipeline options
| 0.3.35  | 2020-11-08 | Improve cluster-pipeline options
| 0.3.36  | 2020-11-08 | Improve cluster-pipeline options
| 0.3.45  | 2020-11-08 | Align all helm charts to version 0.3.45

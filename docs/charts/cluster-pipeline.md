# STARTX helm : cluster-pipeline

This helm chart is used to configure tekton via it's operator.
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
helm show chart startx/cluster-pipeline
```

### Install this chart

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
| 0.2.15  | 2020-10-26 | Improve cluster-pipeline options
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release
| 0.2.36  | 2020-10-31 | Move operator management to the helm chart startx/operator dependency (removed)
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.2.94  | 2020-10-31 | Aligned stable release of all startx charts
| 0.2.94  | 2020-10-31 | Aligned stable release of all startx charts
| 0.2.96  | 2020-10-31 | Stable version 0.2.96 preparing the 0.3 release
| 0.2.96  | 2020-10-31 | Stable version 0.2.96 preparing 0.3 release

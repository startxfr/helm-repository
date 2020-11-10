# STARTX helm : cluster-metering

This helm chart is used to configure Metering at the cluster level.
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
helm show chart startx/cluster-metering
```

### 4. Install this chart

```bash
helm install startx/cluster-metering
```

## Default values

Complete deployment of a project with the following characteristics :

xxxx to do xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-metering
```

## Others values availables

- **startx** : metering cluster wide service configuration using metering operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-metering/values-startx.yaml))

```bash
helm install startx/cluster-metering -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-metering/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.19  | 2020-11-06 | Create chart cluster-metering from cluster-ocs
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.29  | 2020-11-07 | Improve NOTES output and move to 0.3.25 dependencies
| 0.3.47  | 2020-11-08 | Update dependency to 0.3.45 release
| 0.3.50  | 2020-11-08 | publish stable update for the full repository
| 0.3.53  | 2020-11-08 | publish stable update for the full repository
| 0.3.59  | 2020-11-08 | publish stable update for the full repository
| 0.3.61  | 2020-11-09 | Improve repository documentation and new chart for kubevirt management
| 0.3.73  | 2020-11-10 | publish stable update for the full repository
| 0.3.75  | 2020-11-10 | publish stable update for the full repository
| 0.3.77  | 2020-11-10 | publish stable update for the full repository
| 0.3.83  | 2020-11-10 | publish stable update for the full repository
| 0.3.93  | 2020-11-10 | Move to 0.3.93 dependencies for all cluster-xxx charts in the startx repository

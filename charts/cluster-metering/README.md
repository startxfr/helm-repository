# Cluster metering

This helm chart is used to configure Metering at the cluster level.
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
| 0.3.93  | 2020-11-10 | Move to 0.3.93 dependencies for all cluster-xxx charts in the startx repository
| 0.3.105 | 2020-11-11 | Update cluster-xxx charts dependencies to 0.3.103 release
| 0.3.117 | 2020-11-12 | Move to 0.3.115 basic chart dependencies
| 0.3.135 | 2020-11-23 | Improve documentation for all examples charts
| 0.3.141 | 2020-11-24 | publish stable update for the full repository
| 0.3.151 | 2021-01-23 | Upgrade to Metering version 4.6.0
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13
| 0.3.153 | 2021-01-23 | publish stable update for the full repository
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies
| 0.3.187 | 2021-02-13 | Align cluster chart release to 0.3.187          
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts
| 0.3.201 | 2021-02-20 | Update icon and image for charts
| 0.3.203 | 2021-02-21 | Upgrade chart release informations
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming
| 0.3.226 | 2021-06-02 | Update metering operator (end of active support) to version 4.7.0
| 0.3.303 | 2021-06-02 | Update documentation and align all charts to release 0.3.303
| 0.3.311 | 2021-06-03 | Align cluster chart to version 0.3.311
| 0.3.305 | 2021-06-04 | publish stable update for the full repository
| 0.3.315 | 2021-06-04 | Stable documentation for all charts
| 0.3.317 | 2021-06-04 | Improve documentation

# Cluster compliance

This helm chart is used to deploy Compliance instances managed by a dedicated operator.
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
helm show chart startx/cluster-compliance
```

### 4. Install this chart

```bash
helm install startx/cluster-compliance
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-compliance
```

## Others values availables

- **startx** : Compliance operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-compliance/values-startx.yaml))

```bash
helm install startx/cluster-compliance -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-compliance/values-startx.yaml
```

## History

| Release | Date       | Description                                      |
| ------- | ---------- | ------------------------------------------------ |
| 0.3.179 | 2021-02-10 | Create chart cluster-compliance from cluster-ptp |
| 0.3.187 | 2021-02-13 | Align cluster chart release to 0.3.187           |
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts
| 0.3.201 | 2021-02-20 | Update icon and image for charts
| 0.3.203 | 2021-02-21 | Upgrade chart release informations
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming
| 0.3.226 | 2021-06-02 | Update to compliance operator version 0.1.32
| 0.3.303 | 2021-06-02 | Update documentation and align all charts to release 0.3.303
| version: 0.3.3110.3.304 | 2021-06-03 | Align cluster chart to version 0.3.311
| 0.3.305 | 2021-06-04 | publish stable update for the full repository
| 0.3.315 | 2021-06-04 | Stable documentation for all charts
| 0.3.317 | 2021-06-04 | Improve documentation

# Cluster couchbase

This helm chart is used to deploy Couchbase instances managed by a dedicated operator.
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
helm show chart startx/cluster-couchbase
```

### 4. Install this chart

```bash
helm install startx/cluster-couchbase
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-couchbase
```

## Others values availables

- **startx** : Couchbase operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-couchbase/values-startx.yaml))

```bash
helm install startx/cluster-couchbase -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-couchbase/values-startx.yaml
```

## History

| Release | Date       | Description                                 |
| ------- | ---------- | ------------------------------------------- |
| 0.3.187 | 2021-02-13 | Create cluster-couchbase skeleton from cluster-vault
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189
| 0.3.193 | 2021-02-16 | Support for couchbase cluster deployment
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts
| 0.3.201 | 2021-02-20 | Update icon and image for charts
| 0.3.203 | 2021-02-21 | Upgrade chart release informations
| 0.3.205 | 2021-02-21 | Add support for couchbase RBAC
| 0.3.206 | 2021-02-21 | Improve cluster-couchbase options
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming
| 0.3.303 | 2021-06-02 | Update documentation and align all charts to release 0.3.303
| 0.3.311 | 2021-06-03 | Align cluster chart to version 0.3.311
| 0.3.305 | 2021-06-04 | publish stable update for the full repository
| 0.3.315 | 2021-06-04 | Stable documentation for all charts
| 0.3.317 | 2021-06-04 | Improve documentation

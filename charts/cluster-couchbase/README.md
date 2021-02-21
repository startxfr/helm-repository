# STARTX helm : cluster-couchbase

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

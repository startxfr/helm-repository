# Cluster mustgather

This helm chart is used to configure MustGather at the cluster level.
This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-mustgather
```

### 4. Install this chart

```bash
helm install cluster-mustgather startx/cluster-mustgather
```

## Default values

Complete deployment of a project with the following characteristics :

xxxx to do xxxxxx

```bash
# base configuration running default configuration
helm install cluster-mustgather startx/cluster-mustgather
```

## Others values availables

- **startx** : mustgather cluster wide service configuration using mustgather operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mustgather/values-startx.yaml))

```bash
helm install cluster-mustgather startx/cluster-mustgather -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mustgather/values-startx.yaml
```

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 14.6.61 | 2023-12-22 | create
| 14.6.61 | 2023-12-22 | Create cluster-mustgather chart
| 14.6.63 | 2023-12-22 | Align all startx helm-chart to version 14.6.63
| 14.6.65 | 2023-12-27 | test with repo stored in s3 public bucket

# Cluster Chart : MustGather

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
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable/
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
| 14.6.71 | 2023-12-28 | Move to S3 helm repository
| 14.6.71-noschema | 2023-12-28 | full build from s3 helm repo
| 14.6.73-noschema | 2023-12-29 | Upgrade all startx chart dependencies to version 14.6.71-noschema
| 14.6.75-noschema | 2023-12-29 | publish stable update for the full repository
| 14.6.99-noschema | 2024-01-02 | Stable noschema version for 14.6 release

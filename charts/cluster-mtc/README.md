# Cluster Chart : MTC [![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--mtc-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+mtc+startx)

This helm chart is used to deploy Migration Toolkit for Containers operator to help you drive migration of your VM workloads into a Kubevirt enabled kubernetes cluster.

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
helm show chart startx/cluster-mtc
```

### 4. Install this chart

```bash
helm install cluster-mtc startx/cluster-mtc
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-mtc startx/cluster-mtc
```

## Others values availables

- **startx** : MTC operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mtc/values-startx.yaml))

```bash
helm install cluster-mtc startx/cluster-mtc -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mtc/values-startx.yaml
```

## History

| Release  | Date       | Description                              |
| -------- | ---------- | ---------------------------------------- |
| 14.6.281 | 2024-05-29 | Initialize the MTC cluster-service chart |
| 14.6.283 | 2024-05-29 | Update shcema and startx values
| 14.6.293 | 2024-05-29 | Align all charts to release 14.6.293
| 14.6.301 | 2024-05-30 | Helm package are now signed
| 14.6.321 | 2024-06-25 | publish stable update for the full repository
| 14.6.323 | 2024-06-25 | Align all chart to latest release

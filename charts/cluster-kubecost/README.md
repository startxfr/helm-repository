# ![cluster-kubecost](https://helm-repository.readthedocs.io/en/latest/img/cluster-kubecost.svg "Cluster Chart : Kubecost") Cluster Chart : Kubecost
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--kubecost-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+kubecost+startx)

This helm chart is used to deploy Kubecost handled by an operator to configure cluster cost observability and billing.

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
helm show chart startx/cluster-kubecost
```

### 4. Install this chart

```bash
helm install cluster-kubecost startx/cluster-kubecost
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-kubecost startx/cluster-kubecost
```

## Others values availables

- **startx** : Kubecost operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kubecost/values-startx.yaml))

```bash
helm install cluster-kubecost startx/cluster-kubecost -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kubecost/values-startx.yaml
```

## History

| Release  | Date       | Description                                    |
| -------- | ---------- | ---------------------------------------------- |
| 16.19.31 | 2025-02-27 | Create chart cluster-kubecost from cluster-ptp |

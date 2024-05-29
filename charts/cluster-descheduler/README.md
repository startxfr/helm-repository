# Cluster Chart : Descheduler [![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--descheduler-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+descheduler+startx)

This helm chart is used to deploy the KubeDescheduler operator to help you evict pods based on specific strategies so that the pods can be rescheduled onto more appropriate nodes.

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
helm show chart startx/cluster-descheduler
```

### 4. Install this chart

```bash
helm install cluster-descheduler startx/cluster-descheduler
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-descheduler startx/cluster-descheduler
```

## Others values availables

- **startx** : descheduler operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-descheduler/values-startx.yaml))

```bash
helm install cluster-descheduler startx/cluster-descheduler -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-descheduler/values-startx.yaml
```

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 14.6.283 | 2024-05-29 | Initialize the descheduler cluster-service chart

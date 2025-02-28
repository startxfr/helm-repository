# ![cluster-kepler](https://helm-repository.readthedocs.io/en/latest/img/cluster-kepler.svg "Cluster Chart : Kepler") Cluster Chart : Kepler
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--kepler-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+kepler+startx)

This helm chart is used to deploy Kepler handled by an operator to configure cluster cost observability and billing.

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
helm show chart startx/cluster-kepler
```

### 4. Install this chart

```bash
helm install cluster-kepler startx/cluster-kepler
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-kepler startx/cluster-kepler
```

## Others values availables

- **startx** : Kepler operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kepler/values-startx.yaml))

```bash
helm install cluster-kepler startx/cluster-kepler -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kepler/values-startx.yaml
```

## History

| Release  | Date       | Description                                    |
| -------- | ---------- | ---------------------------------------------- |
| 16.19.31 | 2025-02-27 | Create chart cluster-kepler from cluster-kubecost |
| 16.19.43 | 2025-02-27 | publish stable update for the full repository
| 17.14.1 | 2025-02-28 | Initial release for v17.x version

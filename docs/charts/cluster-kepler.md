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

!!! todo
    Complete this section

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
| 17.14.3 | 2025-02-28 | Temporary release used to prepare dependencies changes
| 17.14.5 | 2025-02-28 | Align all startx helm dependencies to release 17.14.1
| 17.14.11 | 2025-03-05 | Adjust doc to material layout
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version
| 18.11.3 | 2025-04-30 | Prepare dependencies move to version 18.x
| 18.11.5 | 2025-04-30 | move dependencies to version 18.11.1
| 18.11.7 | 2025-04-30 | All dependencies linked to 18.x release
| 18.11.9 | 2025-05-01 | Update kepler operator to version 0.4.0
| 18.11.19 | 2025-05-02 | Intermediate alignement of all helm charts
| 18.11.21 | 2025-05-02 | Update all basic chart dependencies to version 18.11.15
| 18.11.22 | 2025-05-02 | Add noinfra values in all charts
| 18.11.24 | 2025-05-02 | Align all to stable version

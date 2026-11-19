# ![cluster-ods](https://helm-repository.readthedocs.io/en/latest/img/cluster-ods.svg "Cluster Chart : ODS") Cluster Chart : RedHat ODS
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--ods-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+ods+startx)

This helm chart is used to configure OpenDataScience at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

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
helm show chart startx/cluster-ods
```

### 4. Install this chart

```bash
helm install cluster-ods startx/cluster-ods
```

## Default values

Complete deployment of a project with the following characteristics :

Complete deployment of an OpenShift Data Science (ODS) configuration with the following characteristics :

- 1 **operator** named **rhods-operator** deployed under **redhat-ods-operator**
- 1 **DataScienceCluster** instance enabling ML/AI tooling and notebook environments

```bash
# base configuration running default configuration
helm install cluster-ods startx/cluster-ods
```

### DataScienceCluster and DSCInitialization API version

The `DataScienceCluster` and `DSCInitialization` resources use the `v2` API (`datasciencecluster.opendatahub.io/v2`, `dscinitialization.opendatahub.io/v2`), required by RHOAI 3.x. Set `DataScienceCluster.apiVersion` (or `DSCInitialization.apiVersion`) to the `v1` API for RHOAI 2.x, and adapt `DataScienceCluster.spec` accordingly: the default `spec` lists the components of RHOAI 2.x, so with the `v2` API replace it with the components of your RHOAI release. The `OperatorGroup` `providedAPIs` list both the `v1` and `v2` APIs. Set `DataScienceCluster.clusterScoped: true` to omit the `metadata.namespace` that the cluster scoped `DataScienceCluster` does not need (it is rendered by default). `values-startx_noinfra-rhoai3.yaml` is an overlay with a `DSCInitialization` and a `DataScienceCluster` spec for RHOAI 3.x, taken from a cluster running rhods-operator 3.6.0-ea.2: use it after `values-startx_noinfra.yaml` and check its components against your RHOAI release. Both resources accept `labels` and `annotations` maps. `DSCInitialization.enabled` creates a cluster scoped `DSCInitialization` (free `spec`, `applicationsNamespace` overrides `spec.applicationsNamespace`) before the `DataScienceCluster`.

## Other available values

- **startx** : rh-ods cluster wide service configuration using rh-ods operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ods/values-startx.yaml))

```bash
helm install cluster-ods startx/cluster-ods -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ods/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-ods/examples/argocd/
oc apply -k .
```

### Applications



## History

| Release  | Date       | Description                                                                                           |
| -------- | ---------- | ----------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release                                                               |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.12 | 2026-06-19 | Improve cluster-ods options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.370 | 2026-11-18 | publish stable update for the full repository |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.372 | 2026-11-19 | update basic dependencies to v21.3.371 |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.378 | 2026-11-19 | clusterScoped option and RHOAI 3.x overlay; Sail operator values, tracked Chart.lock |

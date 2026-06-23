# ![cluster-acm](https://helm-repository.readthedocs.io/en/latest/img/cluster-acm.svg "Cluster Chart : ACM") Cluster Chart : Advanced Cluster Management
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--acm-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+acm+startx)

This helm chart is used to deploy Advanced Cluster Management (ACM) handled by an operator to configure multi-cluster management capabilities at the cluster level.

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
helm show chart startx/cluster-acm
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **open-cluster-management** with the following properties
  - 1 **LimitRange:** defined for this project
  - 1 **Quotas:** defined for this project
  - 3 **RBAC:** allowing **mygroup_example** to **edit** resources
- 1 **operator:** named **advanced-cluster-management** configured with
  - The **release-2.13** channel
  - The **2.13.2** version
  - Deployed under the **open-cluster-management** project
- 1 **mch:** named **default-mch** configured with
  - **hive** enabled
  - **ingress** enabled

```bash
# base configuration running default configuration
helm install cluster-acm startx/cluster-acm
```

#### Other available values

- **startx** : Startx ACM cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx.yaml))

```bash
helm install cluster-acm startx/cluster-acm -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-acm` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject.
The ACM operator and the MultiClusterHub CR both install in `openshift-acm-operator` (ACM requires the MCH in the same namespace as the operator).
Observability resources deploy in `startx-acm-observability`:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-acm/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## History

### Archives

| Release   | Date       | Description                                                                                                             |
| --------- | ---------- | ----------------------------------------------------------------------------------------------------------------------- |
### Actives

| Release  | Date       | Description                                                    |
| -------- | ---------- | -------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.15 | 2026-03-02 | Prepare upgrading dependency to 19.23.11 |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.7 | 2026-03-02 | Update dependencies to version 20.14.0 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.1 | 2026-03-02 | Prepare release 21.3.x with 21.x dependencies |
| 21.3.3 | 2026-03-02 | Upgrade dependencies to v21.3.0 |
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.12 | 2026-06-18 | Update cluster-acm operator and improve argocd examples |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |
| 21.3.107 | 2026-06-21 | publish stable update for the full repository |
| 21.3.167 | 2026-06-23 | publish stable update for the full repository |
| 21.3.181 | 2026-06-23 | publish stable update for the full repository |
| 21.3.182 | 2026-06-23 | publish stable update for the full repository |

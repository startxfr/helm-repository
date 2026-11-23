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

## Values files

Example values files shipped with the chart, to use with `helm install -f <file>` :

- **startx-acm** : context `startx/default/infra`; against `values.yaml`: differ on 103 keys, by top-level key: `operator` (21), `observability` (18), `create` (17), `project` (16), ... (see [values-startx-acm.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx-acm.yaml))
- **startx-create** : context `startx/default/infra`; against `values.yaml`: differ on 93 keys, by top-level key: `operator` (20), `observability` (18), `projectObservability` (14), `project` (11), ... (see [values-startx-create.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx-create.yaml))
- **startx-import** : context `startx/default/infra`; against `values.yaml`: differ on 98 keys, by top-level key: `operator` (20), `observability` (18), `create` (17), `projectObservability` (14), ... (see [values-startx-import.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx-import.yaml))
- **startx-observability** : context `startx/default/infra`; against `values.yaml`: differ on 93 keys, by top-level key: `operator` (20), `create` (17), `project` (16), `projectObservability` (10), ... (see [values-startx-observability.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx-observability.yaml))
- **startx-requirements** : context `startx/default/infra`; against `values.yaml`: differ on 84 keys, by top-level key: `observability` (18), `create` (17), `projectObservability` (14), `import` (9), ... (see [values-startx-requirements.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx-requirements.yaml))
- **startx_noinfra-acm** : context `startx/default/infra`; against `values-startx-acm.yaml`: differ on `acm.infra` (true → false), `operator.config.infra` (true → false) (see [values-startx_noinfra-acm.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx_noinfra-acm.yaml))
- **startx_noinfra-observability** : context `startx/default/infra`; against `values-startx-observability.yaml`: differ on `observability.infra` (true → false) (see [values-startx_noinfra-observability.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx_noinfra-observability.yaml))
- **startx_noinfra-requirements** : context `startx/default/infra`; against `values-startx-requirements.yaml`: differ on `operator.config.infra` (true → false), `operator.subscription.operator.config.infra` (true → false) (see [values-startx_noinfra-requirements.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx_noinfra-requirements.yaml))
- `examples/argocd/` : 5 example manifest(s) (see the ArgoCD or usage sections)

```bash
helm install cluster-acm startx/cluster-acm -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acm/values-startx-acm.yaml
```

## Deploy with ArgoCD

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
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.12 | 2026-06-18 | Update cluster-acm operator and improve argocd examples |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |
| 21.3.412 | 2026-11-22 | full repository release: internal pins on the previous published version (ADR-0006) |
| 21.3.416 | 2026-11-23 | stable update: chart fixes (project, cluster-mongo, cluster-oadp, cluster-pipeline, cluster-machine, example-catalog); cluster-dvo accepts the grafana keys next to graphana, which keeps priority |

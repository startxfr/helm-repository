# ![cluster-3scale](https://helm-repository.readthedocs.io/en/latest/img/cluster-3scale.svg "Cluster Chart : 3Scale") Cluster Chart : 3Scale (API Management)
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--3scale-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+3scale+startx)

This helm chart is used to create a deployment of a 3scale, operator based, deployment of 3Scale API management tools.

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
helm show chart startx/cluster-3scale
```

### 4. Install this chart

```bash
helm install cluster-3scale startx/cluster-3scale
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **startx-3scale** with the following properties
  - 1 **LimitRange:** defined for this project
  - 1 **Quotas:** defined for this project
  - 3 **RBAC:** allowing **mygroup_example** to **edit** resources
- 1 **operator:** named **3scale-operator** configured with
  - The **threescale-2.13** channel
  - The **0.10.5** version
  - Deployed under the **openshift-operators** project
  - The **manager** deployed
- 1 **Secret:** named **startx-3scale-rhn** that hold rhn credentials used fo image pulling

```bash
# base configuration running default configuration
helm install cluster-3scale startx/cluster-3scale
```

## Values files

- **startx** : Startx 3scale cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-3scale/values-startx.yaml))

```bash
helm install cluster-3scale startx/cluster-3scale -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-3scale/values-startx.yaml
```

## Deploy with ArgoCD

Deploy `cluster-3scale` using three dedicated ArgoCD Applications sharing the same AppProject.
The 3scale operator runs in `openshift-operators` (all-namespaces scope); APIManager instances are deployed in `startx-3scale`.

> **3scale 2.16+ requires external databases.** The optional `clusterRedis` and `clusterCrunchy` sub-chart dependencies deploy a Redis cluster and a CrunchyDB PostgreSQL cluster, and `externalComponents` wires them into the APIManager via secrets (`system-redis`, `backend-redis`, `system-database`, `zync`).

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-3scale/examples/argocd/
oc apply -k .
```

> **Passwords**: update `externalComponents.database.password`, `externalComponents.zync.password`, and `externalComponents.zync.secretKeyBase` in your ArgoCD Application values (or use a Sealed Secret / ExternalSecret). The `initScript` in `clusterCrunchy.cluster.list[0]` must use the **same passwords**.

> **Node selector**: the 3scale operator deployment requests `node-role.kubernetes.io/infra` nodes. On clusters without dedicated infra nodes, set `operator.subscription.operator.config.infra: false` in the `-operator` Application values.

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.4 | 2026-03-03 | Upgrade to operator v0.10.5 |
| 21.3.12 | 2026-06-18 | Improve cluster-3scale options |
| 21.3.57 | 2026-06-20 | Auto-create openshift-crunchy-pgo namespace in project wave; fix secrets leaking into operator wave |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.373 | 2026-11-19 | align inter-chart dependency pins |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |

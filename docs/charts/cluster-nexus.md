# ![cluster-nexus](https://helm-repository.readthedocs.io/en/latest/img/cluster-nexus.svg "Cluster Chart : Nexus") Cluster Chart : nexus
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--nexus-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+nexus+startx)

This helm chart is used to deploy Nexus instances managed by a dedicated operator.

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
helm show chart startx/cluster-nexus
```

### 4. Install this chart

```bash
helm install cluster-nexus startx/cluster-nexus
```

## Default values

Complete deployment with the following characteristics:

- Deploy a **Subscription** named `nexus-repository-ha-operator-certified` in `openshift-operators`
- Deploy an **OperatorGroup** named `global-operators` in `openshift-operators` (all-namespaces scope)
- The `project` sub-chart is disabled - `openshift-operators` is a pre-existing system namespace

```bash
# base configuration running default configuration
helm install cluster-nexus startx/cluster-nexus
```

## Values files

- **startx** : Nexus operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nexus/values-startx.yaml))

```bash
helm install cluster-nexus startx/cluster-nexus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nexus/values-startx.yaml
```

## Deploy with ArgoCD

### Deploy via ArgoCD Application

Create an ArgoCD `Application` resource to deploy `cluster-nexus` from the STARTX S3 Helm repository.
This example deploys the Nexus HA operator in `openshift-operators` (all-namespaces scope).
The `project` sub-chart is disabled since `openshift-operators` is a pre-existing system namespace:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-nexus/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles the Nexus Repository operator whenever the chart or values drift from the desired state.

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.14 | 2026-06-17 | Improve schema for nexus |
| 21.3.16 | 2026-06-17 | Improve cluster-nexus options |
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

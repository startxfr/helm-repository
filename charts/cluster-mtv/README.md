# ![cluster-mtv](https://helm-repository.readthedocs.io/en/latest/img/cluster-mtv.svg "Cluster Chart : MTV") Cluster Chart : MTV [![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--mtv-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+mtv+startx)

This helm chart is used to deploy Migration Toolkit for Virtualisation operator to help you drive migration of your VM workloads into a Kubevirt enabled kubernetes cluster.

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
helm show chart startx/cluster-mtv
```

### 4. Install this chart

```bash
helm install cluster-mtv startx/cluster-mtv
```

## Default values

Complete deployment of a project with the following characteristics :

!!! todo
    Complete this section

```bash
# base configuration running default configuration
helm install cluster-mtv startx/cluster-mtv
```

## Values files

- **startx** : MTV operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mtv/values-startx.yaml))

```bash
helm install cluster-mtv startx/cluster-mtv -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mtv/values-startx.yaml
```

### Other values files

Values files without a detailed section above (each one is a complete set of values for `helm install cluster-mtv startx/cluster-mtv -f <file>`) :

- [values-demo.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mtv/values-demo.yaml) : context `startx/default/infra`; against `values-startx.yaml`: differ on 31 keys, by top-level key: `operator` (18), `mtv` (8), `project` (4), `context` (1)
- [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mtv/values-startx_noinfra.yaml) : context `startx/default/infra`; against `values-startx.yaml`: differ on `operator.subscription.operator.config.infra` (true → false)

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-mtv/examples/argocd/
oc apply -k .
```

### Applications

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
| 21.3.4 | 2026-06-17 | Improve default values |
| 21.3.12 | 2026-06-19 | Improve cluster-mtv options |
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
| 21.3.416 | 2026-11-23 | stable update: chart fixes (project, cluster-mongo, cluster-oadp, cluster-pipeline, cluster-machine, example-catalog); cluster-dvo accepts the grafana keys next to its historical keys, which keep priority |

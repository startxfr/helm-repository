# ![cluster-kargo](https://helm-repository.readthedocs.io/en/latest/img/cluster-kargo.svg "Cluster Chart : Kargo") Cluster Chart : Kargo
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--kargo-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+kargo+startx)

This helm chart is used to deploy Kargo tool used to manage and automate the promotion of stage lifecycle using GitOps principles.

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
helm show chart startx/cluster-kargo
```

### 4. Install this chart

```bash
helm install cluster-kargo startx/cluster-kargo
```

## Default values

Complete deployment of a project with the following characteristics :

!!! todo
    Complete this section

```bash
# base configuration running default configuration
helm install cluster-kargo startx/cluster-kargo
```

## Other available values

- **startx** : Kargo chart (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kargo/values-startx.yaml))

```bash
helm install cluster-kargo startx/cluster-kargo -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kargo/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-kargo/examples/argocd/
oc apply -k .
```

### Applications



## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 21.3.5  | 2026-04-10 | Create chart cluster-kargo from cluster-ptp                                                     |
| 21.3.12 | 2026-06-18 | Upgrade Kargo to v1.10.7 and add ArgoCD examples |
| 21.3.13 | 2026-06-18 | Improve cluster-kargo options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-20 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |

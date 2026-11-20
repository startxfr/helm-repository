# ![cluster-dvo](https://helm-repository.readthedocs.io/en/latest/img/cluster-dvo.svg "Cluster Chart : DVO") Cluster Chart : DVO
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--dvo-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+dvo+startx)

This helm chart is used to deploy the Deployment Validation Operator (DVO). This operator checks deployments and other resources against a curated collection of best practices.

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
helm show chart startx/cluster-dvo
```

### 4. Install this chart

```bash
helm install cluster-dvo startx/cluster-dvo
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **operator:** named **deployment-validation-operator** configured with
  - The **alpha** channel for community release
  - The **v0.7.14** version
  - Deployed under **openshift-operators** (AllNamespaces — DVO watches all namespaces)

```bash
# Create the project
helm install cluster-dvo-project startx/cluster-dvo --set project.enabled=true,operator.enabled=false,dvo.enabled=false
# Deploy the DVO operator
helm install cluster-dvo-operator startx/cluster-dvo --set project.enabled=false,operator.enabled=true,dvo.enabled=false && sleep 10
# Configure default DVO resources
helm install cluster-dvo-instance startx/cluster-dvo --set project.enabled=false,operator.enabled=false,dvo.enabled=true
```

## Other available values

- **startx** : DVO operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-dvo/values-startx.yaml))

```bash
helm install cluster-dvo startx/cluster-dvo -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-dvo/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-dvo/examples/argocd/
oc apply -k .
```

### Applications

> DVO requires AllNamespaces scope to validate deployments across the whole cluster. The subscription goes directly into `openshift-operators` — no dedicated namespace or OperatorGroup needed.



## History

| Release  | Date       | Description                                  |
| -------- | ---------- | -------------------------------------------- |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.12 | 2026-06-18 | Improve cluster-dvo options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.372 | 2026-11-19 | update basic dependencies to v21.3.371 |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |

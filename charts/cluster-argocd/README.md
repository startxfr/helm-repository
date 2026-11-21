# ![cluster-argocd](https://helm-repository.readthedocs.io/en/latest/img/cluster-argocd.svg "Cluster Chart : ArgoCD") Cluster Chart : ArgoCD
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--argocd-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+argocd+startx)

This helm chart is used to configure code ready argocd via it's operator and deploy a VM into Openshift.

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
helm show chart startx/cluster-argocd
```

### 4. Install this chart

```bash
helm install cluster-argocd startx/cluster-argocd
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **openshift-gitops** with the following properties
  - 1 **LimitRange:** defined for this project
  - 1 **Quotas:** defined for this project
  - 3 **RBAC:** allowing **mygroup_example** to **edit** resources
- 1 **operator:** named **openshift-gitops-operator** configured with
  - The **gitops-1.19** channel
  - The **1.19.1** version
  - Deployed under the **openshift-operators** project
- 1 **argocd:** named **openshift-gitops**
- 1 **argocd_export:** every days
- 1 **argocd_project:** with **default** namespace declared
- 1 **argocd_application:** named **example-application** used to deploy an html example in **default** namespace

```bash
# base configuration running default configuration
helm install cluster-argocd startx/cluster-argocd
```

## Other available values

- **startx** : Startx argocd cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-argocd/values-startx.yaml))

```bash
helm install cluster-argocd startx/cluster-argocd -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-argocd/values-startx.yaml
```

- **startx-gitops** : Startx gitops cluster wide service configuration using startx group (dev, devops and ops) (see [values-gitops.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-argocd/values-startx-gitops.yaml))

```bash
helm install cluster-argocd startx/cluster-argocd -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-argocd/values-startx-gitops.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-argocd` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject.
The GitOps operator installs in the shared `openshift-operators` namespace. The `ArgoCD` CR deploys in `openshift-gitops`:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-argocd/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

### Chart version of the examples

The Applications of the `examples/argocd/` folders of every chart pull the Helm chart from the startx repository and use the
semver range `targetRevision: 21.3.392
each refresh: pin an exact version in production (ADR-0004). Examples that read a chart from a git `path` and a branch are
unchanged.

### Source of the generated Applications

The destination namespace of an Application (`spec.destination.namespace`) is `destinationNamespace`, which defaults to the namespace of the Application itself (`openshift-gitops`).

In `application.list[].source`, the repository is read from `repo` (or its alias `repoURL`, default `https://gitlab.com/startx1/helm.git`)
and the revision from `rev` (or its alias `targetRevision`, default `master`). The `values-app-*.yaml` files use these keys to pick the
`stable` branch.

## History

| Release  | Date       | Description                                                                                                |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.168 | 2026-06-23 | add pattern app-of-apps |
| 21.3.183 | 2026-06-23 | fix: convert literal YAML blocks to proper structures |
| 21.3.185 | 2026-06-24 | Improve schema |
| 21.3.186 | 2026-06-24 | Improve cluster-argocd options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.391 | 2026-11-21 | chaos charts: krkn v5.2.15, new chaos-pipeline chart, security fixes for litmus and monkey; breaking, see README migration notes |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |

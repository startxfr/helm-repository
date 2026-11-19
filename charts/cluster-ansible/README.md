# ![cluster-ansible](https://helm-repository.readthedocs.io/en/latest/img/cluster-ansible.svg "Cluster Chart : Ansible") Cluster Chart : Ansible
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--ansible-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+ansible+startx)

This helm chart is used to create an operator based deployment of Ansible Automation.

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
helm show chart startx/cluster-ansible
```

### 4. Install this chart

```bash
helm install cluster-ansible startx/cluster-ansible
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **rhaap-operator** with the following properties
- 1 **operator:** named **rhaap-operator** configured with
  - The **stable-2.5-cluster-scoped** channel
  - The **2.5.0** version
  - Deployed under the **rhaap-operator** project
- 1 **ansible** deployed
- 1 **ansibleHub:** enabled

```bash
# base configuration running default configuration
helm install cluster-ansible startx/cluster-ansible
```

### AnsibleAutomationPlatform spec and annotations

`ansibleAAP.spec` accepts a YAML string or a YAML map. `ansibleAAP.annotations` is a map merged over the default ArgoCD sync-wave (`1`), for example to set `argocd.argoproj.io/sync-wave` or `argocd.argoproj.io/sync-options: Prune=false`. `ansibleController.spec` also accepts a YAML string or a YAML map, and `ansibleController.annotations` and `ansibleHub.annotations` override the default sync-waves (`5` and `10`). Helm prints a harmless `Ignoring non-table value` warning when a values file replaces the default string `spec` by a map.

## Other available values

- **startx** : Startx ansible cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ansible/values-startx.yaml))

```bash
helm install cluster-ansible startx/cluster-ansible -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ansible/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-ansible` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject.
The AAP operator installs in the dedicated `aap` namespace (with its own OperatorGroup). The `AnsibleAutomationPlatform` CR deploys in `startx-ansible`:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-ansible/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## History

| Release  | Date       | Description                                                                                 |
| -------- | ---------- | ------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.13 | 2026-06-18 | Improve cluster-ansible options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.361 | 2026-11-10 | Release 21.3.361 for all charts |
| 21.3.362 | 2026-11-18 | publish stable update for the full repository |
| 21.3.370 | 2026-11-18 | publish stable update for the full repository |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.372 | 2026-11-19 | update basic dependencies to v21.3.371 |

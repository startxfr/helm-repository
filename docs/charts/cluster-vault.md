# ![cluster-vault](https://helm-repository.readthedocs.io/en/latest/img/cluster-vault.svg "Cluster Chart : Vault") Cluster Chart : Vault
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--vault-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+vault+startx)

This helm chart is used to create a deployment of a vault, helm based, deployment of Hashicorp Vault solution.

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
helm show chart startx/cluster-vault
```

### 4. Install this chart

```bash
helm install cluster-vault startx/cluster-vault
```

## Values files

### Default values file (values.yaml)

Configuration of default properties all disabled by default. This mean no resource will be created unless overwriting default parameters. Default configuration have the following characteristics :

- 1 **project** named **default-vault**
- 1 **chart** named **vault** to deploy vault server in the project with the following characteristics
  - helm chart version is **0.23.0**
  - vault server is in version **1.12.1**

```bash
# base configuration running default configuration
helm install cluster-vault startx/cluster-vault
```

### Default values file (values-startx.yaml)

Configuration of startx properties with the following characteristics :

- 1 **project** named **startx-vault** (disabled by default)
- 1 **chart** named **vault** to deploy vault server in the project with the following characteristics
  - helm chart version is **0.23.0**
  - vault server is in version **1.12.1**

```bash
# base configuration running startx configuration
helm install cluster-vault startx/cluster-vault -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-vault/values-startx.yaml
```

### Other values files

- **startx_noinfra** : [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-vault/values-startx_noinfra.yaml)

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organizational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | default-vault     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### route values dictionary

| Key           | Default | Description                                      |
| ------------- | ------- | ------------------------------------------------ |
| route         | {}      | Configuration of the route exposing vault server |
| route.enabled | true    | Enable creating a route to expose vault gui      |

#### route values example

```yaml
route:
  enabled: true
```

### project values dictionary

The **project property** scope the [project helm chart](https://helm-repository.readthedocs.io/en/latest/charts/project) dependency. You can find
more information on the availables options you can set under this **project** property on the [project helm chart documentation](https://helm-repository.readthedocs.io/en/latest/charts/project) or by reading the [source code](https://github.com/startxfr/helm-repository/tree/master/charts/project).

#### project values example

````yaml
# example of a project creation with this helm chart
project:
  enabled: true
  context:
    scope: default
    cluster: default
    environment: dev
    component: infra
    app: default-vault
  project:
    enabled: true
    type: project
    name: default-vault
    display_name: Operator VAULT
    description: Vault storage & control plane configured by startx
  rbac:
    enabled: true
    user:
    - id: vault-sa-edit
      name: "system:serviceaccount:default-vault:{{ .Release.name }}"
      role: edit
    - id: vault-agent-injector-sa-admin
      name: "system:serviceaccount:default-vault:{{ .Release.name }}-agent-injector"
      role: admin


### vault values dictionary

The **vault property** scope the [vault helm chart](https://helm-repository.readthedocs.io/en/latest/charts/cluster-vault) dependency. You can find
more information on the availables options you can set under this **vault** property on the [vault helm chart documentation](https://helm-repository.readthedocs.io/en/latest/charts/vault) or by reading the [source code](https://github.com/startxfr/helm-repository/tree/master/charts/vault).

#### vault values example

```yaml
# example of a vault creation with this helm chart

````

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-vault/examples/argocd/
oc apply -k .
```

### Applications



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
| 21.3.14 | 2026-06-19 | Improve cluster-vault options |
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
| 21.3.418 | 2026-11-23 | commit a stable release of all charts |

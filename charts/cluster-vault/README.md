# ![cluster-vault](https://helm-repository.readthedocs.io/en/latest/img/cluster-vault.svg "Cluster Chart : Vault") Cluster Chart : Vault
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--vault-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+vault+startx)

This helm chart is used to create a deployment of a vault, helm based, deployment of Hashicorp Vault solution.

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
helm show chart startx/cluster-vault
```

### 4. Install this chart

```bash
helm install cluster-vault startx/cluster-vault
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
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

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-vault
  namespace: openshift-gitops
spec:
  description: Deploy HashiCorp Vault in startx-vault namespace
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-gitops
      server: https://kubernetes.default.svc
    - namespace: startx-vault
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
```

### Applications

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-vault-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-vault
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-vault
    targetRevision: 21.3.105
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: true
        vault:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-vault-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-vault
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-vault
    targetRevision: 21.3.105
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: false
        vault:
          enabled: true
          global:
            enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: startx-vault
  ignoreDifferences:
    - group: vault.banzaicloud.com
      kind: Vault
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
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
| 21.3.13 | 2026-06-19 | Improve cluster-vault options |
| 21.3.14 | 2026-06-19 | Improve cluster-vault options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
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

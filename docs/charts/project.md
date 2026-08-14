# ![project](https://helm-repository.readthedocs.io/en/latest/img/project.svg "Basic Chart : Project") Basic Chart : Project
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_project-83E22B.svg)](https://artifacthub.io/packages/search?ts_query_web=project+startx)

This helm chart is used to create a project, or namespace, with various options constraint resources like networkPolicy, RoleBinding, LimitRange and Quotas.

This chart is part of the [basic-xxx startx helm chart series](https://helm-repository.readthedocs.io#basic-helm-charts) used by [cluster-xxx charts](https://helm-repository.readthedocs.io#cluster-helm-charts) and [example-xxx charts](https://helm-repository.readthedocs.io#examples-helm-charts).

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
helm show chart startx/project
```

### 4. Install this chart

```bash
helm install project startx/project
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | project   | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### project values dictionary

| Key                         | Default         | Description                                                |
| --------------------------- | --------------- | ---------------------------------------------------------- |
| project.type                | project         | Define the type of tenant to create (project or namespace) |
| project.name                | default         | Name of the project                                        |
| project.display_name        | default         | Display name of the project (only for project)             |
| project.description         | default         | Description of the project (only for project)              |
| rbac.enabled                | false           | Enable RBAC default for this project                       |
| rbac.groups[]               | []              | List groups to authorize on this project                   |
| rbac.groups[0].id           | mygroup         | Group ID for roleBinding                                   |
| rbac.groups[0].name         | mygroup_example | Group name for roleBinding                                 |
| rbac.groups[0].role         | view            | Role to use for this group roleBinding                     |
| rbac.users[]                | []              | List groups to authorize on this project                   |
| rbac.users[0].id            | myuser          | User ID for roleBinding                                    |
| rbac.users[0].name          | myuser_example  | User name for roleBinding                                  |
| rbac.users[0].role          | view            | Role to use for this user roleBinding                      |
| networkpolicy.enabled       | false           | Enable NetworkPolicy default for this project              |
| networkpolicy.rules[]       | []              | List group to create                                       |
| networkpolicy.rules[0].id   | string          | Rule ID for the networkPolicy                              |
| networkpolicy.rules[0].spec | string          | Specifications of this policy rule                         |
| limits.enabled              | false           | Enable limitRange for this project                         |
| limits.rules                | string          | Specifications of the limitRange resource                 |
| quotas.enabled              | false           | Enable quotas for this project                             |
| quotas.rules                | string          | Specifications of the quotas resource                     |

## Values files

### Default values file (values.yaml)

Complete deployment of a project with the following characteristics :

- 1 **project** named **example-project**

```bash
# base configuration running default configuration
helm install project startx/project
```

### Demo kustomize values file (values-demo-kustomize.yaml)

Complete deployment of a demo kustomize project with the following characteristics :

- 1 **project** named **demo-kustomize**
- 4 **RBAC** rules enabled
  - 1 **group RBAC** named **dev** binding group **dev** to role **view**
  - 1 **group RBAC** named **devops** binding group **devops** to role **edit**
  - 1 **group RBAC** named **ops** binding group **ops** to role **admin**
  - 1 **user RBAC** named **argocd-controller-sa** binding user **sa argocd-application-controller** to role **edit**
- 1 **networkpolicy** rules disabled
- 1 **limitRange** rules enabled
- 1 **quotas** rules enabled

```bash
# base configuration running demo kustomize configuration
helm install project-demo-kustomize startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-kustomize.yaml
```

### Demo helm values file (values-demo-helm.yaml)

Complete deployment of a demo helm project with the following characteristics :

- 1 **project** named **demo-helm**
- 4 **RBAC** rules enabled
  - 1 **group RBAC** named **dev** binding group **dev** to role **basic-user**
  - 1 **group RBAC** named **devops** binding group **devops** to role **edit**
  - 1 **group RBAC** named **ops** binding group **ops** to role **admin**
  - 1 **user RBAC** named **argocd-controller-sa** binding user **sa argocd-application-controller** to role **edit**
- 2 **networkpolicy** rules enabled
  - 1 networkpolicy named **allow-from-openshift-ingress**
  - 1 networkpolicy named **allow-from-same-namespace**
- 1 **limitRange** rules enabled
- 1 **quotas** rules enabled

```bash
# base configuration running demo helm configuration
helm install project-demo-helm startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-helm.yaml
```

### Demo argocd values file (values-demo-argocd.yaml)

Complete deployment of a demo argocd project with the following characteristics :

- 1 **project** named **demo-argocd**
- 4 **RBAC** rules enabled
  - 1 **group RBAC** named **dev** binding group **dev** to role **view**
  - 1 **group RBAC** named **devops** binding group **devops** to role **edit**
  - 1 **group RBAC** named **ops** binding group **ops** to role **admin**
  - 1 **user RBAC** named **argocd-controller-sa** binding user **sa argocd-application-controller** to role **edit**
- 2 **networkpolicy** rules disabled
- 1 **limitRange** rules enabled
- 1 **quotas** rules enabled

```bash
# base configuration running demo argocd configuration
helm install project-demo-argocd startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-argocd.yaml
```

### Demo example values file (values-demo-example.yaml)

Complete deployment of a demo example project with the following characteristics :

- 1 **namespace** named **example-project**
- 2 **RBAC** rules enabled
  - 1 **group RBAC** named **mygroup** binding group **mygroup_example** to role **basic-user**
  - 1 **user RBAC** named **myuser** binding user **myuser_example** to role **basic-user**
- 2 **networkpolicy** rules enabled
  - 1 networkpolicy named **allow-from-openshift-ingress**
  - 1 networkpolicy named **allow-from-same-namespace**
- 1 **limitRange** rules enabled
- 1 **quotas** rules enabled

```bash
# base configuration running demo example configuration
helm install project-example-project startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-example.yaml
```

### Startx values file (values-startx.yaml)

Complete deployment of a startx project with the following characteristics :

- 1 **project** named **startx-project**
- 4 **RBAC** rules enabled
  - 1 **group RBAC** named **dev** binding group **dev** to role **basic-user**
  - 1 **group RBAC** named **devops** binding group **devops** to role **edit**
  - 1 **group RBAC** named **ops** binding group **ops** to role **admin**
  - 1 **user RBAC** named **dev** binding user **dev** to role **basic-user**
- 2 **networkpolicy** rules enabled
  - 1 networkpolicy named **allow-from-openshift-ingress**
  - 1 networkpolicy named **allow-from-same-namespace**
- 1 **limitRange** rules enabled
- 1 **quotas** rules enabled

```bash
# base configuration running startx configuration
helm install project-startx startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `project` using a single ArgoCD Application sharing a dedicated AppProject.
The chart creates a namespace with optional RBAC, network policies, limit ranges and quotas:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/project/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles the namespace whenever the chart or values drift from the desired state.

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 16.19.43 | 2025-02-27 | publish stable update for the full repository |
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
| 21.3.21 | 2026-06-19 | release basic version |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.70 | 2026-06-20 | Improve doc and argocd examples |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.69 | 2026-06-20 | Improve project options |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |
| 21.3.167 | 2026-06-23 | publish stable update for the full repository |
| 21.3.181 | 2026-06-23 | publish stable update for the full repository |
| 21.3.182 | 2026-06-23 | publish stable update for the full repository |
| 21.3.199 | 2026-06-24 | publish stable update for the full repository |
| 21.3.201 | 2026-06-24 | publish stable update for the full repository |
| 21.3.202 | 2026-06-24 | publish stable update for the full repository |
| 21.3.207 | 2026-06-24 | Improve project options |
| 21.3.205 | 2026-06-24 | publish stable update for the full repository |
| 21.3.206 | 2026-06-28 | update argocd examples and targetRevision |
| 21.3.208 | 2026-06-28 | Improve project options |
| 21.3.222 | 2026-08-08 | Improve project options |
| 21.3.229 | 2026-08-08 | publish stable update for the full repository |
| 21.3.273 | 2026-08-09 | publish stable update for the full repository |
| 21.3.277 | 2026-08-09 | Align all charts to v21.3.277 |
| 21.3.278 | 2026-08-14 | add centigpu |

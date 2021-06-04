# Basic project

This helm chart is used to create a project, or namespace, with various options constraint resources like networkPolicy, RoleBinding, LimitRange and Quotas.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/project
```

### 4. Install this chart

```bash
helm install startx/project
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description
| ------------------- | --------- | -----------------------------------------------------
| context.scope       | default   | Name of the global scope for this application (organisational tenant)
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod)
| context.component   | demo      | Component name of this application (logical tenant)
| context.app         | project   | Application name (functionnal tenant, default use Chart name)
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)

### project values dictionary

| Key                         | Default           | Description
| --------------------------- | --------------- | -----------------------------------------------------
| project.type                | project         | Define the type of tenant to create (project or namespace)
| project.name                | default         | Name of the project
| project.display_name        | default         | Display name of the project (only for project)
| project.description         | default         | Description of the project (only for project)
| rbac.enabled                | false           | Enable RBAC default for this project
| rbac.groups[]               | []              | List groups to authorize on this project
| rbac.groups[0].id           | mygroup         | Group ID for roleBinding
| rbac.groups[0].name         | mygroup_example | Group name for roleBinding
| rbac.groups[0].role         | view            | Role to use for this group roleBinding
| rbac.users[]                | []              | List groups to authorize on this project
| rbac.users[0].id            | myuser          | User ID for roleBinding
| rbac.users[0].name          | myuser_example  | User name for roleBinding
| rbac.users[0].role          | view            | Role to use for this user roleBinding
| networkpolicy.enabled       | false           | Enable NetworkPolicy default for this project
| networkpolicy.rules[]       | []              | List group to create
| networkpolicy.rules[0].id   | string          | Rule ID for the networkPolicy
| networkpolicy.rules[0].spec | string          | Specifications of this policy rule
| limits.enabled              | false           | Enable limitRange for this project
| limits.rules                | string          | Specifications of the limitRange ressource
| quotas.enabled              | false           | Enable quotas for this project
| quotas.rules                | string          | Specifications of the quotas ressource

## Values files

### Default values file (values.yaml)

Complete deployment of a project with the following characteristics :

- 1 **project** named **example-project**

```bash
# base configuration running default configuration
helm install startx/project
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
helm install startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-kustomize.yaml
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
helm install startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-helm.yaml
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
helm install startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-argocd.yaml
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
helm install startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-example.yaml
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
helm install startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.51  | 2020-10-31 | Initial commit for this chart with default and dev value examples
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.1   | 2020-11-01 | Move to go templates for notes generation and move app content to value property project.data
| 0.3.3   | 2020-11-01 | Test new scope for note template helper
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.45  | 2020-11-08 | Align all basic helm chart to 0.3.45 release
| 0.3.65  | 2020-11-09 | Add hooked option to enable/disable use of helm hook (default is disabled)
| 0.3.81  | 2020-11-10 | Improve project options
| 0.3.91  | 2020-11-10 | Add enable option to enable the creation of a project (default false)
| 0.3.95 | 2020-11-11 | networkPolicy and roleBinding update
| 0.3.115 | 2020-11-12 | Release basic chart stability updates
| 0.3.119  | 2020-11-14 | Add demo values for hpa, affinity and istio
| 0.3.131  | 2020-11-14 | Stable values examples
| 0.3.135 | 2020-11-23 | Improve documentation for all examples charts
| 0.3.141 | 2020-11-24 | publish stable update for the full repository
| 0.3.142 | 2021-01-23 | Update for OCP 4.6.13
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13
| 0.3.153 | 2021-01-23 | publish stable update for the full repository
| 0.3.155 | 2021-01-23 | Debug requester creation
| 0.3.155 | 2021-01-23 | Debug requester creation
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies
| 0.3.171 | 2021-01-24 | Reduce argocd wave level
| 0.3.187 | 2021-02-13 | Align basic chart release to 0.3.187
| 0.3.189 | 2021-02-13 | remove manpage
| 0.3.189 | 2021-02-13 | Align all basic charts to 0.3.189
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189
| 0.3.193 | 2021-02-20 | Stable base helm-chart
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts
| 0.3.201 | 2021-02-20 | Update icon and image for charts
| 0.3.203 | 2021-02-21 | Upgrade chart release informations
| 0.3.205 | 2021-04-19 | Align release of core charts
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215
| 0.3.217 | 2021-05-10 | Move RBAC naming to unique id
| 0.3.217 | 2021-05-10 | Move RBAC naming to unique id
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming
| 0.3.226 | 2021-05-31 | Add values files for various demo
| 0.3.227 | 2021-05-31 | Add demo compliance values
| 0.3.303 | 2021-06-02 | Update documentation and align all charts to release 0.3.303
| 0.2.299 | 2021-06-03 | Update multiple demo project
| 0.2.301 | 2021-06-03 | Stable basic chart aligned to 0.2.301
| 0.3.301 | 2021-06-03 | Stable basic chart aligned to 0.3.301
| 0.3.305 | 2021-06-04 | publish stable update for the full repository
| 0.3.315 | 2021-06-04 | Stable documentation for all charts

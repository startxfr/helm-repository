# ![project](https://helm-repository.readthedocs.io/en/latest/img/project.svg "Basic Chart : Project") Basic Chart : Project
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_project-83E22B.svg)](https://artifacthub.io/packages/search?ts_query_web=project+startx)

This helm chart is used to create a project, or namespace, with various options constraint resources like networkPolicy, RoleBinding, LimitRange and Quotas.

This chart is part of the [basic-xxx startx helm chart series](https://helm-repository.readthedocs.io#basic-helm-charts) used by [cluster-xxx charts](https://helm-repository.readthedocs.io#cluster-helm-charts) and [example-xxx charts](https://helm-repository.readthedocs.io#examples-helm-charts).

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
helm show chart startx/project
```

### 4. Install this chart

```bash
helm install project startx/project
```

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

Every block of this file is disabled (`project`, `rbac`, `serviceAccounts`, `dockercfg`, `networkpolicy`, `limits`, `quotas` are all `enabled: false`), so it renders nothing until you enable the blocks you need. It defines :

- the **project** `startx` (display name `Startx default project`, requester `startx`)
- 5 **RBAC** groups : `students` (view); `dev` (basic-user); `devops` (basic-user); `ops` (admin); `system:authenticated` (read-only), and 1 user
- 1 **serviceAccounts** item, 3 **dockercfg** items
- an empty **networkpolicy** rules list, **limits** rules with every value at `0`, and **quotas** rules (`hard` section, most values at `0`): adjust them before enabling the blocks

```bash
# nothing is created until a block is enabled, e.g. add --set project.enabled=true
helm install project-startx startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx.yaml
```

### Other values files

Every file below is a complete set of values, used with `helm install project startx/project -f <file>`.

- **demo projects** : the 31 files matching `values-demo*.yaml` (for example [values-demo-hpa.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-hpa.yaml)) create one project named after the file (`values-demo-hpa.yaml` creates `demo-hpa`, `values-demo.yaml` creates `demo`; the exception is `values-demo-example.yaml`, project `example-project`) with `context.environment: demo`; some of them are also described above. Enabled blocks:
  - 22 file(s): project, RBAC, NetworkPolicy, LimitRange and quotas
  - 6 file(s): project, RBAC, LimitRange and quotas (no NetworkPolicy) (demo-automation, demo-costs, demo-kafka, demo-kepler, demo-keycloak, demo-knative)
  - 1 file(s): project, RBAC, LimitRange, quotas and service accounts (no NetworkPolicy) (demo-3scale)
  - 1 file(s): project only (demo-example)
  - 1 file(s): no block enabled, `project.enabled: false` (context and project name only) (demo)
- **other projects** (one file each):
  - [values-cdf-poc.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-cdf-poc.yaml) : project `cdf`, environment `infra`, enabled blocks: project, rbac
  - [values-prgmk-ada.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-prgmk-ada.yaml) : project `ada`, environment `devel`, enabled blocks: project, rbac
  - [values-startx-argocd.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx-argocd.yaml) : project `startx-argocd`, environment `demo`, no block enabled (`project.enabled: false`, context and project name only)
  - [values-startx-gitops.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx-gitops.yaml) : project `openshift-gitops`, environment `demo`, no block enabled (`project.enabled: false`, context and project name only)
  - [values-startx-quay.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx-quay.yaml) : project `startx-quay`, environment `demo`, enabled blocks: project, rbac, networkpolicy, limits, quotas
  - [values-startx-ubisoft.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx-ubisoft.yaml) : project `ubisoft-user`, environment `ubisoft`, enabled blocks: project, rbac
  - [values-startx-vault.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx-vault.yaml) : project `startx-vault`, environment `demo`, enabled blocks: project
  - [values-startx-workspaces.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx-workspaces.yaml) : project `openshift-workspaces`, environment `demo`, enabled blocks: project, rbac
  - [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx.yaml) : project `startx`, environment `demo`, no block enabled (`project.enabled: false`, context and project name only)
  - [values-startx_noinfra-gitops.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx_noinfra-gitops.yaml) : project `openshift-gitops`, environment `demo`, no block enabled (`project.enabled: false`, context and project name only)
  - [values-startx_noinfra-vault.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx_noinfra-vault.yaml) : project `startx-vault`, environment `demo`, enabled blocks: project
  - [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx_noinfra.yaml) : project `startx`, environment `demo`, no block enabled (`project.enabled: false`, context and project name only)

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organizational tenant)             |
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
| dockercfg.enabled           | false           | Enable the registry credentials Secrets of this project    |
| dockercfg.list[]            | []              | List of the registry credentials to record                 |
| dockercfg.list[0].name      | registrycreds   | Name of the generated Secret (clear-text credentials)      |
| dockercfg.list[0].registry  | docker.io       | Registry of the generated Secret (with username, password and email) |
| dockercfg.list[0].existingSecret | -          | Name of a Secret of type `kubernetes.io/dockerconfigjson` that already exists in the namespace : the chart renders no Secret for the entry and refuses clear-text credentials beside it |

## Usage examples

### Use a registry Secret that already exists

Keep the registry credentials out of the values : create the Secret apart (an ExternalSecret, a SealedSecret or
`oc create secret docker-registry`), then name it. The chart renders no Secret for an `existingSecret` entry and never
reads the existing one. The Secret must be of type `kubernetes.io/dockerconfigjson`, in the namespace of the entry.
The chart does not link it to a service account : list its name in `serviceAccounts.list[].imagePullSecrets`, as for a generated Secret.

```yaml
# my-project-values.yaml
enabled: true
project:
  name: my-project
dockercfg:
  enabled: true
  list:
    # no credential here : the Secret is provided by the user
    - existingSecret: my-registry-pull-secret
serviceAccounts:
  enabled: true
  list:
    - name: default
      imagePullSecrets:
        - name: my-registry-pull-secret
```

An entry sets `existingSecret` **or** `registry`, `username`, `password` and `email` : both together fail the render,
and `name` is only accepted when it equals `existingSecret`. Entries of the two kinds can share the same list.

## Deploy with ArgoCD

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
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.21 | 2026-06-19 | release basic version |
| 21.3.70 | 2026-06-20 | Improve doc and argocd examples |
| 21.3.206 | 2026-06-28 | update argocd examples and targetRevision |
| 21.3.222 | 2026-08-08 | Improve project options |
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
| 21.3.416 | 2026-11-23 | stable update: chart fixes (project, cluster-mongo, cluster-oadp, cluster-pipeline, cluster-machine, example-catalog); cluster-dvo accepts the grafana keys next to graphana, which keeps priority |

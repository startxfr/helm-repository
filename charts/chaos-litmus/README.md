# ![chaos-litmus](https://helm-repository.readthedocs.io/en/latest/img/chaos-litmus.svg "Chaos Chart : Litmus") Chaos Chart : Litmus
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--litmus-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+litmus+startx)

This helm chart is used to deploy [Litmus](https://litmuschaos.io) on an Openshift or Kubernetes cluster.
Litmus is a chaos engineering platform : a web portal (ChaosCenter) where chaos experiments are designed, scheduled and
followed as workflows.

**Upstream project** : [litmuschaos/litmus](https://github.com/litmuschaos/litmus), deployed with the upstream helm chart [`litmus`](https://litmuschaos.github.io/litmus-helm) version `3.26.0` ; images `litmuschaos/litmusportal-frontend`, `litmusportal-server` and `litmusportal-auth-server`, tag `3.26.0`, and `mongo:4.2.8`.

This chart is part of the [chaos startx helm chart series](https://helm-repository.readthedocs.io#chaos-helm-charts) focused on deploying various kind of chaos tools for cluster infrastructure or applications chaos-testing.

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
helm show chart startx/chaos-litmus
```

### 4. Install this component

```bash
# Create the chaos-litmus namespace
helm install chaos-litmus-project startx/chaos-litmus --set project.enabled=true
# Deploy the litmus instance
helm install chaos-litmus-instance startx/chaos-litmus --set litmus.enabled=true -n chaos-litmus
```

## Default values

The default [values.yaml](https://github.com/startxfr/helm-repository/blob/master/charts/chaos-litmus/values.yaml) deploys
nothing : each part is switched on by its `enabled` key.

- `project.enabled=true` : 1 **namespace** `chaos-litmus` (see the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project))
- `litmus.enabled=true` : the litmus portal (frontend, server, auth-server, MongoDB), 1 **SecurityContextConstraints** `privileged-litmus` with its Role and RoleBinding, 1 Argo **Workflow** `startx-workflow`
- `litmus.expose=true` : 1 **Route** `frontend`

The `startx-workflow` resource is an Argo `Workflow` : the `workflows.argoproj.io` definition must exist on the cluster
before `litmus.enabled=true` is installed (it is installed with a Litmus chaos infrastructure or with Argo Workflows).

| Key                  | Default      | Description                                                                                                                      |
| -------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| context.scope        | companyname  | Name of the global scope for this application (organizational tenant)                                                            |
| context.cluster      | clustername  | Name of the cluster running this application (platform tenant)                                                                   |
| context.environment  | dev          | Name of the environment for this application (ex: dev, factory, preprod or prod)                                                 |
| context.component    | chaos        | Component name of this application (logical tenant)                                                                              |
| context.app          | litmus       | Application name (functional tenant, default use Chart name)                                                                     |
| context.version      | 3.26.0       | Version name of this application (default use Chart appVersion)                                                                  |
| project              | {...}        | Values of the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project), which creates the namespace      |
| project.enabled      | false        | Create the namespace                                                                                                             |
| project.project.name | chaos-litmus | Name of the namespace ; also the namespace of the resources created by this chart                                                |
| litmus               | {...}        | Values of the upstream [litmus chart](https://github.com/litmuschaos/litmus-helm/tree/master/charts/litmus), passed as is        |
| litmus.enabled       | false        | Deploy the litmus portal, the `privileged-litmus` SecurityContextConstraints and the `startx-workflow` example workflow          |
| litmus.expose        | false        | Create the Openshift route `frontend` to the litmus portal, on top of the route of the upstream chart (`litmus.openshift.route`) |
| litmus.adminConfig   | {...}        | Portal administrator and database credentials. **Change the defaults**                                                           |
| litmus.portal        | {...}        | Frontend, GraphQL server and authentication server of the portal                                                                 |
| litmus.mongo         | {...}        | MongoDB deployed with the portal                                                                                                 |

## Other available values

- **startx-project** : [values-startx-project.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-litmus/values-startx-project.yaml), namespace `startx-chaos-litmus` only
- **startx-deploy** : [values-startx-deploy.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-litmus/values-startx-deploy.yaml), litmus portal in the namespace `startx-chaos-litmus`

```bash
helm install chaos-litmus-project startx/chaos-litmus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-litmus/values-startx-project.yaml
helm install chaos-litmus-instance startx/chaos-litmus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-litmus/values-startx-deploy.yaml -n startx-chaos-litmus
```

## ArgoCD deployment

One AppProject and two Applications : `chaos-litmus-project` (wave 1, the namespace) then `chaos-litmus-instance` (wave 5, the portal and its route).
The files are in [examples/argocd](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-litmus/examples/argocd).

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/chaos-litmus
oc apply -k examples/argocd/
```

Each Application sets the `enabled` key of the other part to `false`, so that the two Applications never render the
same resource. Delete `chaos-litmus-instance` first, wait for it to be gone, then delete `chaos-litmus-project` (it has no
finalizer : a namespace can be slow to terminate).

## Usage examples

### Default : namespace then portal

Two releases of the same chart, the namespace first.

```bash
helm install chaos-litmus-project startx/chaos-litmus --set project.enabled=true
helm install chaos-litmus-instance startx/chaos-litmus --set litmus.enabled=true -n chaos-litmus
```

### Minimal : portal in an existing namespace

The namespace already exists ; the portal is reached with `oc port-forward`.

```yaml
# my-litmus-minimal-values.yaml
project:
  enabled: false
  project:
    name: my-chaos
litmus:
  enabled: true
```

```bash
helm install chaos-litmus startx/chaos-litmus -f my-litmus-minimal-values.yaml -n my-chaos
oc port-forward -n my-chaos svc/chaos-litmus-frontend-service 9091:9091
```

### Advanced : exposed portal with its own credentials

The portal is exposed with a route, the administrator and database passwords are replaced and the public URL is given to the server.

```yaml
# my-litmus-values.yaml
context:
  scope: myorg
  cluster: mycluster
  environment: prod
  component: chaos
  app: litmus
litmus:
  enabled: true
  expose: true
  adminConfig:
    DBUSER: "litmus"
    DBPASSWORD: "change-me"
    ADMIN_USERNAME: "admin"
    ADMIN_PASSWORD: "change-me-too"
  portal:
    server:
      graphqlServer:
        genericEnv:
          CHAOS_CENTER_UI_ENDPOINT: https://frontend-chaos-litmus.apps.mycluster.example.com
```

```bash
helm install chaos-litmus-instance startx/chaos-litmus -f my-litmus-values.yaml -n chaos-litmus
```
## History

| Release  | Date       | Description                                                                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same release |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all charts to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.203 | 2026-06-24 | Improve chaos-litmus options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.313 | 2026-11-04 | Add cluster-unifai and cluster-qdrant, align all charts to 21.3.313 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.373 | 2026-11-19 | align inter-chart dependency pins |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |

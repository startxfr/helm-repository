# ![chaos-mesh](https://helm-repository.readthedocs.io/en/latest/img/chaos-mesh.svg "Chaos Chart : ChaosMesh") Chaos Chart : Mesh
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--mesh-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+mesh+startx)

This helm chart is used to deploy [Chaos Mesh](https://chaos-mesh.org) on an Openshift or Kubernetes cluster.
Chaos Mesh is a chaos engine driven by custom resources (`PodChaos`, `NetworkChaos`, `TimeChaos`...) or by its web
dashboard.

**Upstream project** : [chaos-mesh/chaos-mesh](https://github.com/chaos-mesh/chaos-mesh), deployed with the upstream helm chart [`chaos-mesh`](https://charts.chaos-mesh.org) version `2.8.8` ; images `ghcr.io/chaos-mesh/chaos-mesh`, `chaos-daemon` and `chaos-dashboard`, tag `v2.8.8`.

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
helm show chart startx/chaos-mesh
```

### 4. Install this component

```bash
# Create the chaos-mesh namespace
helm install chaos-mesh-project startx/chaos-mesh --set project.enabled=true
# Deploy the mesh instance
helm install chaos-mesh-instance startx/chaos-mesh --set mesh.enabled=true -n chaos-mesh
```

## Default values

The default [values.yaml](https://github.com/startxfr/helm-repository/blob/master/charts/chaos-mesh/values.yaml) deploys
nothing : each part is switched on by its `enabled` key.

- `project.enabled=true` : 1 **namespace** `chaos-mesh` (see the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project))
- `mesh.enabled=true` : the chaos-mesh controller, daemon, dashboard, DNS server and Prometheus, 2 **SecurityContextConstraints** `anyuid-mesh` and `privileged-mesh` with their Role and RoleBinding, 1 **Route** `server` (unless `mesh.expose=false`)

The custom resource definitions (`chaos-mesh.org`) are shipped in the `crds/` directory of the upstream chart : helm
installs them at the first install and never upgrades them.

| Key                         | Default                                      | Description                                                                                                                   |
| --------------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| context.scope               | companyname                                  | Name of the global scope for this application (organizational tenant)                                                         |
| context.cluster             | clustername                                  | Name of the cluster running this application (platform tenant)                                                                |
| context.environment         | dev                                          | Name of the environment for this application (ex: dev, factory, preprod or prod)                                              |
| context.component           | chaos                                        | Component name of this application (logical tenant)                                                                           |
| context.app                 | chaos-mesh                                   | Application name (functional tenant, default use Chart name)                                                                  |
| context.version             | 2.8.8                                        | Version name of this application (default use Chart appVersion)                                                               |
| project                     | {...}                                        | Values of the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project), which creates the namespace   |
| project.enabled             | false                                        | Create the namespace                                                                                                          |
| project.project.name        | chaos-mesh                                   | Name of the namespace ; also the namespace of the resources created by this chart                                             |
| mesh                        | {...}                                        | Values of the upstream [chaos-mesh chart](https://github.com/chaos-mesh/chaos-mesh/tree/master/helm/chaos-mesh), passed as is |
| mesh.enabled                | false                                        | Deploy chaos-mesh and the `anyuid-mesh` and `privileged-mesh` SecurityContextConstraints                                      |
| mesh.expose                 | true                                         | Create the Openshift route `server` to the dashboard (when `mesh.enabled` and `mesh.dashboard.create`)                        |
| mesh.chaosDaemon.runtime    | crio                                         | Container runtime of the nodes ; `socketPath` goes with it                                                                    |
| mesh.dashboard.create       | true                                         | Deploy the web dashboard                                                                                                      |
| mesh.dashboard.securityMode | true                                         | The dashboard asks for a token instead of using its own service account                                                       |
| mesh.dashboard.rootUrl      | https://server-chaos-mesh.apps.mycluster.com | Public URL of the dashboard, to adapt to the cluster                                                                          |
| mesh.prometheus.create      | true                                         | Deploy a Prometheus with a persistent volume                                                                                  |

## Other available values

- **startx-project** : [values-startx-project.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-mesh/values-startx-project.yaml), namespace `startx-chaos-mesh` only
- **startx-deploy** : [values-startx-deploy.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-mesh/values-startx-deploy.yaml), chaos-mesh in the namespace `startx-chaos-mesh`, 3 controller replicas

```bash
helm install chaos-mesh-project startx/chaos-mesh -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-mesh/values-startx-project.yaml
helm install chaos-mesh-instance startx/chaos-mesh -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-mesh/values-startx-deploy.yaml -n startx-chaos-mesh
```

## Usage examples

### Default : namespace then chaos-mesh

Two releases of the same chart, the namespace first.

```bash
helm install chaos-mesh-project startx/chaos-mesh --set project.enabled=true
helm install chaos-mesh-instance startx/chaos-mesh --set mesh.enabled=true -n chaos-mesh
```

### Minimal : engine only

No dashboard, no route, no Prometheus, no DNS server : experiments are applied as custom resources.

```yaml
# my-mesh-minimal-values.yaml
mesh:
  enabled: true
  expose: false
  dashboard:
    create: false
  prometheus:
    create: false
  dnsServer:
    create: false
```

```bash
helm install chaos-mesh-instance startx/chaos-mesh -f my-mesh-minimal-values.yaml -n chaos-mesh
```

### Advanced : highly available controller and a first experiment

Three controller replicas, the dashboard published under the cluster domain, then a `PodChaos` that kills one pod of an application.

```yaml
# my-mesh-values.yaml
context:
  scope: myorg
  cluster: mycluster
  environment: prod
  component: chaos
  app: chaos-mesh
mesh:
  enabled: true
  controllerManager:
    replicaCount: 3
  dashboard:
    rootUrl: https://server-chaos-mesh.apps.mycluster.example.com
  prometheus:
    create: false
```

```bash
helm install chaos-mesh-instance startx/chaos-mesh -f my-mesh-values.yaml -n chaos-mesh
cat <<EOF | oc apply -f -
apiVersion: chaos-mesh.org/v1alpha1
kind: PodChaos
metadata:
  name: pod-kill-myapp
  namespace: chaos-mesh
spec:
  action: pod-kill
  mode: one
  selector:
    namespaces:
      - myapp-namespace
    labelSelectors:
      app.kubernetes.io/name: myapp
EOF
```
## ArgoCD deployment

One AppProject and two Applications : `chaos-mesh-project` (wave 1, the namespace) then `chaos-mesh-instance` (wave 5, chaos-mesh).
The files are in [examples/argocd](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-mesh/examples/argocd).

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/chaos-mesh
oc apply -k examples/argocd/
```

Each Application sets the `enabled` key of the other part to `false`, so that the two Applications never render the
same resource. Delete `chaos-mesh-instance` first, wait for it to be gone, then delete `chaos-mesh-project` (it has no
finalizer : a namespace can be slow to terminate).

Things to know with ArgoCD :

- **Custom resource definitions** : ArgoCD installs and upgrades the definitions of the `crds/` directory. They are too
  large for a client side apply, hence `ServerSideApply=true` in the instance Application. Do not set `skipCrds` :
  nothing else installs them.
- **Prometheus volume** : with a `WaitForFirstConsumer` StorageClass the volume claim stays `Pending` and ArgoCD waits
  for it before creating the pod that would bind it. The example sets `mesh.prometheus.create: false` ; otherwise give
  an `Immediate` StorageClass.
- **AppProject** : the chart creates `MutatingWebhookConfiguration` and `ValidatingWebhookConfiguration` resources ;
  both are in the `clusterResourceWhitelist` of the example.

## History

| Release  | Date       | Description                                                                                                                                              |
| -------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same release |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all charts to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.313 | 2026-11-04 | Add cluster-unifai and cluster-qdrant, align all charts to 21.3.313 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.361 | 2026-11-10 | Release chaos-mesh restored chart |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.372 | 2026-11-19 | update basic dependencies to v21.3.371 |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |

# ![chaos-mesh](https://helm-repository.readthedocs.io/en/latest/img/chaos-mesh.svg "Chaos Chart : ChaosMesh") Chaos Chart : Mesh
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--mesh-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+mesh+startx)

This helm chart used to deploy chaos-mesh on Openshift or Kubernetes cluster.
Chaos Mesh is a chaos engine with a GUI to define and execute chaos scenarios for Kubernetes clusters.

This chart is part of the [chaos startx helm chart series](https://helm-repository.readthedocs.io#chaos-helm-charts) focused on deploying various kind of chaos tools for cluster infrastructure or applications chaos-testing. [chaos-xxx charts](https://helm-repository.readthedocs.io#chaos-helm-charts).

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
# Install the chaos-mesh project
helm install --set project.enabled=true chaos-mesh-project  startx/chaos-mesh
# Deploy the chaos-mesh instance
helm install --set mesh.enabled=true -n chaos-mesh chaos-mesh-instance startx/chaos-mesh
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | chaos-mesh     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### chaos-mesh values dictionary

| Key            | Default | Description                                                                                                                                                                                                                                                                       |
| -------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project        | {...}   | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/project/#project-values-dictionary) for more options) |
| project.enable | false   | Enable creation of the namespace                                                                                                                                                                                                                                                  |
| mesh           | {...}   | Configuration of the chaos-mesh deployment. Inherit from the [official chaos-mesh chart](https://charts.chaos-mesh.org) (see [chart options](https://charts.chaos-mesh.org) for more options)                                                                                     |
| mesh.enable    | false   | Enable deploying the chaos-mesh chaos engine                                                                                                                                                                                                                                          |

## Values files

### Default values file (values.yaml)

Simple mesh with default configuration :

- 1 **project** named **chaos-mesh**
- 1 **scc** with privileged context for 9 **mesh** serviceaccount
- 1 **mesh** deployment using official helm chart
- 1 **route** to the **mesh** service

```bash
# Running the default configuration
helm install --set project.enable=true chaos-mesh-project startx/chaos-mesh
helm install --set mesh.enable=true chaos-mesh-instance startx/chaos-mesh
```

### STARTX values file (values-startx-xxx.yaml)

Same as the default configuration but with namespace prefixed with startx-

```bash
# Configuration running demo example configuration
helm install chaos-mesh-project startx/chaos-mesh -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-mesh/values-startx-project.yaml
helm install chaos-mesh-deploy startx/chaos-mesh -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-mesh/values-startx-deploy.yaml
```

## Usage examples

### Deploy chaos-mesh with dashboard and route

Enable chaos-mesh with its web dashboard exposed via an OpenShift route:

```yaml
# my-mesh-values.yaml
context:
  scope: myorg
  cluster: prod-cluster
  environment: chaos
  component: mesh
  app: chaos-mesh

mesh:
  enabled: true
  dashboard:
    create: true
    securityMode: false
  controllerManager:
    replicaCount: 1
  chaosDaemon:
    runtime: containerd
    socketPath: /run/containerd/containerd.sock
```

```bash
helm install chaos-mesh-instance startx/chaos-mesh -f my-mesh-values.yaml -n chaos-mesh
```

### Minimal deployment (no dashboard)

Deploy chaos-mesh engine only, without the web dashboard, for CLI/CR-driven chaos scenarios:

```yaml
# my-mesh-minimal-values.yaml
mesh:
  enabled: true
  dashboard:
    create: false
  controllerManager:
    replicaCount: 1
```

```bash
helm install chaos-mesh-minimal startx/chaos-mesh -f my-mesh-minimal-values.yaml -n chaos-mesh
```

### Apply a PodChaos experiment after deployment

Once chaos-mesh is deployed, apply a `PodChaos` CR directly to kill pods at random:

```yaml
# pod-chaos-example.yaml
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
      "app.kubernetes.io/name": "myapp"
  scheduler:
    cron: "@every 10m"
```

```bash
oc apply -f pod-chaos-example.yaml
```

## History

| Release  | Date       | Description                                                                                                                                              |
| -------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
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
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |

# ![chaos](https://helm-repository.readthedocs.io/en/latest/img/chaos.svg "Chaos Chart : Umbrella") Chaos Chart : Main
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+startx)

This helm chart is used to deploy a chaos test suite composed of cerberus, kraken, litmus, chaos mesh and kube-monkey.

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
helm show chart startx/chaos
```

### 4. Install this suite

```bash
# Install the projects
helm install \
--set cerberus.enabled=true --set cerberus.project.enabled=true  \
--set kraken.enabled=true --set kraken.project.enabled=true  \
--set litmus.enabled=true --set litmus.project.enabled=true  \
--set mesh.enabled=true --set mesh.project.enabled=true  \
--set monkey.enabled=true --set monkey.project.enabled=true  \
chaos-projects  startx/chaos
# Deploy the cerberus instance
helm install \
--set cerberus.enabled=true --set cerberus.cerberus.enabled=true  \
chaos-cerberus-instance  startx/chaos-cerberus
# Deploy the kraken instance in a job mode
helm install \
--set kraken.enabled=true --set kraken.kraken.enabled=true  \
--set kraken.kraken.mode=job  \
chaos-kraken-instance-job  startx/chaos-kraken
# Deploy the kraken instance with tekton pipeline (require pipeline been installed)
helm install \
--set kraken.enabled=true --set kraken.kraken.enabled=true  \
--set kraken.kraken.mode=pipeline \
chaos-kraken-instance-pipeline  startx/chaos-kraken
# Deploy the litmus instance
helm install \
--set litmus.enabled=true --set litmus.litmus.enabled=true  \
chaos-litmus-instance  startx/chaos-litmus
# Deploy the mesh instance
helm install \
--set mesh.enabled=true --set mesh.mesh.enabled=true  \
chaos-mesh-instance  startx/chaos-mesh
# Deploy the monkey instance
helm install \
--set monkey.enabled=true --set monkey.monkey.enabled=true  \
chaos-monkey-instance  startx/chaos-monkey
```

### 5. Manage with ArgoCD

### Deploy via ArgoCD Applications

`chaos` is an umbrella chart. The recommended GitOps approach is one AppProject shared across the suite and one Application per sub-chart (cerberus, kraken, litmus, mesh, monkey) to allow independent lifecycle management.

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/chaos/examples/argocd/
oc apply -k .
```



## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                                                                                                                                                                                                                                               |
| ------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)                                                                                                                                                                                                                                     |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                                                                                                                                                                                                                                           |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod)                                                                                                                                                                                                                         |
| context.component   | demo      | Component name of this application (logical tenant)                                                                                                                                                                                                                                                       |
| context.app         | generic     | Application name (functional tenant, default use Chart name)                                                                                                                                                                                                                                             |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                                                                                                                                                                                                                                           |
| cerberus            | {...}     | Configuration of the cerberus component. Inherit from the [chaos-cerberus chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-cerberus) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-cerberus/#chaos-cerberus-values-dictionary) for more options) |
| kraken              | {...}     | Configuration of the kraken component. Inherit from the [chaos-kraken chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-kraken) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-kraken/#chaos-kraken-values-dictionary) for more options)           |
| litmus              | {...}     | Configuration of the litmus component. Inherit from the [chaos-litmus chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-litmus) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-litmus/#chaos-litmus-values-dictionary) for more options)           |
| mesh                | {...}     | Configuration of the chaos-mesh component. Inherit from the [chaos-mesh chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-mesh) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-mesh/#chaos-mesh-values-dictionary) for more options)               |
| monkey              | {...}     | Configuration of the kube-monkey component. Inherit from the [chaos-monkey chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-monkey) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-monkey/#chaos-monkey-values-dictionary) for more options)      |

## Values files

### Default values file (values.yaml)

#### Deploy chaos namespaces

Deploy the chaos test suite environment :

- 1 **project** named **chaos-cerberus**
- 1 **project** named **chaos-kraken**
- 1 **project** named **chaos-litmus**
- 1 **project** named **chaos-mesh**
- 1 **project** named **chaos-monkey**

```bash
helm install \
 --set cerberus.enable=true --set cerberus.project.enable=true \
 --set kraken.enable=true   --set kraken.project.enable=true \
 --set litmus.enable=true   --set litmus.project.enable=true \
 --set mesh.enable=true     --set mesh.project.enable=true \
 --set monkey.enable=true   --set monkey.project.enable=true \
 chaos startx/chaos
```

#### Deploy cerberus

Deploy the cerberus component

```bash
helm install \
--set cerberus.enable=true --set cerberus.cerberus.enable=true \
chaos-cerberus startx/chaos-cerberus
```

#### Deploy kraken

Deploy the kraken component

```bash
helm install \
--set kraken.enable=true --set kraken.kraken.enable=true \
chaos-kraken startx/chaos-kraken
```

#### Deploy litmus

Deploy the litmus component

```bash
helm install \
--set litmus.enable=true --set litmus.litmus.enable=true \
chaos-litmus startx/chaos-litmus
```

#### Deploy Chaos-mesh

Deploy the chaos-mesh component

```bash
helm install \
--set mesh.enable=true --set mesh.mesh.enable=true \
chaos-mesh startx/chaos-mesh
```

#### Deploy Kube-monkey

Deploy the kube-monkey component

```bash
helm install \
--set monkey.enable=true --set monkey.monkey.enable=true \
chaos-monkey startx/chaos-monkey
```

## Usage examples

### Deploy the full chaos suite in sequence

The recommended deployment order: namespaces first, then cerberus (healthcheck), then engines.

```bash
# 1. Create all chaos namespaces
helm install chaos-namespaces startx/chaos \
  --set cerberus.enabled=true --set cerberus.project.enabled=true \
  --set kraken.enabled=true   --set kraken.project.enabled=true \
  --set litmus.enabled=true   --set litmus.project.enabled=true \
  --set mesh.enabled=true     --set mesh.project.enabled=true \
  --set monkey.enabled=true   --set monkey.project.enabled=true

# 2. Deploy cerberus (healthcheck watchdog) first
helm install chaos-cerberus startx/chaos-cerberus \
  --set cerberus.enabled=true \
  --set cerberus.kubeconfig.mode=token \
  --set cerberus.kubeconfig.token.server=https://api.prod.example.com:6443 \
  --set cerberus.kubeconfig.token.token=sha256~REPLACE \
  -n chaos-cerberus

# 3. Deploy the kraken chaos engine (pipeline mode)
helm install chaos-kraken startx/chaos-kraken \
  --set kraken.enabled=true \
  --set kraken.mode=pipeline \
  --set kraken.cerberusUrl=http://cerberus.chaos-cerberus.svc.cluster.local:8080 \
  --set kraken.kubeconfig.mode=token \
  --set kraken.kubeconfig.token.server=https://api.prod.example.com:6443 \
  --set kraken.kubeconfig.token.token=sha256~REPLACE \
  -n chaos-kraken
```

### Deploy only cerberus + kraken (minimal chaos pair)

```yaml
# my-chaos-minimal-values.yaml
cerberus:
  enabled: true
  cerberus:
    enabled: true
    kubeconfig:
      mode: token
      token:
        server: https://api.prod.example.com:6443
        token: sha256~REPLACE

kraken:
  enabled: true
  kraken:
    enabled: true
    mode: job
    cerberusUrl: http://cerberus.chaos-cerberus.svc.cluster.local:8080
    kubeconfig:
      mode: token
      token:
        server: https://api.prod.example.com:6443
        token: sha256~REPLACE
```

```bash
helm install my-chaos startx/chaos -f my-chaos-minimal-values.yaml
```

## History

| Release   | Date       | Description                                                                                                             |
| --------- | ---------- | ----------------------------------------------------------------------------------------------------------------------- |
| 16.19.59  | 2024-12-09 | Align all chart to the 16.19.59 release                                                                                 |
| 17.14.19  | 2025-03-12 | Align all chart to the 17.14.19 release                                                                                 |
| 17.14.90  | 2025-04-30 | Publish stable release for 4.17 version                                                                                 |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.15 | 2026-03-02 | Prepare upgrading dependency to 19.23.11 |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.7 | 2026-03-02 | Update dependencies to version 20.14.0 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.1 | 2026-03-02 | Prepare release 21.3.x with 21.x dependencies |
| 21.3.1 | 2026-03-02 | Prepare release 21.3.x with 21.x dependencies |
| 21.3.3 | 2026-03-02 | Upgrade dependencies to v21.3.0 |
| 21.3.3 | 2026-03-02 | Upgrade dependencies to v21.3.0 |
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.105 | 2026-06-20 | Improve chaos options |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |
| 21.3.107 | 2026-06-21 | publish stable update for the full repository |
| 21.3.107 | 2026-06-21 | publish stable update for the full repository |
| 21.3.107 | 2026-06-21 | publish stable update for the full repository |
| 21.3.167 | 2026-06-23 | publish stable update for the full repository |
| 21.3.181 | 2026-06-23 | publish stable update for the full repository |
| 21.3.182 | 2026-06-23 | publish stable update for the full repository |
| 21.3.199 | 2026-06-24 | publish stable update for the full repository |
| 21.3.201 | 2026-06-24 | publish stable update for the full repository |
| 21.3.202 | 2026-06-24 | publish stable update for the full repository |
| 21.3.205 | 2026-06-24 | publish stable update for the full repository |
| 21.3.229 | 2026-08-08 | publish stable update for the full repository |
| 21.3.270 | 2026-08-08 | publish stable update for the full repository |

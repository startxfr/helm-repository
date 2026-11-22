# ![chaos](https://helm-repository.readthedocs.io/en/latest/img/chaos.svg "Chaos Chart : Umbrella") Chaos Chart : Main
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+startx)

This helm chart is used to deploy a chaos test suite composed of cerberus, kraken (krkn), Tekton chaos pipelines, litmus, chaos mesh and kube-monkey.

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
--set pipeline.enabled=true --set pipeline.project.enabled=true  \
--set litmus.enabled=true --set litmus.project.enabled=true  \
--set mesh.enabled=true --set mesh.project.enabled=true  \
--set monkey.enabled=true --set monkey.project.enabled=true  \
chaos-projects  startx/chaos
# Deploy the cerberus instance
helm install -n chaos-cerberus \
--set cerberus.enabled=true  \
chaos-cerberus-instance  startx/chaos-cerberus
# Run a krkn (kraken) chaos job with one scenario
helm install -n chaos-kraken \
--set kraken.enabled=true --set kraken.scenarios.pods-monitoring.enabled=true  \
chaos-kraken-run  startx/chaos-kraken
# Deploy the Tekton chaos pipelines (requires OpenShift Pipelines)
helm install -n chaos-pipeline \
--set pipeline.enabled=true  \
chaos-pipeline-instance  startx/chaos-pipeline
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

`chaos` is an umbrella chart. The recommended GitOps approach is one AppProject shared across the suite and one Application per sub-chart (cerberus, kraken, pipeline, litmus, mesh, monkey) to allow independent lifecycle management.

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/chaos/examples/argocd/
oc apply -k .
```



## Values files

### Default values file (values.yaml)

#### Deploy chaos namespaces

Deploy the chaos test suite environment :

- 1 **project** named **chaos-cerberus**
- 1 **project** named **chaos-kraken**
- 1 **project** named **chaos-pipeline**
- 1 **project** named **chaos-litmus**
- 1 **project** named **chaos-mesh**
- 1 **project** named **chaos-monkey**

```bash
helm install \
 --set cerberus.enabled=true --set cerberus.project.enabled=true \
 --set kraken.enabled=true   --set kraken.project.enabled=true \
 --set litmus.enabled=true   --set litmus.project.enabled=true \
 --set mesh.enabled=true     --set mesh.project.enabled=true \
 --set monkey.enabled=true   --set monkey.project.enabled=true \
 chaos startx/chaos
```

#### Deploy cerberus

Deploy the cerberus component

```bash
helm install -n chaos-cerberus \
--set cerberus.enabled=true \
chaos-cerberus startx/chaos-cerberus
```

#### Deploy kraken

Deploy the kraken component

```bash
helm install -n chaos-kraken \
--set kraken.enabled=true --set kraken.scenarios.pods-monitoring.enabled=true \
chaos-kraken startx/chaos-kraken
```

#### Deploy litmus

Deploy the litmus component

```bash
helm install \
--set litmus.enabled=true --set litmus.litmus.enabled=true \
chaos-litmus startx/chaos-litmus
```

#### Deploy Chaos-mesh

Deploy the chaos-mesh component

```bash
helm install \
--set mesh.enabled=true --set mesh.mesh.enabled=true \
chaos-mesh startx/chaos-mesh
```

#### Deploy Kube-monkey

Deploy the kube-monkey component

```bash
helm install \
--set monkey.enabled=true --set monkey.monkey.enabled=true \
chaos-monkey startx/chaos-monkey
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                                                                                                                                                                                                                                               |
| ------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organizational tenant)                                                                                                                                                                                                                                     |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                                                                                                                                                                                                                                           |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod)                                                                                                                                                                                                                         |
| context.component   | demo      | Component name of this application (logical tenant)                                                                                                                                                                                                                                                       |
| context.app         | generic     | Application name (functional tenant, default use Chart name)                                                                                                                                                                                                                                             |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                                                                                                                                                                                                                                           |
| cerberus            | {...}     | Configuration of the cerberus component. Inherit from the [chaos-cerberus chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-cerberus) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-cerberus/#chaos-cerberus-values-dictionary) for more options) |
| kraken              | {...}     | Configuration of the kraken component. Inherit from the [chaos-kraken chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-kraken) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-kraken/#chaos-kraken-values-dictionary) for more options)           |
| pipeline            | {...}     | Configuration of the Tekton chaos pipelines. Inherit from the [chaos-pipeline chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-pipeline) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-pipeline/#chaos-pipeline-values-dictionary) for more options) |
| litmus              | {...}     | Configuration of the litmus component. Inherit from the [chaos-litmus chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-litmus) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-litmus/#chaos-litmus-values-dictionary) for more options)           |
| mesh                | {...}     | Configuration of the chaos-mesh component. Inherit from the [chaos-mesh chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-mesh) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-mesh/#chaos-mesh-values-dictionary) for more options)               |
| monkey              | {...}     | Configuration of the kube-monkey component. Inherit from the [chaos-monkey chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-monkey) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-monkey/#chaos-monkey-values-dictionary) for more options)      |

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
  -n chaos-cerberus

# 3. Deploy the Tekton chaos pipelines, gated by cerberus
helm install chaos-pipeline startx/chaos-pipeline \
  --set pipeline.enabled=true \
  --set pipeline.cerberus.url=http://cerberus.chaos-cerberus.svc.cluster.local:8080 \
  -n chaos-pipeline

# 4. Or run a single krkn (kraken) chaos job
helm install chaos-kraken startx/chaos-kraken \
  --set kraken.enabled=true \
  --set kraken.scenarios.pods-monitoring.enabled=true \
  --set kraken.cerberus.enabled=true \
  --set kraken.cerberus.url=http://cerberus.chaos-cerberus.svc.cluster.local:8080 \
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
| 17.14.90  | 2025-04-30 | Publish stable release for 4.17 version                                                                                 |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.313 | 2026-11-04 | Add cluster-unifai and cluster-qdrant, align all charts to 21.3.313 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.361 | 2026-11-10 | Fix chaos-mesh dependency pin |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.373 | 2026-11-19 | align inter-chart dependency pins |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.391 | 2026-11-21 | chaos charts: krkn v5.2.15, new chaos-pipeline chart, security fixes for litmus and monkey; breaking, see README migration notes |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.400 | 2026-11-22 | fix: krkn-run no longer exits after a healthy cerberus signal (exit_on_failure), ClusterOperator check hardened, exitOnFailure refused with cerberus |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |

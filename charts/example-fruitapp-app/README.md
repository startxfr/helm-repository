# ![example-fruitapp-app](https://helm-repository.readthedocs.io/en/latest/img/example-fruitapp-app.svg "Example Chart : Fruitapp - App") Example Chart : Fruitapp - App
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_example--fruitapp--app-E28A2B.svg)](https://artifacthub.io/packages/search?ts_query_web=example+fruitapp+startx)

This helm chart is used to deploy the fruitapp application into a namespace created using the
`example-fruitapp-project` helm chart. Furthemore, your project should have a runing database and
related shared services as the one deployed with `example-fruitapp-shared` helm chart.

This chart is part of the [example-fruitapp-xxx startx helm chart series](https://helm-repository.readthedocs.io#examples-helm-charts) focused on deploying various kind of application consuming the cluster services deployed using the [cluster-xxx charts](https://helm-repository.readthedocs.io#cluster-helm-charts).

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
helm show chart startx/example-fruitapp-app
```

### 4. Install this chart

```bash
helm install example-fruitapp-app startx/example-fruitapp-app
```

## Values files

### Default values file (values.yaml)

Deploy all app services for a given namespace with the following characteristics :

- 1 **deployment** named **fruitapp-v3-2-11** with
  - **2** replicas
  - **128Mi** max memory
- 1 **service** named **fruitapp-v3-2-11** load-balancing to pod from this release
- 1 **route** named **frontend** routing to the **fruitapp-v3-2-11 service**. This route could be shared among multiple version of the application

```bash
# base configuration running default configuration
helm install example-fruitapp-app startx/example-fruitapp-app
```

### Other values files

- **mc** : [values-mc.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-fruitapp-app/values-mc.yaml)
helm install example-fruitapp-app startx/example-fruitapp-app -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-fruitapp-app/values-mc.yaml

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organizational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | fruitapp     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### example-fruitapp-app values dictionary

| Key                   | Default          | Description                                                                                 |
| --------------------- | ---------------- | ------------------------------------------------------------------------------------------- |
| namespace             | fruitapp-preprod | Project used fot these resources                                                           |
| frontend              | {}               | Configuration of the frontend components                                                    |
| frontend.enabled      | true             | Enable frontend for this project                                                            |
| frontend.name         | fruitapp         | Microservice name used                                                                      |
| frontend.memory_limit | 128Mi            | Microservice memory limit                                                                   |
| frontend.replicas     | 2                | The number of replicas to apply                                                             |
| frontend.version      | v3.2.11          | The appication version (should be one of latest, v3.2.8, v3.2.11 or any existing image tag) |

## Deploy with ArgoCD

### Deploy via ArgoCD Application

`example-fruitapp-app` can be deployed by ArgoCD with a single `Application`. Adapt the destination namespace and the values to your
cluster.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: example-fruitapp-app
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com/stable
    chart: example-fruitapp-app
    # pin an exact version in production (ADR-0004)
    targetRevision: 21.3.410
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default-fruitapp-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```


## History

| Release  | Date       | Description                                                      |
| -------- | ---------- | ---------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
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
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |

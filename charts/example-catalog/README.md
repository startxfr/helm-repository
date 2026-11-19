# ![example-catalog](https://helm-repository.readthedocs.io/en/latest/img/example-catalog.svg "Example Chart : Catalog") Example Chart : catalog
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_example--catalog-E28A2B.svg)](https://artifacthub.io/packages/search?ts_query_web=example+catalog+startx)

This helm chart is chart used to deploy various example of application used in Startx demo and mostly based on [sxapi helm chart](https://helm-repository.readthedocs.io/en/latest/charts/sxapi) microservice framework.

This chart is part of the [example-xxx startx helm chart series](https://helm-repository.readthedocs.io#examples-helm-charts) focused on deploying various kind of application consuming the cluster services deployed using the [cluster-xxx charts](https://helm-repository.readthedocs.io#cluster-helm-charts).

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
helm show chart startx/example-catalog
```

### 4. Install this chart

```bash
helm install example-catalog startx/example-catalog
```

## Other available values

- **aap** : [values-aap.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-aap.yaml)
- **affinity** : [values-affinity.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-affinity.yaml)
- **costs** : [values-costs.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-costs.yaml)
- **elasticsearch** : [values-elasticsearch.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-elasticsearch.yaml)
- **hugo** : [values-hugo.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-hugo.yaml)
- **istio-mg** : [values-istio-mg.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-istio-mg.yaml)
- **istio** : [values-istio.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-istio.yaml)
- **keycloak** : [values-keycloak.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-keycloak.yaml)
- and 16 more `values-*.yaml` files: see the [chart directory](https://github.com/startxfr/helm-repository/tree/master/charts/example-catalog)

```bash
helm install example-catalog startx/example-catalog -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-aap.yaml
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organizational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | example-catalog     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### example-catalog values dictionary

| Key                   | Default    | Description                                           |
| --------------------- | ---------- | ----------------------------------------------------- |
| sxapi.service.enabled | false      | Enable service for this application                   |
| sxapi.version         | 0.3.63     | Sxapi image version to run                            |
| sxapi.profile         | prod:start | Profile to run inside the container                   |
| sxapi.debug           | true       | Enable debuging of the container                      |
| sxapi.replicas        | 1          | Define the number of replicas for this sxapi instance |
| sxapi.data            | string     | Files to load into the application                    |

## Values files

### Default values file (values.yaml)

Complete deployment of an sxapi application with the following characteristics :

- 1 **service** named **example-catalog** load balancing to pod deployed
- 1 **deployment** named **example-catalog** deploying **1 pod** from version **0.3.63** sxapi image running the **prod:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running default configuration
helm install example-catalog startx/example-catalog
```

### Development values file (values-dev.yaml)

Complete deployment of a sxapi development application with the following characteristics :

- 1 **service** named **example-catalog-dev** load balancing to pod deployed
- 1 **deployment** named **example-catalog-dev** deploying **1 pod** from version **0.3.63** sxapi image running the **dev:start** command with debug disabled
- 2 **configMap** holding sxapi configuration and pod environment variable context

```bash
# base configuration running tekton v1.0.1 configuration
helm install example-catalog startx/example-catalog -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-catalog/values-dev.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

`example-catalog` can be deployed by ArgoCD with a single `Application`. Adapt the destination namespace and the values to your
cluster.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: example-catalog
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com/stable
    chart: example-catalog
    # pin an exact version in production (ADR-0004)
    targetRevision: 21.3.379
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default-catalog
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```


## History

| Release  | Date       | Description                                                                                       |
| -------- | ---------- | ------------------------------------------------------------------------------------------------- |
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
| 21.3.361 | 2026-11-10 | Fix dependency version pins |
| 21.3.370 | 2026-11-18 | publish stable update for the full repository |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.373 | 2026-11-19 | align inter-chart dependency pins |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |

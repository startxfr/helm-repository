# ![example-deployment](https://helm-repository.readthedocs.io/en/latest/img/example-deployment.svg "Example Chart : Simple deployment") Example Chart : Deployment
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_example--deployment-E28A2B.svg)](https://artifacthub.io/packages/search?ts_query_web=example+deployment+startx)

This helm chart is used to create a deployment of various application images according to the values file.

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
helm show chart startx/example-deployment
```

### 4. Install this chart

```bash
helm install example-deployment startx/example-deployment
```

## Other available values

- **apache** : [values-apache.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-apache.yaml)
- **demo** : [values-demo.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-demo.yaml)
- **mariadb** : [values-mariadb.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-mariadb.yaml)
- **quay-secvuln** : [values-quay-secvuln.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-quay-secvuln.yaml)

```bash
helm install example-deployment startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-deployment/values-apache.yaml
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organizational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | example-deployment     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### example-deployment values dictionary

| Key      | Default       | Description                                                      |
| -------- | ------------- | ---------------------------------------------------------------- |
| image    | fedora:latest | Image to run into the pod                                        |
| command  | /bin/sx       | Command to run inside the container                              |
| args     | run           | argunments to pass to the command exectuted inside the container |
| debug    | true          | Enable debuging of the container                                 |
| replicas | 1             | Define the number of replicas for this sxapi instance            |

## Values files

### Default values file (values.yaml)

Simple deployment of a container image with the following characteristics :

- 1 **deployment** named **example-deployment** of **1 pod** running **quay.io/startx/fedora:latest** image
- 1 **service** named **example-deployment**

```bash
# base configuration running default configuration
helm install example-deployment startx/example-deployment
```

### Demo values file (values-demo.yaml)

Deployment of an demo container image with the following characteristics :

- 1 **pod** named **demo-helm-deployment** of **2 pods** running **quay.io/startx/apache:latest** image
- 1 **service** named **demo-helm-deployment**

```bash
# Configuration running demo example configuration
helm install example-deployment-demo startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-demo.yaml
```

### Apache values file (values-apache.yaml)

Deployment of an apache container image with the following characteristics :

- 1 **pod** named **example-deployment-apache** of **2 pods** running **quay.io/startx/apache:latest** image
- 1 **service** named **example-deployment-apache**

```bash
# Configuration running apache example configuration
helm install example-deployment-apache startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-apache.yaml
```

### MariaDB values file (values-mariadb.yaml)

Deployment of an mariadb container image with the following characteristics :

- 1 **pod** named **example-deployment-mariadb** of **2 pods** running **quay.io/startx/mariadb:latest** image
- 1 **service** named **example-deployment-mariadb**

```bash
# Configuration running mariadb example configuration
helm install example-deployment-mariadb startx/example-deployment -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-mariadb.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

`example-deployment` can be deployed by ArgoCD with a single `Application`. Adapt the destination namespace and the values to your
cluster.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: example-deployment
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com/stable
    chart: example-deployment
    # pin an exact version in production (ADR-0004)
    targetRevision: 21.3.390
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default-deployment
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```


## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
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

# ![chaos-litmus](https://helm-repository.readthedocs.io/en/latest/img/chaos-litmus.svg "Chaos Chart : Litmus") Chaos Chart : Litmus
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--litmus-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+litmus+startx)

This helm chart used to deploy litmus on Openshift or Kubernetes cluster.
Litmus is a chaos engineering platform for designing, scheduling, and orchestrating chaos experiments on Kubernetes clusters.

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
helm show chart startx/chaos-litmus
```

### 4. Install this component

```bash
# Install the litmus project
helm install --set project.enabled=true chaos-litmus-project  startx/chaos-litmus
# Deploy the litmus instance
helm install --set litmus.enabled=true -n chaos-litmus chaos-litmus-instance startx/chaos-litmus
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | litmus     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### chaos-litmus values dictionary

| Key            | Default | Description                                                                                                                                                                                                                                                                       |
| -------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project        | {...}   | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/project/#project-values-dictionary) for more options) |
| project.enable | false   | Enable creation of the namespace                                                                                                                                                                                                                                                  |
| litmus         | {...}   | Configuration of the litmus deployment. Inherit from the [official litmus chart](https://litmuschaos.github.io/litmus-helm) (see [chart options](https://litmuschaos.github.io/litmus-helm) for more options)                                                                     |
| litmus.enable  | false   | Enable deploying the litmus chaos engine                                                                                                                                                                                                                                              |

## Values files

### Default values file (values.yaml)

Simple litmus with default configuration :

- 1 **project** named **chaos-litmus**
- 1 **scc** with privileged context for 9 **litmus** serviceaccount
- 1 **litmus** deployment using official helm chart
- 1 **route** to the **litmus** service

```bash
# Running the default configuration
helm install --set project.enable=true chaos-litmus-project startx/chaos-litmus
helm install --set litmus.enable=true chaos-litmus-instance startx/chaos-litmus
```

### STARTX values file (values-startx-xxx.yaml)

Same as the default configuration but with namespace prefixed with startx-

```bash
# Configuration running demo example configuration
helm install chaos-litmus-project startx/chaos-litmus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-litmus/values-startx-project.yaml
helm install chaos-litmus-deploy startx/chaos-litmus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-litmus/values-startx-deploy.yaml
```

## Usage examples

### Deploy litmus portal with web UI

Enable the LitmusChaos control plane and expose it via an OpenShift route:

```yaml
# my-litmus-values.yaml
context:
  scope: myorg
  cluster: prod-cluster
  environment: chaos
  component: litmus
  app: litmus-chaos

litmus:
  enabled: true
  portal:
    enabled: true
    server:
      graphqlServer:
        genericEnv:
          CHAOS_CENTER_UI_ENDPOINT: https://litmus-frontend.chaos-litmus.apps.prod-cluster.example.com
```

```bash
helm install chaos-litmus-instance startx/chaos-litmus -f my-litmus-values.yaml -n chaos-litmus
```

### Minimal deployment (backend only, no UI)

Deploy the litmus backend without the frontend portal, useful for API-only usage:

```yaml
# my-litmus-minimal-values.yaml
litmus:
  enabled: true
  portal:
    enabled: true
    frontend:
      enabled: false
    server:
      enabled: true
```

```bash
helm install chaos-litmus-minimal startx/chaos-litmus -f my-litmus-minimal-values.yaml -n chaos-litmus
```

### Full stack with namespace

```bash
# 1. Create the namespace
helm install chaos-litmus-project startx/chaos-litmus \
  --set project.enabled=true \
  -n default

# 2. Deploy litmus portal
helm install chaos-litmus startx/chaos-litmus \
  --set litmus.enabled=true \
  -n chaos-litmus
```

## ArgoCD deployment

### Deploy via ArgoCD Application

`chaos-litmus` follows the project/instance pattern. The litmus portal includes a frontend and a backend — both are enabled by default when `litmus.enabled=true`.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: chaos-litmus
  namespace: openshift-gitops
spec:
  description: Deploy Litmus chaos engineering portal on OpenShift
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
    - 'https://litmuschaos.github.io/litmus-helm'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: chaos-litmus
    - server: https://kubernetes.default.svc
      namespace: default
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: project.openshift.io
      kind: ProjectRequest
    - group: security.openshift.io
      kind: SecurityContextConstraints
    - group: rbac.authorization.k8s.io
      kind: ClusterRoleBinding
    - group: apiextensions.k8s.io
      kind: CustomResourceDefinition
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: chaos-litmus-project
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: chaos-litmus
  source:
    chart: chaos-litmus
    helm:
      values: |
        project:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.105
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: chaos-litmus-instance
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: chaos-litmus
    server: https://kubernetes.default.svc
  project: chaos-litmus
  source:
    chart: chaos-litmus
    helm:
      values: |
        litmus:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.105
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply with:

```bash
kubectl apply -f chaos-litmus-argocd.yaml -n openshift-gitops
```

## History

| Release  | Date       | Description                                                                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
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
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-20 | Improve chaos-litmus options |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |

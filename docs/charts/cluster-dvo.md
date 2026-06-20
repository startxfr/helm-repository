# ![cluster-dvo](https://helm-repository.readthedocs.io/en/latest/img/cluster-dvo.svg "Cluster Chart : DVO") Cluster Chart : DVO
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--dvo-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+dvo+startx)

This helm chart is used to deploy the Deployment Validation Operator (DVO). This operator checks deployments and other resources against a curated collection of best practices.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use theses resources.

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
helm show chart startx/cluster-dvo
```

### 4. Install this chart

```bash
helm install cluster-dvo startx/cluster-dvo
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **operator:** named **deployment-validation-operator** configured with
  - The **alpha** channel for community release
  - The **v0.7.14** version
  - Deployed under **openshift-operators** (AllNamespaces — DVO watches all namespaces)

```bash
# Create the project
helm install cluster-dvo-project startx/cluster-dvo --set project.enabled=true,operator.enabled=false,dvo.enabled=false
# Deploy the DVO operator
helm install cluster-dvo-operator startx/cluster-dvo --set project.enabled=false,operator.enabled=true,dvo.enabled=false && sleep 10
# Configure default DVO resources
helm install cluster-dvo-instance startx/cluster-dvo --set project.enabled=false,operator.enabled=false,dvo.enabled=true
```

## Other available values

- **startx** : DVO operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-dvo/values-startx.yaml))

```bash
helm install cluster-dvo startx/cluster-dvo -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-dvo/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-dvo
  namespace: openshift-gitops
spec:
  description: Deploy Deployment Validation Operator and configure DVO at cluster level
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-operators
      server: https://kubernetes.default.svc
    - namespace: openshift-gitops
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
```

### Applications

> DVO requires AllNamespaces scope to validate deployments across the whole cluster. The subscription goes directly into `openshift-operators` — no dedicated namespace or OperatorGroup needed.

```yaml
---
# Wave 5 — DVO operator subscription in openshift-operators (AllNamespaces, no project wave needed)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-dvo-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-dvo
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-dvo
    targetRevision: 21.3.67
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: false
        operator:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-operators
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Wave 10 — Grafana dashboard for DVO metrics (disabled by default)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-dvo-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-dvo
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-dvo
    targetRevision: 21.3.67
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        grafana:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: deployment-validation-monitoring
  ignoreDifferences:
    - group: grafana.integreatly.org
      kind: Grafana
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                  |
| -------- | ---------- | -------------------------------------------- |
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
| 21.3.12 | 2026-06-18 | Improve cluster-dvo options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |

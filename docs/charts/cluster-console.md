# ![cluster-console](https://helm-repository.readthedocs.io/en/latest/img/cluster-console.svg "Cluster Chart : Console") Cluster Chart : Console
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--console-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+console+startx)

This helm chart is used to configure openshift console at the cluster level.

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
helm show chart startx/cluster-console
```

### 4. Install this chart

```bash
helm install cluster-console startx/cluster-console
```

## Default values

Complete deployment of a project with the following characteristics :

Complete deployment of a cluster console configuration with the following characteristics :

- 1 **console** configuration with custom links, notifications and logo
- 1 **webTerminal** operator for in-browser terminal accesss

```bash
# base configuration running default configuration
helm install cluster-console startx/cluster-console
```

## Others values availables

- **startx** : Startx Openshift Console customization (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-console/values-startx.yaml))

```bash
helm install cluster-console startx/cluster-console -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-console/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-console
  namespace: openshift-gitops
spec:
  description: Configure OpenShift console and deploy web-terminal operator
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-config
      server: https://kubernetes.default.svc
    - namespace: openshift-console
      server: https://kubernetes.default.svc
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

```yaml
---
# Deploys web-terminal operator in openshift-operators (shared namespace, OG already exists)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-console-webterminal
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-console
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-console
    targetRevision: 21.3.56
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        console:
          enabled: false
        webTerminal:
          enabled: true
          subscription:
            enabled: true
          operatorGroup:
            enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Configures console: branding, links, notifications and log links
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-console-personalize
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-console
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-console
    targetRevision: 21.3.56
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        console:
          enabled: true
          namespace: openshift-config
          state: Managed
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-config
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                                                                                      |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.73 | 2026-01-21 | Change in devo logo |
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
| 21.3.12 | 2026-06-18 | Update context version to 4.21.3, web-terminal operator to v1.14.0, add ArgoCD deployment examples |
| 21.3.13 | 2026-06-18 | Improve cluster-console options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |

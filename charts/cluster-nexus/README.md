# ![cluster-nexus](https://helm-repository.readthedocs.io/en/latest/img/cluster-nexus.svg "Cluster Chart : Nexus") Cluster Chart : nexus
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--nexus-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+nexus+startx)

This helm chart is used to deploy Nexus instances managed by a dedicated operator.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

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
helm show chart startx/cluster-nexus
```

### 4. Install this chart

```bash
helm install cluster-nexus startx/cluster-nexus
```

## Default values

Complete deployment with the following characteristics:

- Deploy a **Subscription** named `nexus-repository-ha-operator-certified` in `openshift-operators`
- Deploy an **OperatorGroup** named `global-operators` in `openshift-operators` (all-namespaces scope)
- The `project` sub-chart is disabled - `openshift-operators` is a pre-existing system namespace

```bash
# base configuration running default configuration
helm install cluster-nexus startx/cluster-nexus
```

## Other available values

- **startx** : Nexus operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nexus/values-startx.yaml))

```bash
helm install cluster-nexus startx/cluster-nexus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nexus/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Create an ArgoCD `Application` resource to deploy `cluster-nexus` from the STARTX S3 Helm repository.
This example deploys the Nexus HA operator in `openshift-operators` (all-namespaces scope).
The `project` sub-chart is disabled since `openshift-operators` is a pre-existing system namespace:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-nexus
  namespace: openshift-gitops
spec:
  description: Deploy the Nexus Repository HA operator on OpenShift
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: openshift-operators
    - server: https://kubernetes.default.svc
      namespace: '*'
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: operators.coreos.com
      kind: OperatorGroup
    - group: operators.coreos.com
      kind: Subscription
    - group: sonatype.com
      kind: NexusRepo
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-nexus-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  destination:
    namespace: openshift-operators
    server: https://kubernetes.default.svc
  project: cluster-nexus
  source:
    chart: cluster-nexus
    helm:
      values: |
        project:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.68
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-nexus-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: openshift-operators
    server: https://kubernetes.default.svc
  project: cluster-nexus
  source:
    chart: cluster-nexus
    helm:
      values: |
        operator:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.68
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-nexus-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: openshift-operators
    server: https://kubernetes.default.svc
  project: cluster-nexus
  source:
    chart: cluster-nexus
    helm:
      values: |
        nexus:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.68
  ignoreDifferences:
    - group: sonatype.com
      kind: NexusRepo
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply with:

```bash
kubectl apply -f cluster-nexus-argocd.yaml -n openshift-gitops
```

The automated sync policy ensures ArgoCD reconciles the Nexus Repository operator whenever the chart or values drift from the desired state.

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
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
| 21.3.4 | 2026-06-17 | Improve cluster-nexus options |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.12 | 2026-06-17 | Improve cluster-nexus options |
| 21.3.13 | 2026-06-17 | Improve cluster-nexus options |
| 21.3.14 | 2026-06-17 | Improve schema for nexus |
| 21.3.15 | 2026-06-17 | Improve cluster-nexus options |
| 21.3.16 | 2026-06-17 | Improve cluster-nexus options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |

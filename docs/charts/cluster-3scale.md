# ![cluster-3scale](https://helm-repository.readthedocs.io/en/latest/img/cluster-3scale.svg "Cluster Chart : 3Scale") Cluster Chart : 3Scale (API Management)
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--3scale-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+3scale+startx)

This helm chart is used to create a deployment of a 3scale, operator based, deployment of 3Scale API management tools.

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
helm show chart startx/cluster-3scale
```

### 4. Install this chart

```bash
helm install cluster-3scale startx/cluster-3scale
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **startx-3scale** with the following properties
  - 1 **LimitRange:** defined for this projet
  - 1 **Quotas:** defined for this projet
  - 3 **RBAC:** allowing **mygroup_example** to **edit** resources
- 1 **operator:** named **3scale-operator** configured with
  - The **threescale-2.13** channel
  - The **0.10.5** version
  - Deployed under the **openshift-operators** project
  - The **manager** deployed
- 1 **Secret:** named **startx-3scale-rhn** that hold rhn credentials used fo image pulling

```bash
# base configuration running default configuration
helm install cluster-3scale startx/cluster-3scale
```

## Other available values

- **startx** : Startx 3scale cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-3scale/values-startx.yaml))

```bash
helm install cluster-3scale startx/cluster-3scale -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-3scale/values-startx.yaml
```

### Deploy via ArgoCD Application

Deploy `cluster-3scale` using three dedicated ArgoCD Applications sharing the same AppProject.
The 3scale operator runs in `openshift-operators` (all-namespaces scope); APIManager instances are deployed in `startx-3scale`.

> **3scale 2.16+ requires external databases.** The optional `clusterRedis` and `clusterCrunchy` sub-chart dependencies deploy a Redis cluster and a CrunchyDB PostgreSQL cluster, and `externalComponents` wires them into the APIManager via secrets (`system-redis`, `backend-redis`, `system-database`, `zync`).

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-3scale
  namespace: openshift-gitops
spec:
  description: Deploy the 3scale API Management operator on OpenShift
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: openshift-operators
    - server: https://kubernetes.default.svc
      namespace: openshift-crunchy-pgo
    - server: https://kubernetes.default.svc
      namespace: startx-3scale
    - server: https://kubernetes.default.svc
      namespace: default-crunchy
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
---
# Wave 1 — namespaces: startx-3scale (3scale), default-crunchy (postgres)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-3scale-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-3scale
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-3scale
    targetRevision: 21.3.68
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: true
        operator:
          enabled: false
        manager:
          enabled: false
        externalComponents:
          enabled: false
        clusterRedis:
          enabled: false
        clusterCrunchy:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: startx-3scale
  ignoreDifferences:
    - group: ""
      kind: ServiceAccount
      name: default
      namespace: startx-3scale
      jsonPointers:
        - /imagePullSecrets
        - /secrets
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Wave 5 — operators: 3scale (openshift-operators) + redis + crunchy
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-3scale-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-3scale
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-3scale
    targetRevision: 21.3.68
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: false
        operator:
          enabled: true
        manager:
          enabled: false
        externalComponents:
          enabled: false
          redis:
            enabled: false
          database:
            enabled: false
        clusterRedis:
          enabled: true
          project:
            enabled: false
          operator:
            enabled: true
          cluster:
            enabled: false
        clusterCrunchy:
          enabled: true
          project:
            enabled: false
          operator:
            enabled: true
          cluster:
            enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-operators
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Wave 10 — apps: Redis cluster + PostgreSQL cluster + 3scale APIManager + secrets
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-3scale-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-3scale
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-3scale
    targetRevision: 21.3.68
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: false
        operator:
          enabled: false
        manager:
          enabled: true
        externalComponents:
          enabled: true
          redis:
            enabled: true
          database:
            enabled: true
        clusterRedis:
          enabled: true
          project:
            enabled: false
          operator:
            enabled: false
          cluster:
            enabled: true
        clusterCrunchy:
          enabled: true
          project:
            enabled: false
          operator:
            enabled: false
          cluster:
            enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: startx-3scale
  ignoreDifferences:
    - group: apps.3scale.net
      kind: APIManager
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply with:

```bash
oc apply -f cluster-3scale-argocd.yaml -n openshift-gitops
```

> **Passwords**: update `externalComponents.database.password`, `externalComponents.zync.password`, and `externalComponents.zync.secretKeyBase` in your ArgoCD Application values (or use a Sealed Secret / ExternalSecret). The `initScript` in `clusterCrunchy.cluster.list[0]` must use the **same passwords**.

> **Node selector**: the 3scale operator deployment requests `node-role.kubernetes.io/infra` nodes. On clusters without dedicated infra nodes, set `operator.subscription.operator.config.infra: false` in the `-operator` Application values.

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
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
| 21.3.4 | 2026-03-03 | Upgrade to operator v0.10.5 |
| 21.3.5 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.12 | 2026-06-18 | Improve cluster-3scale options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | Add cluster-redis/cluster-crunchy sub-charts and externalComponents support for 3scale 2.16+ |
| 21.3.57 | 2026-06-20 | Auto-create openshift-crunchy-pgo namespace in project wave; fix secrets leaking into operator wave |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |

# ![cluster-couchbase](https://helm-repository.readthedocs.io/en/latest/img/cluster-couchbase.svg "Cluster Chart : Couchbase") Cluster Chart : Couchbase
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--couchbase-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+couchbase+startx)

This helm chart is used to deploy Couchbase instances managed by a dedicated operator.

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
helm show chart startx/cluster-couchbase
```

### 4. Install this chart

```bash
helm install cluster-couchbase startx/cluster-couchbase
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **openshift-startx-couchbase** without constraints
- 1 **operator:** named **couchbase-enterprise-certified** configured with
  - The **stable** channel for community release
  - The **v2.8.0** version
  - Deployed under the **openshift-startx-couchbase** project

```bash
# Create the project
helm install cluster-couchbase-project startx/cluster-couchbase --set project.enabled=true,operator.enabled=false,couchbase.enabled=false
# Deploy the couchbase operator
helm install cluster-couchbase-operator startx/cluster-couchbase --set project.enabled=false,operator.enabled=true,couchbase.enabled=false && sleep 10
# Configure default couchbase resources
helm install cluster-couchbase-instance startx/cluster-couchbase --set project.enabled=false,operator.enabled=false,couchbase.enabled=true
```

## Others values availables

- **startx** : Couchbase operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-couchbase/values-startx.yaml))

```bash
helm install cluster-couchbase startx/cluster-couchbase -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-couchbase/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-couchbase
  namespace: openshift-gitops
spec:
  description: Deploy Couchbase Autonomous operator and configure Couchbase clusters
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-startx-couchbase
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
# Creates namespace openshift-startx-couchbase
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-couchbase-project
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-couchbase
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-couchbase
    targetRevision: 21.3.12
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: true
        couchbaseConfig:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Deploys Couchbase Autonomous operator in openshift-startx-couchbase (dedicated namespace, own OperatorGroup)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-couchbase-operator
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-couchbase
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-couchbase
    targetRevision: 21.3.12
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        operator:
          enabled: true
        couchbaseConfig:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-startx-couchbase
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Configures Couchbase environment (ServiceAccounts, RBAC) in openshift-startx-couchbase
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-couchbase-app
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-couchbase
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-couchbase
    targetRevision: 21.3.12
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        cluster:
          enabled: true
        clusterRbac:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-startx-couchbase
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

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
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.12 | 2026-06-18 | Update couchbase-enterprise-certified operator to 2.9.2, add ArgoCD deployment examples |

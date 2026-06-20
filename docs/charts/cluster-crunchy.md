# ![cluster-crunchy](https://helm-repository.readthedocs.io/en/latest/img/cluster-crunchy.svg "Cluster Chart : Crunchy") Cluster Chart : Crunchy
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--crunchy-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+crunchy+startx)

This helm chart is used to deploy CrunchyDB instances managed by a dedicated operator.

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
helm show chart startx/cluster-crunchy
```

### 4. Install this chart

```bash
helm install cluster-crunchy startx/cluster-crunchy
```

## Deploy this helm chart with ArgoCD

### 1. Create the project

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-project
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "default-crunchy"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: 21.3.67
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: project.enabled
      value: "true"
EOF
```

## 2. Deploy the operator

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-operator
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "default-crunchy"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: 21.3.67
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: operator.enabled
      value: "true"
EOF
```

## 2. Deploy a crunchy instance

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-instance
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "default-crunchy"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: 21.3.67
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: cluster.enabled
      value: "true"
    - name: loader.enabled
      value: "true"
EOF
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **default-crunchy** without constraints
- 1 **operator:** named **crunchy-postgres-operator** configured with
  - The **v5** channel for community release
  - The **v5.8.6** version
  - Deployed under the **default-crunchy** project

```bash
# Create the project
helm install cluster-crunchy-project startx/cluster-crunchy --set project.enabled=true,operator.enabled=false,crunchy.enabled=false
# Deploy the crunchy operator
helm install cluster-crunchy-operator startx/cluster-crunchy --set project.enabled=false,operator.enabled=true,crunchy.enabled=false && sleep 10
# Configure default crunchy resources
helm install cluster-crunchy-instance startx/cluster-crunchy --set project.enabled=false,operator.enabled=false,crunchy.enabled=true
```

## Others values availables

- **startx** : CrunchyDB operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx.yaml))

```bash
helm install cluster-crunchy startx/cluster-crunchy -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-crunchy
  namespace: openshift-gitops
spec:
  description: Deploy Crunchy Postgres operator and configure PostgreSQL clusters
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: default-crunchy
      server: https://kubernetes.default.svc
    - namespace: default-crunchy
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
# Creates namespace default-crunchy
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-crunchy-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-crunchy
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-crunchy
    targetRevision: 21.3.67
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Deploys Crunchy Postgres operator in default-crunchy (dedicated namespace, own OperatorGroup)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-crunchy-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-crunchy
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-crunchy
    targetRevision: 21.3.67
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        operator:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: default-crunchy
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Deploys PostgresCluster instances in default-crunchy
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-crunchy-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-crunchy
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-crunchy
    targetRevision: 21.3.67
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        cluster:
          enabled: true
        loader:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: default-crunchy
  ignoreDifferences:
    - group: postgres-operator.crunchydata.com
      kind: PostgresCluster
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                            |
| -------- | ---------- | ------------------------------------------------------ |
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
| 21.3.12 | 2026-06-18 | Update crunchy-postgres-operator to 5.8.7, add ArgoCD deployment examples |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |

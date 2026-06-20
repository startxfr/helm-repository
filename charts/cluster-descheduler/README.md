# ![cluster-descheduler](https://helm-repository.readthedocs.io/en/latest/img/cluster-descheduler.svg "Cluster Chart : Descheduler") Cluster Chart : Descheduler
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--descheduler-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+descheduler+startx)

This helm chart is used to deploy the KubeDescheduler operator to help you evict pods based on specific strategies so that the pods can be rescheduled onto more appropriate nodes.

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
helm show chart startx/cluster-descheduler
```

### 4. Install this chart

```bash
helm install cluster-descheduler startx/cluster-descheduler
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **openshift-kube-descheduler-operator** without constraints
- 1 **operator:** named **cluster-kube-descheduler-operator** configured with
  - The **stable** channel for community release
  - The **v5.2.1** version
  - Deployed under the **openshift-kube-descheduler-operator** project

```bash
# Create the project
helm install cluster-descheduler-project startx/cluster-descheduler --set project.enabled=true,operator.enabled=false,descheduler.enabled=false
# Deploy the descheduler operator
helm install cluster-descheduler-operator startx/cluster-descheduler --set project.enabled=false,operator.enabled=true,descheduler.enabled=false && sleep 10
# Configure default descheduler resources
helm install cluster-descheduler-instance startx/cluster-descheduler --set project.enabled=false,operator.enabled=false,descheduler.enabled=true
```

## Others values availables

- **startx** : descheduler operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-descheduler/values-startx.yaml))

```bash
helm install cluster-descheduler startx/cluster-descheduler -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-descheduler/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-descheduler
  namespace: openshift-gitops
spec:
  description: Deploy Kube Descheduler operator and configure descheduler policies
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-kube-descheduler-operator
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
# Creates namespace openshift-kube-descheduler-operator
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-descheduler-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-descheduler
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-descheduler
    targetRevision: 21.3.68
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
# Deploys Kube Descheduler operator in openshift-kube-descheduler-operator (dedicated namespace, own OperatorGroup)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-descheduler-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-descheduler
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-descheduler
    targetRevision: 21.3.68
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        operator:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-kube-descheduler-operator
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Deploys KubeDescheduler instance in openshift-kube-descheduler-operator
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-descheduler-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-descheduler
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-descheduler
    targetRevision: 21.3.68
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        descheduler:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-kube-descheduler-operator
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                                       |
| -------- | ---------- | ----------------------------------------------------------------- |
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
| 21.3.12 | 2026-06-18 | Improve cluster-descheduler options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |

# ![cluster-argocd](https://helm-repository.readthedocs.io/en/latest/img/cluster-argocd.svg "Cluster Chart : ArgoCD") Cluster Chart : ArgoCD
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--argocd-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+argocd+startx)

This helm chart is used to configure code ready argocd via it's operator and deploy a VM into Openshift.

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
helm show chart startx/cluster-argocd
```

### 4. Install this chart

```bash
helm install cluster-argocd startx/cluster-argocd
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **openshift-gitops** with the following properties
  - 1 **LimitRange:** defined for this projet
  - 1 **Quotas:** defined for this projet
  - 3 **RBAC:** allowing **mygroup_example** to **edit** resources
- 1 **operator:** named **openshift-gitops-operator** configured with
  - The **gitops-1.19** channel
  - The **1.19.1** version
  - Deployed under the **openshift-operators** project
- 1 **argocd:** named **openshift-gitops**
- 1 **argocd_export:** every days
- 1 **argocd_project:** with **default** namespace declared
- 1 **argocd_application:** named **example-application** used to deploy an html example in **default** namespace

```bash
# base configuration running default configuration
helm install cluster-argocd startx/cluster-argocd
```

## Others values availables

- **startx** : Startx argocd cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-argocd/values-startx.yaml))

```bash
helm install cluster-argocd startx/cluster-argocd -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-argocd/values-startx.yaml
```

- **startx-gitops** : Startx gitops cluster wide service configuration using startx group (dev, devops and ops) (see [values-gitops.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-argocd/values-startx-gitops.yaml))

```bash
helm install cluster-argocd startx/cluster-argocd -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-argocd/values-startx-gitops.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-argocd` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject.
The GitOps operator installs in the shared `openshift-operators` namespace. The `ArgoCD` CR deploys in `openshift-gitops`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-argocd
  namespace: openshift-gitops
spec:
  description: Deploy OpenShift GitOps (ArgoCD) operator on OpenShift
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: openshift-operators
    - server: https://kubernetes.default.svc
      namespace: openshift-gitops
    - server: https://kubernetes.default.svc
      namespace: '*'
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: operators.coreos.com
      kind: OperatorGroup
    - group: operators.coreos.com
      kind: Subscription
    - group: argoproj.io
      kind: ArgoCD
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-argocd-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  destination:
    namespace: openshift-gitops
    server: https://kubernetes.default.svc
  project: cluster-argocd
  source:
    chart: cluster-argocd
    helm:
      values: |
        argocd:
          enabled: false
        project:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.56
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
  name: cluster-argocd-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: openshift-operators
    server: https://kubernetes.default.svc
  project: cluster-argocd
  source:
    chart: cluster-argocd
    helm:
      values: |
        argocd:
          enabled: false
        operator:
          enabled: true
          operatorGroup:
            enabled: false
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.56
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-argocd-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: openshift-gitops
    server: https://kubernetes.default.svc
  project: cluster-argocd
  source:
    chart: cluster-argocd
    helm:
      values: |
        argocd:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.56
  ignoreDifferences:
    - group: argoproj.io
      kind: ArgoCD
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply with:

```bash
kubectl apply -f cluster-argocd-argocd.yaml -n openshift-gitops
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## History

| Release  | Date       | Description                                                                                                |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------- |
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
| 21.3.12 | 2026-06-18 | Improve cluster-argocd options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |

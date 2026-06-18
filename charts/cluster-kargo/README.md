# ![cluster-kargo](https://helm-repository.readthedocs.io/en/latest/img/cluster-kargo.svg "Cluster Chart : Kargo") Cluster Chart : Kargo
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--kargo-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+kargo+startx)

This helm chart is used to deploy Kargo tool used to manage and automate the promotion of stage lifecycle using GitOps principles.

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
helm show chart startx/cluster-kargo
```

### 4. Install this chart

```bash
helm install cluster-kargo startx/cluster-kargo
```

## Default values

Complete deployment of a project with the following characteristics :

!!! todo
    Complete this section

```bash
# base configuration running default configuration
helm install cluster-kargo startx/cluster-kargo
```

## Others values availables

- **startx** : Kargo chart (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kargo/values-startx.yaml))

```bash
helm install cluster-kargo startx/cluster-kargo -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kargo/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-kargo
  namespace: openshift-gitops
spec:
  description: Deploy Kargo GitOps promotion platform
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: kargo-system
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
# Creates namespace kargo-system
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-kargo-project
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-kargo
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-kargo
    targetRevision: 21.3.13
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: true
        kargo:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Deploys Kargo promotion platform in kargo-system
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-kargo-app
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-kargo
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-kargo
    targetRevision: 21.3.13
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        project:
          enabled: false
        kargo:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: kargo-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 21.3.5  | 2026-04-10 | Create chart cluster-kargo from cluster-ptp                                                     |
| 21.3.6 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.12 | 2026-06-18 | Upgrade Kargo to v1.10.7 and add ArgoCD examples |
| 21.3.13 | 2026-06-18 | Improve cluster-kargo options |

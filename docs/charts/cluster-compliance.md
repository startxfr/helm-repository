# ![cluster-compliance](https://helm-repository.readthedocs.io/en/latest/img/cluster-compliance.svg "Cluster Chart : Compliance") Cluster Chart : Compliance
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--compliance-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+compliance+startx)

This helm chart is used to deploy Compliance instances managed by a dedicated operator.

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
helm show chart startx/cluster-compliance
```

### 4. Install this chart

```bash
helm install cluster-compliance startx/cluster-compliance
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **openshift-compliance** without constraints
- 1 **operator:** named **compliance-operator** configured with
  - The **stable** channel for community release
  - The **v1.8.2** version
  - Deployed under the **openshift-operators** project

```bash
# Create the project
helm install cluster-compliance-project startx/cluster-compliance --set project.enabled=true,operator.enabled=false,compliance.enabled=false
# Deploy the compliance operator
helm install cluster-compliance-operator startx/cluster-compliance --set project.enabled=false,operator.enabled=true,compliance.enabled=false && sleep 10
# Configure default compliance resources
helm install cluster-compliance-instance startx/cluster-compliance --set project.enabled=false,operator.enabled=false,compliance.enabled=true
```

## Others values availables

- **startx** : Compliance operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-compliance/values-startx.yaml))

```bash
helm install cluster-compliance startx/cluster-compliance -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-compliance/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-compliance
  namespace: openshift-gitops
spec:
  description: Deploy and configure Compliance operator on the cluster
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-compliance
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
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-compliance-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-compliance
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-compliance
    targetRevision: 21.3.68
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        compliance:
          enabled: false
        project:
          enabled: true
          project:
            name: "openshift-compliance"
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-compliance-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-compliance
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-compliance
    targetRevision: 21.3.68
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        compliance:
          enabled: false
        operator:
          enabled: true
          subscription:
            enabled: true
          operatorGroup:
            enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-compliance-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-compliance
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-compliance
    targetRevision: 21.3.68
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        compliance:
          enabled: true
        project:
          project:
            name: "openshift-compliance"
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-compliance
  ignoreDifferences:
    - group: compliance.openshift.io
      kind: ScanSetting
      jsonPointers:
        - /metadata/finalizers
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
| 21.3.12 | 2026-06-18 | Update compliance operator to v1.9.1, add ArgoCD deployment examples |
| 21.3.13 | 2026-06-18 | Fix ScanSetting template (was incorrectly using PtpConfig kind) |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |

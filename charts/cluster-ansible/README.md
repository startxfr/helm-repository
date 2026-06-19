# ![cluster-ansible](https://helm-repository.readthedocs.io/en/latest/img/cluster-ansible.svg "Cluster Chart : Ansible") Cluster Chart : Ansible
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--ansible-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+ansible+startx)

This helm chart is used to create an operator based deployment of Ansible Automation.

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
helm show chart startx/cluster-ansible
```

### 4. Install this chart

```bash
helm install cluster-ansible startx/cluster-ansible
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **rhaap-operator** with the following properties
- 1 **operator:** named **rhaap-operator** configured with
  - The **stable-2.5-cluster-scoped** channel
  - The **2.5.0** version
  - Deployed under the **rhaap-operator** project
- 1 **ansible** deployed
- 1 **ansibleHub:** enabled

```bash
# base configuration running default configuration
helm install cluster-ansible startx/cluster-ansible
```

## Others values availables

- **startx** : Startx ansible cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ansible/values-startx.yaml))

```bash
helm install cluster-ansible startx/cluster-ansible -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ansible/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-ansible` using three dedicated ArgoCD Applications — one per concern — all sharing the same AppProject.
The AAP operator installs in the dedicated `aap` namespace (with its own OperatorGroup). The `AnsibleAutomationPlatform` CR deploys in `startx-ansible`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-ansible
  namespace: openshift-gitops
spec:
  description: Deploy Ansible Automation Platform (AAP) on OpenShift
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: aap
    - server: https://kubernetes.default.svc
      namespace: startx-ansible
    - server: https://kubernetes.default.svc
      namespace: '*'
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: operators.coreos.com
      kind: OperatorGroup
    - group: operators.coreos.com
      kind: Subscription
    - group: aap.ansible.com
      kind: AnsibleAutomationPlatform
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-ansible-project
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: startx-ansible
    server: https://kubernetes.default.svc
  project: cluster-ansible
  source:
    chart: cluster-ansible
    helm:
      values: |
        project:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.13
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
  name: cluster-ansible-operator
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: aap
    server: https://kubernetes.default.svc
  project: cluster-ansible
  source:
    chart: cluster-ansible
    helm:
      values: |
        projectOperator:
          enabled: true
          project:
            name: "aap"
        operator:
          enabled: true
          operatorGroup:
            enabled: true
            name: "aap"
            namespace: "aap"
          subscription:
            enabled: true
            namespace: "aap"
            operator:
              channel: stable-2.7
              installPlanApproval: Manual
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.13
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
  name: cluster-ansible-app
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: startx-ansible
    server: https://kubernetes.default.svc
  project: cluster-ansible
  source:
    chart: cluster-ansible
    helm:
      values: |
        ansibleAAP:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.13
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Apply with:

```bash
kubectl apply -f cluster-ansible-argocd.yaml -n openshift-gitops
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## History

| Release  | Date       | Description                                                                                 |
| -------- | ---------- | ------------------------------------------------------------------------------------------- |
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
| 21.3.12 | 2026-06-18 | Improve cluster-ansible options |
| 21.3.13 | 2026-06-18 | Improve cluster-ansible options |

# ![cluster-logging](https://helm-repository.readthedocs.io/en/latest/img/cluster-logging.svg "Cluster Chart : Logging") Cluster Chart : Logging
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--logging-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+logging+startx)

This helm chart is used to configure Metering at the cluster level.

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
helm show chart startx/cluster-logging
```

### 4. Install this chart

```bash
helm install cluster-logging startx/cluster-logging
```

## Default values

Complete deployment of a project with the following characteristics :

Complete deployment of a Logging configuration with the following characteristics :

- 1 **operator** named **cluster-logging** deployed under **openshift-logging**
- 1 **ClusterLogging** instance with configurable log store (Loki or Elastic)
- Optional **ClusterLogForwarder** for external log routing
- Optional **EventRouter** for Kubernetes event collection

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-logging
  namespace: openshift-gitops
spec:
  description: Deploy OpenShift Logging operator (cluster-logging + loki) and configure log forwarding
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-logging
      server: https://kubernetes.default.svc
    - namespace: openshift-operators-redhat
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
# Creates namespace openshift-logging
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-logging-project
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-logging
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-logging
    targetRevision: 21.3.12
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
# Deploys cluster-logging operator in openshift-logging (dedicated namespace, own OperatorGroup)
# and loki-operator in openshift-operators-redhat (shared namespace, no OperatorGroup)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-logging-operator
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-logging
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-logging
    targetRevision: 21.3.12
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        operator:
          enabled: true
          operatorGroup:
            enabled: true
        operatorLoki:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-logging
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Configures ClusterLogging and ClusterLogForwarder (disabled by default)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-logging-app
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-logging
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-logging
    targetRevision: 21.3.12
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        logging:
          enabled: false
        logforwarder:
          enabled: false
        eventrouter:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-logging
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                                                                                      |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.21 | 2025-03-17 | LogStore is now optional |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.75 | 2026-01-22 | Adding creation of the logging-admin service account |
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
| 21.3.12 | 2026-06-18 | Upgrade cluster-logging to 6.5.1 and add ArgoCD examples |
| 21.3.12 | 2026-06-18 | Improve cluster-logging options |

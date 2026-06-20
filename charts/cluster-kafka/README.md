# ![cluster-kafka](https://helm-repository.readthedocs.io/en/latest/img/cluster-kafka.svg "Cluster Chart : Kafka") Cluster Chart : Kafka
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--kafka-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+kafka+startx)

This helm chart is used to deploy Kafka handled by an operator to configure cluster and topic management at the cluster level.

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
helm show chart startx/cluster-kafka
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **operator:** named **amq-streams-console** configured with
  - The **stable** channel for community release
  - The **v3.2.0** version
  - Deployed under the **openshift-operators** project

```bash
# Create the project
helm install cluster-kafka-project startx/cluster-kafka --set project.enabled=true,operator.enabled=false,kafka.enabled=false
# Deploy the kafka operator
helm install cluster-kafka-operator startx/cluster-kafka --set project.enabled=false,operator.enabled=true,kafka.enabled=false && sleep 10
# Configure default kafka resources
helm install cluster-kafka-instance startx/cluster-kafka --set project.enabled=false,operator.enabled=false,kafka.enabled=true
```

#### Other available values

- **startx** : Kafka operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kafka/values-startx.yaml))

```bash
helm install cluster-kafka startx/cluster-kafka -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kafka/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-kafka
  namespace: openshift-gitops
spec:
  description: Deploy AMQ Streams (Kafka) operator and configure Kafka clusters
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: startx-kafka
      server: https://kubernetes.default.svc
    - namespace: openshift-operators
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
# Creates namespace startx-kafka
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-kafka-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-kafka
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-kafka
    targetRevision: 21.3.102
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
# Deploys AMQ Streams and console operators in openshift-operators (shared namespace, global-operators OG exists)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-kafka-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-kafka
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-kafka
    targetRevision: 21.3.102
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        operator:
          enabled: true
        operatorConsole:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-operators
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Configures Kafka clusters and topics (disabled by default)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-kafka-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-kafka
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-kafka
    targetRevision: 21.3.102
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        clusters:
          enabled: false
        topics:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: startx-kafka
  ignoreDifferences:
    - group: kafka.strimzi.io
      kind: Kafka
      jsonPointers:
        - /metadata/finalizers
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release | Date       | Description                                       |
| ------- | ---------- | ------------------------------------------------- |
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
| 21.3.12 | 2026-06-18 | Improve cluster-kafka options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |

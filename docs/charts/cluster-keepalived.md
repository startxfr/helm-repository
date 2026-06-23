# ![cluster-keepalived](https://helm-repository.readthedocs.io/en/latest/img/cluster-keepalived.svg "Cluster Chart : Keepalived") Cluster Chart : Keepalived
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--keepalived-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+keepalived+startx)

This helm chart is used to configure Keepalived at the cluster level.

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
helm show chart startx/cluster-keepalived
```

### 4. Install this chart

```bash
helm install cluster-keepalived startx/cluster-keepalived
```

## Default values

Complete deployment of a Keepalived configuration with the following characteristics :

- 1 **operator** named **keepalived-operator** deployed under **keepalived-operator** namespace
- 1 **KeepalivedGroup** instance managing VRRP on worker/infra nodes
- 1 **clusterNetwork** patch enabling external IP assignment

```bash
# base configuration running default configuration
helm install cluster-keepalived startx/cluster-keepalived
```

## Others values availables

- **startx** : Startx keepalived cluster wide service configuration using keepalived operator (see [values-example.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-keepalived/values-example.yaml))

```bash
helm install cluster-keepalived startx/cluster-keepalived -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-keepalived/values-example.yaml
```

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-keepalived
  namespace: openshift-gitops
spec:
  description: Deploy Keepalived operator and configure VIP/network for external IP support
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: keepalived-operator
      server: https://kubernetes.default.svc
    - namespace: openshift-ingress
      server: https://kubernetes.default.svc
    - namespace: openshift-ingress-operator
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
# Creates the keepalived-operator namespace
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-keepalived-project
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  project: cluster-keepalived
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-keepalived
    targetRevision: 21.3.4
    helm:
      values: |
        project:
          enabled: true
          project:
            enabled: true
        operator:
          enabled: false
        clusterNetwork:
          enabled: false
        keepalived:
          enabled: false
        ingressController:
          enabled: false
        ingressControllerService:
          enabled: false
        ingressControllerSecret:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Installs keepalived-operator via OLM
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-keepalived-operator
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "5"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-keepalived
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-keepalived
    targetRevision: 21.3.4
    helm:
      values: |
        project:
          enabled: false
        operator:
          enabled: true
          subscription:
            enabled: true
          operatorGroup:
            enabled: true
        clusterNetwork:
          enabled: false
        keepalived:
          enabled: false
        ingressController:
          enabled: false
        ingressControllerService:
          enabled: false
        ingressControllerSecret:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: keepalived-operator
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Configures cluster network, KeepalivedGroups and optional IngressController
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-keepalived-app
  namespace: openshift-gitops
  annotations:
    argocd.argoproj.io/sync-wave: "10"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-keepalived
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-keepalived
    targetRevision: 21.3.4
    helm:
      values: |
        project:
          enabled: false
        operator:
          enabled: false
        clusterNetwork:
          enabled: true
          externalIP:
            autoAssignCIDRs:
              - 10.99.10.237/32
            policy:
              allowedCIDRs:
                - 10.99.10.237/32
        keepalived:
          enabled: true
          groups:
            enabled: true
            list:
              - name: keepalivedgroup-workers
                namespace: openshift-ingress
                spec: |
                  blacklistRouterIDs:
                    - 165
                    - 168
                    - 169
                  image: registry.redhat.io/openshift4/ose-keepalived-ipfailover
                  interface: br-ex
                  nodeSelector:
                    node-role.kubernetes.io/infra: ''
        ingressController:
          enabled: true
          name: public
          domain: apps.public.example.com
          replicas: 3
          routeSelector:
            matchLabels:
              ingress: public
        ingressControllerService:
          enabled: true
          name: router-public-lb
          externalIPs:
            - 10.99.10.237
        ingressControllerSecret:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-ingress
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 21.3.3   | 2026-06-23 | Initial release of cluster-keepalived chart |
| 21.3.4 | 2026-06-23 | Improve cluster-keepalived options |

# ![cluster-auth](https://helm-repository.readthedocs.io/en/latest/img/cluster-auth.svg "Cluster Chart : Auth") Cluster Chart : Auth
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--auth-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+auth+startx)

This helm chart is used to configure Auth at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like auth.

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
helm show chart startx/cluster-auth
```

### 4. Install this chart

```bash
helm install cluster-auth startx/cluster-auth
```

## Default values

Complete configuration of the OCP authentification with the following characteristics :

- 3 auth templates in **openshift-config**
  - 1 template login set to **default-login**
  - 1 template errors set to **default-errors**
  - 1 template providers set to **default-providers**
- 1 auth backend set to **htpasswd** named **default-htpasswd** with
  - 1 user **dev**

```bash
# base configuration running default configuration
helm install cluster-auth startx/cluster-auth
```

## Others values availables

- **startx** : Startx auth cluster wide service configuration using startx group (dev, devops and ops) (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-auth/values-startx.yaml))
  - 3 auth templates in **openshift-config**
    - 1 template login set to **startx-login**
    - 1 template errors set to **startx-errors**
    - 1 template providers set to **startx-providers**
  - 1 auth backend set to **htpasswd** named **default-htpasswd** with
    - 1 user **dev**
    - 1 user **devops**
    - 1 user **ops**
    - 1 user **admin**

```bash
helm install cluster-auth startx/cluster-auth -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-auth/values-startx.yaml
```

- **startx-mg** : Startx gitops cluster wide service configuration using startx group (dev, devops and ops) (see [values-mg.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-auth/values-mg.yaml))

```bash
helm install cluster-auth startx/cluster-auth -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-auth/values-mg.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

`cluster-auth` is a configuration-only chart (no operator, no dedicated namespace). It configures the cluster `OAuth` CR and related secrets in `openshift-config`. A single Application is sufficient:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-auth
  namespace: openshift-gitops
spec:
  description: Configure OpenShift OAuth and authentication on the cluster
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: openshift-config
    - server: https://kubernetes.default.svc
      namespace: '*'
  clusterResourceWhitelist:
    - group: config.openshift.io
      kind: OAuth
    - group: ''
      kind: Secret
    - group: ''
      kind: ConfigMap
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-auth-app
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: openshift-config
    server: https://kubernetes.default.svc
  project: cluster-auth
  source:
    chart: cluster-auth
    helm:
      values: |
        auth:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.56
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply with:

```bash
kubectl apply -f cluster-auth-argocd.yaml -n openshift-gitops
```

The automated sync policy ensures ArgoCD reconciles the OAuth configuration whenever the chart or values drift from the desired state.

## History

| Release  | Date       | Description                                                                                                                                             |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.72 | 2025-11-27 | improve with devoteam logo |
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
| 21.3.12 | 2026-06-18 | Improve cluster-auth options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |

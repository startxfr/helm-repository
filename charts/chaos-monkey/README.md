# ![chaos-monkey](https://helm-repository.readthedocs.io/en/latest/img/chaos-monkey.svg "Chaos Chart : Monkeys") Chaos Chart : ChaosMonkeys
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--monkey-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+monkey+startx)

This helm chart used to deploy kube-monkey on Openshift or Kubernetes cluster.
Kube-monkey is a chaos injection tool that randomly terminates pods during business hours to test application resilience.

This chart is part of the [chaos startx helm chart series](https://helm-repository.readthedocs.io#chaos-helm-charts) focused on deploying various kind of chaos tools for cluster infrastructure or applications chaos-testing. [chaos-xxx charts](https://helm-repository.readthedocs.io#chaos-helm-charts).

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

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
helm show chart startx/chaos-monkey
```

### 4. Install this component

```bash
# Install the monkey project
helm install --set project.enabled=true chaos-monkey-project  startx/chaos-monkey
# Deploy the monkey instance
helm install --set monkey.enabled=true  chaos-monkey-instance startx/chaos-monkey
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | kube-monkey     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### chaos-monkey values dictionary

| Key            | Default | Description                                                                                                                                                                                                                                                                       |
| -------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project        | {...}   | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/project/#project-values-dictionary) for more options) |
| project.enable | false   | Enable creation of the namespace                                                                                                                                                                                                                                                  |
| monkey         | {...}   | Configuration of the kube-monkey deployment. Inherit from the [asobti kube-monkey chart](https://asobti.github.io/kube-monkey/charts/repo) (see [chart options](https://asobti.github.io/kube-monkey/charts/repo) for more options)                                               |
| monkey.enable  | false   | Enable deploying the kube-monkey chaos injector                                                                                                                                                                                                                                         |

## Values files

### Default values file (values.yaml)

Simple monkey with default configuration :

- 1 **project** named **chaos-monkey**
- 1 **scc** with privileged context for **monkey** deployment
- 1 **kube-monkey** deployment using asobti helm chart

```bash
# Install the kube-monkey project
helm install --set project.enable=true chaos-monkey-project startx/chaos-monkey
# Deploy the kube-monkey instance
helm install --set monkey.enable=true -n chaos-monkey chaos-monkey-instance startx/chaos-monkey
```

### STARTX values file (values-startx-xxx.yaml)

Same as the default configuration but with namespace prefixed with startx-

```bash
# Configuration running demo example configuration
helm install chaos-monkey-project startx/chaos-monkey -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-monkey/values-startx-project.yaml
helm install chaos-monkey-deploy startx/chaos-monkey -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-monkey/values-startx-deploy.yaml
```

## Usage examples

### Deploy kube-monkey with basic kill schedule

Enable kube-monkey to run daily at 8am and terminate pods in opted-in namespaces:

```yaml
# my-monkey-values.yaml
context:
  scope: myorg
  cluster: prod-cluster
  environment: chaos
  component: monkey
  app: kube-monkey

monkey:
  enabled: true
  config:
    dryRun: false
    timezone: America/New_York
    startHour: 8
    endHour: 17
    gracePeriodSec: 5
    killAllOnFail: false
    debug:
      enabled: false
```

```bash
helm install chaos-monkey-instance startx/chaos-monkey -f my-monkey-values.yaml -n chaos-monkey
```

### Dry-run mode (simulate without killing)

Test the configuration without actually terminating pods:

```yaml
# my-monkey-dryrun-values.yaml
monkey:
  enabled: true
  config:
    dryRun: true
    timezone: Europe/Paris
    startHour: 9
    endHour: 18
```

```bash
helm install chaos-monkey-dryrun startx/chaos-monkey -f my-monkey-dryrun-values.yaml -n chaos-monkey
```

### Opt in a deployment for kube-monkey

Add annotations to your application's Deployment to opt in and set the kill probability:

```yaml
# In your application Deployment manifest
metadata:
  labels:
    kube-monkey/enabled: "enabled"
  annotations:
    kube-monkey/enabled: "enabled"
    kube-monkey/identifier: "myapp"
    kube-monkey/mtbf: "3"           # mean time between failures (days)
    kube-monkey/kill-mode: "fixed"  # or "random-max-percent"
    kube-monkey/kill-value: "1"     # number of pods to kill
```

## ArgoCD deployment

### Deploy via ArgoCD Application

`chaos-monkey` deploys kube-monkey which runs on a schedule (configurable `startHour`/`endHour`). Target deployments must opt in via annotations.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: chaos-monkey
  namespace: openshift-gitops
spec:
  description: Deploy kube-monkey chaos pod killer on OpenShift
  sourceRepos:
    - 'http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/*'
    - 'https://asobti.github.io/kube-monkey/charts/repo'
  destinations:
    - server: https://kubernetes.default.svc
      namespace: chaos-monkey
    - server: https://kubernetes.default.svc
      namespace: default
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: project.openshift.io
      kind: ProjectRequest
    - group: security.openshift.io
      kind: SecurityContextConstraints
    - group: rbac.authorization.k8s.io
      kind: ClusterRole
    - group: rbac.authorization.k8s.io
      kind: ClusterRoleBinding
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: chaos-monkey-project
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: chaos-monkey
  source:
    chart: chaos-monkey
    helm:
      values: |
        project:
          enabled: true
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.103
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: chaos-monkey-instance
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: chaos-monkey
    server: https://kubernetes.default.svc
  project: chaos-monkey
  source:
    chart: chaos-monkey
    helm:
      values: |
        monkey:
          enabled: true
          config:
            dryRun: true
            timezone: Europe/Paris
            startHour: 9
            endHour: 17
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    targetRevision: 21.3.103
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Apply with:

```bash
kubectl apply -f chaos-monkey-argocd.yaml -n openshift-gitops
```

## History

| Release  | Date       | Description                                                                                                                                                 |
| -------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
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
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-20 | Improve chaos-monkey options |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |

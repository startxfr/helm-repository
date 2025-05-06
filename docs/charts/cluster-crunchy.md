# ![cluster-crunchy](https://helm-repository.readthedocs.io/en/latest/img/cluster-crunchy.svg "Cluster Chart : Crunchy") Cluster Chart : Crunchy
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--crunchy-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+crunchy+startx)

This helm chart is used to deploy CrunchyDB instances managed by a dedicated operator.

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
helm show chart startx/cluster-crunchy
```

### 4. Install this chart

```bash
helm install cluster-crunchy startx/cluster-crunchy
```

## Deploy this helm chart with ArgoCD

### 1. Create the project

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-project
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "crunchy-demo"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "stable"
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: project.enabled
      value: "true"
EOF
```

## 2. Deploy the operator

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-operator
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "openshift-operators"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "stable"
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: operator.enabled
      value: "true"
EOF
```

## 2. Deploy a crunchy instance

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-instance
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "crunchy-demo"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "stable"
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: cluster.enabled
      value: "true"
    - name: loader.enabled
      value: "true"
EOF
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **demo-crunchy** without constraints
- 1 **operator:** named **crunchy-postgres-operator** configured with
  - The **v5** channel for community release
  - The **v5.8.1** version
  - Deployed under the **demo-crunchy** project

```bash
# Create the project
helm install cluster-crunchy-project startx/cluster-crunchy --set project.enabled=true,operator.enabled=false,crunchy.enabled=false
# Deploy the crunchy operator
helm install cluster-crunchy-operator startx/cluster-crunchy --set project.enabled=false,operator.enabled=true,crunchy.enabled=false && sleep 10
# Configure default crunchy ressources
helm install cluster-crunchy-instance startx/cluster-crunchy --set project.enabled=false,operator.enabled=false,crunchy.enabled=true
```

## Others values availables

- **startx** : CrunchyDB operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx.yaml))

```bash
helm install cluster-crunchy startx/cluster-crunchy -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx.yaml
```

## History

| Release  | Date       | Description                                            |
| -------- | ---------- | ------------------------------------------------------ |
| 11.28.68 | 2023-02-26 | Create cluster-crunchy skeleton from cluster-crunchy |
| 11.28.68 | 2023-02-26 | Create cluster-crunchy skeleton from cluster-crunchy
| 11.28.69 | 2023-03-07 | publish stable update for the full repository
| 11.28.89 | 2023-04-01 | publish stable update for the full repository
| 11.28.93 | 2023-04-20 | publish stable update for the full repository
| 11.28.95 | 2023-04-21 | publish stable update for the full repository
| 11.28.99 | 2023-04-21 | publish stable update for the full repository
| 11.28.103 | 2023-05-04 | publish stable update for the full repository
| 11.28.127 | 2023-06-12 | publish stable update for the full repository
| 11.28.128 | 2023-06-12 | publish stable update for the full repository
| 11.28.129 | 2023-06-13 | publish stable update for the full repository
| 11.28.201 | 2023-07-06 | publish stable update for the full repository
| 11.28.207 | 2023-07-06 | publish stable update for the full repository
| 11.28.230 | 2023-08-18 | Align all helm chart to release 11.28.230 stable release
| 11.30.0 | 2023-08-18 | Align all helm chart to release 11.30.0 stable for OCP 4.11.30
| 11.40.0 | 2023-08-18 | Align all helm chart to release 11.40.0 stable for OCP 4.11.40
| 11.47.0 | 2023-08-18 | Align all helm chart to release 11.47.0 stable for OCP 4.11.47
| 11.47.1 | 2023-08-18 | Update appVersion in Chart.yml
| 12.0.0 | 2023-08-18 | Align all helm chart to release 12.0.0 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.1 | 2023-08-18 | Align all helm chart to release 12.0.1 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.5 | 2023-08-18 | publish stable update for the full repository
| 12.0.7 | 2023-08-18 | Upgrade to 5.4.1 crunchy operator release
| 12.0.11 | 2023-08-18 | publish stable update for the full repository
| 12.30.1 | 2023-09-29 | release 12.30.1 aligned and tested with OCP 4.12.30
| 12.36.1 | 2023-09-29 | release 12.36.0 aligned with OCP 4.12.36 (unstable)
| 12.36.9 | 2023-10-01 | publish stable update for the full repository
| 12.36.36 | 2023-10-11 | publish stable update for the full repository
| 12.36.49 | 2023-11-13 | publish stable update for the full repository
| 12.36.51 | 2023-11-13 | publish stable update for the full repository
| 12.36.58 | 2023-11-13 | Align all startx dependencies packages to version 12.36.49 stable for OCP 4.12.36
| 12.36.59 | 2023-11-13 | publish stable update for the full repository
| 12.36.63 | 2023-11-13 | publish stable update for the full repository
| 12.36.64 | 2023-11-13 | publish stable update for the full repository
| 12.36.65 | 2023-11-14 | publish stable update for the full repository
| 12.36.66 | 2023-11-14 | Update trunc to 255 for helper
| 12.36.69 | 2023-11-14 | move dependencies to version 12.36.65
| 12.45.0 | 2023-12-08 | Stable version aligned to Openshift version 4.12.45
| 13.26.0 | 2023-12-08 | Unstable version aligned to Openshift version 4.13.26 to prepare the 13.26.x stable release (short lived)
| 13.26.1 | 2023-12-09 | Minimum requirements for kubernetes is 1.26.0 version and upgrade all cluster-xxx charts to latest release for OCP 4.13
| 13.26.2 | 2023-12-09 | upgrade all dependencies charts to version 13.26.0
| 13.26.3 | 2023-12-09 | publish stable update for the full repository
| 14.6.1 | 2023-12-09 | iniFirst release for OCP 4.14 release. Aligned on 4.14.6 release
| 14.6.5 | 2023-12-10 | upgrade all dependencies charts to version 13.26.2
| 14.6.9 | 2023-12-10 | publish stable update for the full repository
| 14.6.11 | 2023-12-10 | upgrade minimum kubeVersion to 1.27.x and startx helm-chart dependencies to version 14.6.5
| 14.6.15 | 2023-12-11 | update packages for OCP 4.14.6
| 14.6.21 | 2023-12-18 | publish stable update for the full repository
| 14.6.22 | 2023-12-18 | stable si good
| 14.6.27 | 2023-12-19 | publish stable update for the full repository
| 14.6.29 | 2023-12-19 | publish stable update for the full repository
| 14.6.31 | 2023-12-19 | move to kubeversion min 1.25.0
| 14.6.33 | 2023-12-19 | Move dependencies to github-pages
| 14.6.35 | 2023-12-20 | publish stable update for the full repository
| 14.6.45 | 2023-12-22 | publish stable update for the full repository
| 14.6.46 | 2023-12-22 | publish stable update for the full repository
| 14.6.55 | 2023-12-22 | align all dependencies chart to 14.6.45
| 14.6.59 | 2023-12-22 | move back dependencies to version 14.6.35
| 14.6.63 | 2023-12-22 | Align all startx helm-chart to version 14.6.63
| 14.6.65 | 2023-12-27 | test with repo stored in s3 public bucket
| 14.6.71 | 2023-12-28 | Move to S3 helm repository
| 14.6.73 | 2023-12-29 | Upgrade all startx chart dependencies to version 14.6.65
| 14.6.75 | 2023-12-29 | Upgrade all startx chart dependencies to version 14.6.71
| 14.6.91 | 2024-01-02 | publish stable update for the full repository
| 14.6.99 | 2024-01-02 | Full stable release of the chart repository
| 14.6.103 | 2024-01-03 | Upgrade all startx chart dependencies to version 14.6.75
| 14.6.105 | 2024-01-03 | publish stable update for the full repository
| 14.6.107 | 2024-01-04 | publish stable update for the full repository
| 14.6.109 | 2024-01-04 | Update all chart dependencies to version 14.6.105
| 14.6.131 | 2024-01-18 | publish stable update for the full repository
| 14.6.133 | 2024-01-18 | Update the documentation with artifacthub badge
| 14.6.135 | 2024-01-18 | debug artifacthub recommandations
| 14.6.137 | 2024-01-18 | publish stable update for the full repository
| 14.6.141 | 2024-02-03 | upgrade of the full startx repository
| 14.6.143 | 2024-02-03 | Align to 14.6.143 chart release
| 14.6.145 | 2024-02-03 | Update all startx dependencies chart to 14.6.141 chart release
| 14.6.149 | 2024-02-03 | Update all startx dependencies chart to 14.6.141 chart release
| 14.6.150 | 2024-02-03 | Stable 14.6.150 release
| 14.6.161 | 2024-02-08 | publish stable update for the full repository
| 14.6.171 | 2024-02-08 | publish stable update for the full repository
| 14.6.189 | 2024-02-08 | publish stable update for the full repository
| 14.6.195 | 2024-02-08 | publish stable update for the full repository
| 14.6.197 | 2024-02-08 | publish stable update for the full repository
| 14.6.201 | 2024-02-08 | publish stable update for the full repository
| 14.6.208 | 2024-03-06 | Align all dependencies to 14.6.208 release
| 14.6.215 | 2024-03-08 | Align all charts to release 14.6.215
| 14.6.231 | 2024-03-19 | Align all charts to release 14.6.231
| 14.6.233 | 2024-03-27 | Adding immutable option to ConfigMap resources
| 14.6.251 | 2024-03-27 | Align all charts to release 14.6.251
| 14.6.269 | 2024-03-31 | Align all charts to release 14.6.269
| 14.6.281 | 2024-05-20 | Align all charts to release 14.6.281
| 14.6.293 | 2024-05-29 | Align all charts to release 14.6.293
| 14.6.301 | 2024-05-30 | Helm package are now signed
| 14.6.321 | 2024-06-25 | publish stable update for the full repository
| 14.6.323 | 2024-06-25 | Align all chart to latest release
| 14.6.325 | 2024-06-25 | Adding chart logo in README header
| 14.6.325 | 2024-06-25 | publish stable update for the full repository
| 14.6.331 | 2024-06-25 | update all dependencies to version 14.6.323
| 14.6.335 | 2024-06-26 | publish stable update for the full repository
| 14.6.341 | 2024-06-26 | Update startx dependencies chart to release 14.6.339
| 14.6.343 | 2024-06-26 | publish stable update for the full repository
| 14.6.345 | 2024-06-26 | publish stable update for the full repository
| 14.6.351 | 2024-06-26 | Update all dependencies
| 14.6.353 | 2024-06-26 | Fixed missed dependencies in previous release
| 14.6.367 | 2024-06-29 | Align all startx charts to release 14.6.367
| 14.6.381 | 2024-06-30 | Align all startx charts to release 14.6.381
| 15.27.3 | 2024-11-06 | create init release for version 15.x
| 15.27.5 | 2024-11-06 | publish stable update for the full repository
| 15.27.7 | 2024-11-06 | Align all startx charts dependencies to release 15.27.3
| 15.27.9 | 2024-11-09 | Upgrade the Crunchy operator version to v5.7.0
| 15.27.17 | 2024-11-10 | Release aligned for OCP 4.15.27
| 15.27.21 | 2024-11-10 | Release aligned for OCP 4.15.37
| 16.19.3 | 2024-11-10 | Init release 16.19.1 aligned for OCP 4.16.19
| 16.19.7 | 2024-11-10 | Update all dependencies to version 16.19.4
| 16.19.11 | 2024-11-10 | Update all dependencies to version 16.19.4
| 16.19.15 | 2024-11-10 | publish stable update for the full repository
| 16.19.29 | 2024-11-11 | Align all chart to the 16.19.29 release
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release
| 16.19.31 | 2024-12-10 | Align all charts to 19.19.31
| 16.19.43 | 2025-02-27 | publish stable update for the full repository
| 17.14.1 | 2025-02-28 | Initial release for v17.x version
| 17.14.3 | 2025-02-28 | Temporary release used to prepare dependencies changes
| 17.14.5 | 2025-02-28 | Align all startx helm dependencies to release 17.14.1
| 17.14.11 | 2025-03-05 | Adjust doc to material layout
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version
| 18.11.3 | 2025-04-30 | Prepare dependencies move to version 18.x
| 18.11.5 | 2025-04-30 | move dependencies to version 18.11.1
| 18.11.7 | 2025-04-30 | All dependencies linked to 18.x release
| 18.11.9 | 2025-05-01 | Upgrade crunchy operator to version 5.8.1
| 18.11.19 | 2025-05-02 | Intermediate alignement of all helm charts
| 18.11.21 | 2025-05-02 | Update all basic chart dependencies to version 18.11.15
| 18.11.22 | 2025-05-02 | Add noinfra values in all charts
| 18.11.24 | 2025-05-02 | Align all to stable version
| 18.11.31 | 2025-05-03 | update all dependencies to version 18.11.19
| 18.11.39 | 2025-05-05 | Update icon with startx new theme
| 18.11.51 | 2025-05-06 | publish stable update for the full repository

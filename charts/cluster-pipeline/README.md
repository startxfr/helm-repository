# ![cluster-pipeline](https://helm-repository.readthedocs.io/en/latest/img/cluster-pipeline.svg "Cluster Chart : Pipeline") Cluster Chart : Pipeline
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--pipeline-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+pipeline+startx)

This helm chart is used to configure tekton via it's operator.

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
helm show chart startx/cluster-pipeline
```

### 4. Install this chart

```bash
helm install cluster-pipeline startx/cluster-pipeline
```

## Default values

Deployment of tekton :

- 1 **subscription** named **openshift-pipelines-operator-rh** to deploy codeready operator with the following characteristics
  - operator name is **openshift-pipelines-operator-rh**
  - operator version is **openshift-pipelines-operator.v1.8.2**
  - operator catalog is **redhat-operators** located in **openshift-marketplace**

```bash
# base configuration running default configuration
helm install cluster-pipeline startx/cluster-pipeline
```

## Others values availables

- **startx** : Startx tekton configuration for Startx clusters (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-pipeline/values-startx.yaml)) deploying the following environment
  - 1 **subscription** named **openshift-pipelines-operator-rh** to deploy codeready operator with the following characteristics
    - operator name is **openshift-pipelines-operator-rh**
    - operator version is **openshift-pipelines-operator.v1.8.2**
    - operator catalog is **redhat-operators** located in **openshift-marketplace**

```bash
helm install cluster-pipeline startx/cluster-pipeline -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-pipeline/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-pipeline/examples/argocd/
oc apply -k .
```

### Applications



## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
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
| 21.3.12 | 2026-06-19 | Improve cluster-pipeline options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |
| 21.3.167 | 2026-06-23 | publish stable update for the full repository |
| 21.3.181 | 2026-06-23 | publish stable update for the full repository |
| 21.3.182 | 2026-06-23 | publish stable update for the full repository |
| 21.3.199 | 2026-06-24 | publish stable update for the full repository |
| 21.3.201 | 2026-06-24 | publish stable update for the full repository |
| 21.3.202 | 2026-06-24 | publish stable update for the full repository |
| 21.3.205 | 2026-06-24 | publish stable update for the full repository |
| 21.3.229 | 2026-08-08 | publish stable update for the full repository |

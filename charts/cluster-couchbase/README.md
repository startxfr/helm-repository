# ![cluster-couchbase](https://helm-repository.readthedocs.io/en/latest/img/cluster-couchbase.svg "Cluster Chart : Couchbase") Cluster Chart : Couchbase
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--couchbase-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+couchbase+startx)

This helm chart is used to deploy Couchbase instances managed by a dedicated operator.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

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
helm show chart startx/cluster-couchbase
```

### 4. Install this chart

```bash
helm install cluster-couchbase startx/cluster-couchbase
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **default-couchbase** without constraints
- 1 **operator:** named **couchbase-enterprise-certified** configured with
  - The **stable** channel for community release
  - The **v2.8.0** version
  - Deployed under the **default-couchbase** project

```bash
# Create the project
helm install cluster-couchbase-project startx/cluster-couchbase --set project.enabled=true,operator.enabled=false,couchbase.enabled=false
# Deploy the couchbase operator
helm install cluster-couchbase-operator startx/cluster-couchbase --set project.enabled=false,operator.enabled=true,couchbase.enabled=false && sleep 10
# Configure default couchbase resources
helm install cluster-couchbase-instance startx/cluster-couchbase --set project.enabled=false,operator.enabled=false,couchbase.enabled=true
```

## Other available values

- **startx** : Couchbase operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-couchbase/values-startx.yaml))

```bash
helm install cluster-couchbase startx/cluster-couchbase -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-couchbase/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-couchbase/examples/argocd/
oc apply -k .
```

### Applications



## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.12 | 2026-06-18 | Update couchbase-enterprise-certified operator to 2.9.2, add ArgoCD deployment examples |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.361 | 2026-11-10 | Release 21.3.361 for all charts |
| 21.3.362 | 2026-11-18 | publish stable update for the full repository |
| 21.3.370 | 2026-11-18 | publish stable update for the full repository |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.372 | 2026-11-19 | update basic dependencies to v21.3.371 |

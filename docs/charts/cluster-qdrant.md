# ![cluster-qdrant](https://helm-repository.readthedocs.io/en/latest/img/cluster-qdrant.svg "Cluster Chart : Qdrant") Cluster Chart : Qdrant

[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--qdrant-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+qdrant+startx)

This helm chart is used to deploy [Qdrant](https://qdrant.tech), an open-source vector database and similarity search engine, at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

> **Note**: unlike most other `cluster-*` charts in this repository, no actively maintained Qdrant Kubernetes
> operator exists. The community operators (`qdrant-operator/qdrant-operator`, `ganochenkodg/qdrant-operator`)
> are dormant or archived and were never published on OperatorHub/OLM, and Qdrant's own real operator is
> closed-source (Private/Hybrid Cloud only). This chart therefore wraps Qdrant's official `qdrant-helm`
> vendor chart directly as a StatefulSet workload instead of wrapping an Operator Subscription and a
> Custom Resource.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

- An OpenShift namespace compatible with the default `restricted`/`restricted-v2` SCC. The vendor
  `qdrant-helm` chart hardcodes `runAsUser`/`runAsGroup`/`fsGroup`, which this chart nulls out so
  OpenShift can auto-assign a UID/fsGroup from the namespace's allocated range instead.
- A default StorageClass available in the cluster (or set `qdrant.persistence.storageClassName`
  explicitly) for the 10Gi PVC backing Qdrant's collections and WAL.
- Enabling `qdrant.metrics.serviceMonitor.enabled` requires OpenShift user-workload-monitoring to
  be enabled cluster-wide beforehand ; otherwise the created `ServiceMonitor` simply won't be scraped.

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
helm show chart startx/cluster-qdrant
```

### 4. Install this chart

```bash
helm install cluster-qdrant startx/cluster-qdrant
```

## Default values

Complete deployment of Qdrant with the following characteristics:

- Single-instance Qdrant **StatefulSet** (`replicaCount: 1`, `config.cluster.enabled: false`) deployed in `default-qdrant`
- The `project` sub-chart creates the `default-qdrant` namespace
- 10Gi PVC-backed persistence for Qdrant's collections and WAL
- REST API (port 6333) exposed externally via an OpenShift **Route** (edge TLS), since the vendor chart ships no Route and its own Ingress has no OpenShift awareness
- `apiKey` disabled by default : an open REST API behind the Route is not production-safe, enable `qdrant.apiKey` before exposing this beyond a dev/test cluster

```bash
# base configuration running default configuration
helm install cluster-qdrant startx/cluster-qdrant
```

## Other available values

- **startx** : Qdrant deployed in a `default-qdrant` namespace with the STARTX "infra" scope/context (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-qdrant/values-startx.yaml))

```bash
helm install cluster-qdrant startx/cluster-qdrant -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-qdrant/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-qdrant` using two dedicated ArgoCD Applications - one per concern - sharing the same AppProject.
Since Qdrant has no operator, there is no `-operator` Application (unlike most other `cluster-*` charts in this repository):
the `-project` Application (wave `"1"`, no finalizer) creates the `default-qdrant` namespace, and the `-app`
Application (wave `"10"`, with the `resources-finalizer.argocd.argoproj.io` finalizer) deploys the Qdrant
StatefulSet/Service/Route into that same namespace. Both Applications explicitly set the other's feature
flag to `false` (`qdrant.enabled: false` on `-project`, `project.enabled: false` on `-app`) to avoid a
`SharedResourceWarning`.

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-qdrant/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## History

| Release | Date       | Description                                                                          |
| ------- | ---------- | ------------------------------------------------------------------------------------- |
| 21.3.1  | 2026-10-15 | Create chart cluster-qdrant wrapping qdrant-helm (no operator available for Qdrant) |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |

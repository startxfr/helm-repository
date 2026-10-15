# ![cluster-unifai](https://helm-repository.readthedocs.io/en/latest/img/cluster-unifai.svg "Cluster Chart : UnifAI") Cluster Chart : UnifAI

[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--unifai-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+unifai+startx)

This helm chart is used to deploy [UnifAI](https://github.com/redhat-community-ai-tools/UnifAI), a Red Hat community platform for constructing and executing multi-agent AI workflows across enterprise knowledge sources, at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

> **Note**: unlike most other `cluster-*` charts in this repository, UnifAI ships no OLM operator and no CRD upstream.
> This chart therefore deploys the application components (backend, multiagent, rag, ui, identity) directly as
> Deployments/Services/Routes instead of wrapping an Operator Subscription and a Custom Resource.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

UnifAI requires the following externally managed infrastructure, none of which is deployed by this chart
(bring your own, e.g. this repository's own [cluster-mongo](https://helm-repository.readthedocs.io/en/latest/charts/cluster-mongo) chart, or any existing instance) :

- **MongoDB** : metadata/persistence store used by the rag, multiagent, identity and backend components
- **Qdrant** : vector database used by the rag component for embeddings
- **RabbitMQ** : Celery task broker used by the rag component for asynchronous document ingestion
- **Redis** : session store used by the identity component (and optional streaming backend for multiagent)
- **Keycloak / Red Hat SSO** : external identity provider used by the identity component
- **Temporal** (optional) : distributed execution engine for the multiagent component, only required when `unifai.multiagent.engine: temporal`

### Container images

Upstream UnifAI has no public release (no git tag) and no public container registry : production images are built by an
internal Jenkins pipeline and pushed to the private `images.paas.redhat.com/unifai/*` registry, which this chart uses
as its default `image.repository` (matching upstream behavior). Deploying outside Red Hat's own OpenShift environment
therefore requires either:

- Access to `images.paas.redhat.com` and an `imagePullSecret` (set `unifai.<component>.pullSecret`), or
- Building the 5 images yourself from the [UnifAI repository](https://github.com/redhat-community-ai-tools/UnifAI) sources and pushing them to a registry you control, then overriding `unifai.<component>.image.{repository,tag}` :

| Component  | Dockerfile                                       | Base image (public)                                  |
| ---------- | ------------------------------------------------- | ----------------------------------------------------- |
| backend    | `backend/Dockerfile`                               | `registry.access.redhat.com/ubi9/python-311`          |
| multiagent | `multi-agent/Dockerfile`                           | `registry.access.redhat.com/ubi10/python-312-minimal` |
| rag        | `rag/Dockerfile`                                   | `registry.access.redhat.com/ubi9/python-311`          |
| ui         | `ui/deployment/Dockerfile`                         | `registry.access.redhat.com/ubi9/nodejs-22` → `ubi9/nginx-120` |
| identity   | `shared-resources/identity/Dockerfile`             | `registry.access.redhat.com/ubi9/python-311`          |

All base images are public, unauthenticated Red Hat UBI images, so the 5 components can be fully built from source
without any internal Red Hat access.

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
helm show chart startx/cluster-unifai
```

### 4. Install this chart

```bash
helm install cluster-unifai startx/cluster-unifai
```

## Default values

Complete deployment of UnifAI with the following characteristics:

- Deploy the **backend**, **multiagent**, **rag** (flask + celery worker + celery beat), **ui** and **identity** components in `default-unifai`
- The `project` sub-chart creates the `default-unifai` namespace
- All external infrastructure (MongoDB, Qdrant, RabbitMQ, Redis, Keycloak) must be configured via `unifai.externalServices.*` before this will actually work end-to-end

```bash
# base configuration running default configuration
helm install cluster-unifai startx/cluster-unifai
```

## Other available values

- **startx** : UnifAI deployed in a `startx-unifai` namespace (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-unifai/values-startx.yaml))

```bash
helm install cluster-unifai startx/cluster-unifai -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-unifai/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-unifai` using two dedicated ArgoCD Applications - one per concern - sharing the same AppProject.
Since UnifAI has no operator, there is no `-operator` Application (unlike most other `cluster-*` charts in this repository):
the `-project` Application creates the namespace, and the `-app` Application deploys all enabled components.

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-unifai/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## History

| Release | Date       | Description                              |
| ------- | ---------- | ----------------------------------------- |
| 21.3.1  | 2026-10-15 | Create chart cluster-unifai from cluster-kubecost |

# ![cluster-unifai](https://helm-repository.readthedocs.io/en/latest/img/cluster-unifai.svg "Cluster Chart : UnifAI") Cluster Chart : UnifAI

[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--unifai-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+unifai+startx)

This helm chart is used to deploy [UnifAI](https://github.com/redhat-community-ai-tools/UnifAI), a Red Hat community platform for constructing and executing multi-agent AI workflows across enterprise knowledge sources, at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

> **Note**: unlike most other `cluster-*` charts in this repository, UnifAI ships no OLM operator and no CRD upstream, so
> this chart isn't a wrapper around an Operator Subscription and a Custom Resource. Instead it is an **umbrella chart**:
> `Chart.yaml` declares the real UnifAI component charts as Helm dependencies, vendored (copied, not a git submodule)
> from the [startxfr/UnifAI](https://github.com/startxfr/UnifAI) fork (branch `devel`), which validates its own
> deployments on a real OpenShift cluster and documents that state in its own `MEMORY.md`. See
> `vendor/VENDORED_FROM.md` for the exact commit this was synced from, and `.tools/sync-unifai-vendor.sh` to refresh.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

### Components

| Alias (values.yaml key)       | Role                                                              | Enabled by default |
| ------------------------------ | ------------------------------------------------------------------ | ------------------- |
| `unifai_backend`               | Backend Flask API                                                   | yes |
| `multiagent_server`             | Multi-Agent System orchestrator (LangGraph engine)                  | yes |
| `multiagent_temporal_worker`    | Multi-Agent System worker (Temporal engine, alternative to LangGraph) | no |
| `multiagent_shared_storage`     | Shared PVC (`/app/shared`) for the multiagent components             | yes |
| `unifai_rag_server`             | RAG ingestion/query Flask server                                     | yes |
| `unifai_rag_celery`             | RAG Celery worker (document ingestion)                               | yes |
| `unifai_rag_celery_beat`        | RAG Celery beat scheduler (same chart as `unifai_rag_celery`, 2nd alias) | yes |
| `unifai_rag_shared_storage`     | Shared PVC (`/app/shared`) for the RAG components                    | yes |
| `ui`                            | React/Vite frontend served via Nginx                                 | yes |
| `identity`                      | Identity broker (Keycloak/Red Hat SSO, LDAP directory lookup)        | yes |
| `mongodb`                       | Metadata/persistence store                                           | yes |
| `qdrant`                        | Vector database (RAG embeddings)                                     | yes |
| `rabbitmq`                      | Celery task broker                                                   | yes |
| `redis`                         | Session store / cache                                                | yes |
| `temporal`                      | Distributed execution engine, only needed by `multiagent_temporal_worker` | no |

Each alias maps 1:1 to a `dependencies[]` entry in `Chart.yaml` and can be toggled independently via `<alias>.enabled`.

**Not vendored in this iteration** (no impact on the components above, can be added later the same way): the upstream
"dummy" config-creation charts (`multiagent/multiagent-config`, `rag/unifai-rag-config`, `shared-resources/shared-config`)
whose only role upstream is to trigger bash presync/postsync hooks — replaced here by `templates/shared-config.yaml`,
a direct Secret/ConfigMap template (see below) — and `shared-resources/{redis-config,redis-insight,logging,docling,vllm-serving-engine}`,
none of which were deployed in the fork's own validated test (`MEMORY.md`, cluster `demo333`).

### Shared secrets and config

`templates/shared-config.yaml` creates every ConfigMap/Secret the vendored charts reference by a fixed name
(`shared-config`, `shared-secret`, `unifai-rag-secrets`, `multiagent-be-configmap`, `multiagent-temporal-worker-configmap`,
`multiagent-be-secret`, `redis-secret`, `identity-config`, `identity-secret`), driven entirely by the `glue.*` values —
no Helm hook Jobs, no bash scripts. Fill in `glue.keycloak.*` (identity/SSO), `glue.slack.*` (optional RAG Slack
ingestion), `glue.vault.*`/`glue.langfuse.*`/`glue.umami.*` (optional) before relying on those integrations; `glue.secretKey`,
`glue.credentialEncryptionKey` and `glue.oauthStateSecret` auto-generate if left empty.

> The exact ConfigMap/Secret **key names** used by `identity-config`/`identity-secret` are inferred from the fork's
> documentation, not from reading the identity application's source — double check against your image if SSO/LDAP
> login doesn't pick up the expected values.

### Blueprints

Custom agent-graph blueprints are plain YAML (no CRD) listed under `blueprints: [{name, content}]`, rendered as
ConfigMaps by `templates/blueprints.yaml`. Mounting one into the `multiagent_server` pod is a manual step — add a
matching entry under `multiagent_server.volumes`/`multiagent_server.volumeMounts` referencing the
`unifai-blueprint-<name>` ConfigMap, since Helm values are static data and this chart cannot cross-reference them
from a template.

### Container images

Upstream UnifAI has no public release (no git tag) and no public container registry: production images are built
by an internal Jenkins pipeline and pushed to the private `images.paas.redhat.com/unifai/*` registry. This chart
ships **no default `repository`/`tag`** for the 5 application images (`unifai_backend`, `multiagent_server`,
`multiagent_temporal_worker`, `unifai_rag_server`/`unifai_rag_celery`/`unifai_rag_celery_beat`, `identity.backend`,
`ui`) — build them yourself from the [UnifAI repository](https://github.com/redhat-community-ai-tools/UnifAI) sources
and push to a registry you control:

| Component  | Dockerfile                             | Base image (public)                                            |
| ---------- | --------------------------------------- | ---------------------------------------------------------------- |
| backend    | `backend/Dockerfile`                    | `registry.access.redhat.com/ubi9/python-311`                      |
| multiagent | `multi-agent/Dockerfile`                | `registry.access.redhat.com/ubi10/python-312-minimal`             |
| rag        | `rag/Dockerfile`                        | `registry.access.redhat.com/ubi9/python-311`                      |
| ui         | `ui/deployment/Dockerfile`              | `registry.access.redhat.com/ubi9/nodejs-22` → `ubi9/nginx-120`    |
| identity   | `shared-resources/identity/Dockerfile`  | `registry.access.redhat.com/ubi9/python-311`                      |

All base images are public, unauthenticated Red Hat UBI images, so the 5 components can be fully built from source
without any internal Red Hat access. The [startxfr/UnifAI](https://github.com/startxfr/UnifAI) fork's `Makefile`
(`make build-% push-%`) automates exactly this.

The 5 infrastructure components (`mongodb`, `qdrant`, `rabbitmq`, `redis`) **do** have default images, matching the
public substitutes validated by that same fork (`MEMORY.md`, cluster `demo333`): `docker.io/library/mongo`,
`docker.io/qdrant/qdrant:v1.16.0`, `docker.io/bitnamilegacy/rabbitmq`, `quay.io/fedora/redis-7:20250108` — none of
these depend on a private registry or require a custom build. `temporal` already defaults to the public
`temporalio/temporal` image upstream.

### Known gaps (inherited from the fork's own validated test)

- `unifai_rag_celery`'s default resources request `nvidia.com/gpu: 1` — drop it (`unifai_rag_celery.resources.requests.nvidia\.com/gpu: null` and the matching `limits` entry) if you don't have GPU nodes, or label/taint a node pool for it.
- `unifai_backend`'s `slackSocket` sidecar is enabled by default and will fail without real Slack tokens (`glue.slack.*`) — set `unifai_backend.slackSocket.enabled: false` if you don't use Slack ingestion.
- Storage classes default to `""` (cluster default StorageClass) instead of the AWS-specific classes hardcoded upstream — override `<alias>.storage.className` / `storageClassName` for your cluster if needed.

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

- Deploy every component listed above (except `multiagent_temporal_worker`/`temporal`) in `default-unifai`, including the bundled infrastructure (MongoDB/Qdrant/RabbitMQ/Redis)
- The `project` sub-chart creates the `default-unifai` namespace
- The 5 application images have no default `repository`/`tag` : set them before this will actually start (see "Container images" above)
- `glue.keycloak.*` must be filled in for the identity/SSO integration to work

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
the `-project` Application creates the namespace (every component alias disabled), and the `-app` Application deploys
all enabled components (their defaults already match, `project` disabled).

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
| 21.3.2  | 2026-10-15 | Rebuild as an umbrella chart vendoring the real component charts from startxfr/UnifAI (devel) |

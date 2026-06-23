# ![chaos-cerberus](https://helm-repository.readthedocs.io/en/latest/img/chaos-cerberus.svg "Chaos Chart : Cerberus") Chaos Chart : Cerberus
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--cerberus-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+cerberus+startx)

This helm chart used to deploy cerberus on Openshift or Kubernetes cluster.
Cerberus is as a watchdog who act as a global cluster healthcheck.

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
helm show chart startx/chaos-cerberus
```

### 4. Install this component

```bash
# Install the cerberus project
helm install --set project.enabled=true chaos-cerberus-project  startx/chaos-cerberus
# Deploy the cerberus instance
helm install --set cerberus.enabled=true  chaos-cerberus-instance startx/chaos-cerberus
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organizational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | cerberus     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 1.0.0     | Version name of this application (default use Chart appVersion)                   |

### chaos-cerberus values dictionary

| Key                              | Default                | Description                                                                                                                                                                                                                                                                       |
| -------------------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project                          | {...}                  | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/project/#project-values-dictionary) for more options) |
| project.enable                   | false                  | Enable creation of the namespace                                                                                                                                                                                                                                                  |
| cerberus                         | {...}                  | Configuration of the cerberus deployment                                                                                                                                                                                                                                          |
| cerberus.enable                  | false                  | Enable deploying the cerberus watchdog                                                                                                                                                                                                                                            |
| cerberus.expose                  | true                   | Enable exposition for this application (route based)                                                                                                                                                                                                                              |
| cerberus.kraken_allowed          | true                   | Enable kraken pod to query the cerberus healthcheck (networkpolicy)                                                                                                                                                                                                               |
| cerberus.kraken_ns               | chaos-kraken           | Namespace of the kraken pod that would be allowed                                                                                                                                                                                                                                 |
| cerberus.watch_url_routes        | []                     | Url list of endpoint to watch as part of the global healthcheck (double array)                                                                                                                                                                                                    |
| cerberus.kubeconfig              | {...}                  | Kubeconfig of the supervised tested cluster (mandatory)                                                                                                                                                                                                                           |
| cerberus.watch_nodes                    | true                   | Enable watching nodes health as part of the global health signal                                                                                                                                                                                                                  |
| cerberus.watch_cluster_operators        | true                   | Enable watching cluster operator health as part of the global health signal                                                                                                                                                                                                       |
| cerberus.watch_terminating_namespaces   | true                   | Enable watching terminating namespaces as part of the global health signal                                                                                                                                                                                                        |
| cerberus.watch_namespaces               | [...]                  | List of namespaces to watch (supports regex patterns). Defaults to OpenShift critical namespaces                                                                                                                                                                                   |
| cerberus.watch_namespaces_ignore_pattern| ["^installer.*"]       | Regex patterns for namespaces to exclude from watching                                                                                                                                                                                                                            |
| cerberus.custom_checks                  | []                     | List of custom check scripts (paths relative to /root/cerberus/ working directory). Example: ["config/startx_check.py"]                                                                                                                                                          |
| cerberus.kubeconfig                     | {...}                  | Kubeconfig of the supervised tested cluster (mandatory)                                                                                                                                                                                                                           |
| cerberus.kubeconfig.mode                | token                  | Connection mode to use for the cluster (token, file, or local)                                                                                                                                                                                                                    |
| cerberus.kubeconfig.token               | {...}                  | If mode is token, this section must be filled                                                                                                                                                                                                                                     |
| cerberus.kubeconfig.token.server        | https://localhost:6443 | The server URL to the target cluster API                                                                                                                                                                                                                                          |
| cerberus.kubeconfig.token.token         | sha256~XXX             | The bearer token with cluster-reader access (supports up to 2000 chars since v21.3.103)                                                                                                                                                                                           |
| cerberus.kubeconfig.file                | ""                     | If mode is file, this property must be set with a full kubeconfig content                                                                                                                                                                                                         |

## Values files

### Default values file (values.yaml)

Simple cerberus with default configuration :

- 1 **project** named **chaos-cerberus**
- 1 **scc** with privileged context for **cerberus** deployment
- 1 **configmap** with cerberus server configuration
- 1 **configmap** with kubeconfig of the targeted cluster
- 2 **networkpolicy** allowing route and kraken pods in chaos-kraken namespace, to get cerberus signal
- 1 **deployment** named **cerberus**
  - watching the cluster https://localhost:6443
  - using token sha256~XXXXXXXXXX_PUT_YOUR_TOKEN_HERE_XXXXXXXXXXXX
  - watching no particular routes (as part of the watchdog)
- 1 **service** to the **cerberus** pods
- 1 **route** to the **cerberus** service

```bash
# Install the cerberus project
helm install --set project.enable=true chaos-cerberus-project startx/chaos-cerberus
# Deploy the cerberus instance
helm install --set cerberus.enable=true -n chaos-cerberus chaos-cerberus-instance startx/chaos-cerberus
```

### STARTX values file (values-startx-xxx.yaml)

Same as the default configuration but with namespace prefixed with startx-

```bash
# Configuration running demo example configuration
helm install chaos-cerberus-project startx/chaos-cerberus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-cerberus/values-startx-project.yaml
helm install chaos-cerberus-deploy startx/chaos-cerberus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-cerberus/values-startx-deploy.yaml
```

## Usage examples

### Monitor a cluster using token authentication

Deploy cerberus to monitor a remote cluster and expose its healthcheck endpoint:

```yaml
# my-cerberus-values.yaml
context:
  scope: myorg
  cluster: prod-cluster
  environment: prod
  component: chaos
  app: cerberus-prod

cerberus:
  enabled: true
  expose: true
  kraken_allowed: true
  kraken_ns: chaos-kraken
  watch_url_routes:
    - - http://myapp.prod.svc.cluster.local/healthz
      - "200"
  kubeconfig:
    mode: token
    token:
      server: https://api.prod-cluster.example.com:6443
      token: sha256~REPLACE_WITH_YOUR_TOKEN
```

```bash
helm install chaos-cerberus startx/chaos-cerberus -f my-cerberus-values.yaml -n chaos-cerberus
```

### Monitor a cluster using a kubeconfig file

```yaml
# my-cerberus-file-values.yaml
cerberus:
  enabled: true
  kubeconfig:
    mode: file
    file:
      apiVersion: v1
      kind: Config
      clusters:
      - cluster:
          server: https://api.prod-cluster.example.com:6443
          certificate-authority-data: <base64-encoded-ca>
        name: prod-cluster
      users:
      - name: chaos-user
        user:
          token: sha256~REPLACE_WITH_YOUR_TOKEN
      contexts:
      - context:
          cluster: prod-cluster
          user: chaos-user
        name: prod
      current-context: prod
```

```bash
helm install chaos-cerberus startx/chaos-cerberus -f my-cerberus-file-values.yaml -n chaos-cerberus
```

### Full stack with project namespace

```bash
# 1. Create the namespace
helm install chaos-cerberus-project startx/chaos-cerberus \
  --set project.enabled=true \
  --set project.project.name=chaos-cerberus \
  -n default

# 2. Deploy cerberus
helm install chaos-cerberus startx/chaos-cerberus \
  -f my-cerberus-values.yaml \
  -n chaos-cerberus
```

## ArgoCD deployment

### Prerequisites

**Local mode** (in-cluster, no external credentials): the chart automatically creates the `ClusterRole` and `ClusterRoleBinding` for the `cerberus` ServiceAccount — nothing extra to prepare.

**Token mode** (remote cluster monitoring): Cerberus monitors `ClusterVersions`, `ClusterOperators`, nodes and namespaces — it requires `cluster-reader` access. Create a dedicated ServiceAccount:

```bash
oc create serviceaccount cerberus-monitor -n chaos-cerberus
oc create clusterrolebinding cerberus-monitor-cluster-reader \
  --clusterrole=cluster-reader --serviceaccount=chaos-cerberus:cerberus-monitor
# Generate a long-lived token (schema allows up to 2000 chars since v21.3.103)
SA_TOKEN=$(oc create token cerberus-monitor -n chaos-cerberus --duration=8760h)
```

### Deploy via ArgoCD Application

`chaos-cerberus` follows the project/instance pattern: one Application creates the namespace, a second deploys cerberus. A ready-to-use example file is available at [`examples/argocd/cerberus-argocd.yaml`](examples/argocd/cerberus-argocd.yaml).

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/chaos-cerberus/examples/argocd/
oc apply -k .
```

## History

| Release  | Date       | Description                                                                                                                        |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------- |
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
| 21.3.1 | 2026-03-02 | Prepare release 21.3.x with 21.x dependencies |
| 21.3.3 | 2026-03-02 | Upgrade dependencies to v21.3.0 |
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
|  | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-20 | Improve chaos-cerberus options |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |
| 21.3.107 | 2026-06-21 | publish stable update for the full repository |
| 21.3.108 | 2026-06-22 | Improve chaos-cerberus options |
| 21.3.109 | 2026-06-22 | Improve chaos-cerberus options |
| 21.3.110 | 2026-06-22 | improve cerberus config: fix kraken version ref, networkpolicy scope, add upstream fields, local mode schema, ArgoCD examples |
| 21.3.110 | 2026-06-22 | improve cerberus config: fix kraken version ref, networkpolicy scope, add upstream fields, local mode schema, ArgoCD examples |
| 21.3.111 | 2026-06-22 | fix local mode: generate kubeconfig from SA token at startup (tokenFile unsupported by Python k8s client) |
| 21.3.112 | 2026-06-22 | fix local mode ClusterRole: add nodes/status, CSR, routes, serviceaccounts/token permissions |

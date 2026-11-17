# ![cluster-logging](https://helm-repository.readthedocs.io/en/latest/img/cluster-logging.svg "Cluster Chart : Logging") Cluster Chart : Logging
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--logging-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+logging+startx)

This helm chart is used to configure the OpenShift Logging stack (cluster-logging operator) at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

It manages the two generations of OpenShift Logging, selected with a single boolean (`observability.enabled`):

- the **legacy generation** (Logging 5.x, default): the **ClusterLogging** instance (Elasticsearch log store, Kibana, curator and collector), its optional elasticsearch route and the **ClusterLogForwarder** of the `logging.openshift.io/v1` API
- the **new generation** (Logging 6.x): the collector **ServiceAccount** with its cluster role bindings, the **ClusterLogForwarder** of the `observability.openshift.io/v1` API forwarding the logs to a LokiStack, and the logging **UIPlugin** of the Cluster Observability Operator (Observe > Logs view of the OpenShift console)

The project, the operator subscriptions (`operator`, `operatorElastic`, `operatorLoki`, `operatorObservability`), the optional **EventRouter** and the secret of an external log store do not depend on the selected generation.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

### Logging generations

|                  | Legacy generation                                                                             | New generation                                                                                                 |
| ---------------- | --------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Selection        | `observability.enabled: false` (default)                                                      | `observability.enabled: true`                                                                                  |
| Logging operator | 5.x                                                                                           | 6.x                                                                                                            |
| Values           | `logging` and `logforwarder` blocks                                                           | `observability` block                                                                                          |
| Resources        | ClusterLogging, elasticsearch Route, ClusterLogForwarder and ServiceAccount of `logforwarder` | ServiceAccount, ClusterRoleBindings, ClusterLogForwarder and UIPlugin                                          |
| Log store        | Elasticsearch managed by the ClusterLogging                                                   | LokiStack (see the [cluster-loki](https://helm-repository.readthedocs.io/en/latest/charts/cluster-loki) chart) |
| Console          | Kibana                                                                                        | Observe > Logs (logging UIPlugin)                                                                              |

The generations are mutually exclusive. When `observability.enabled` is `true`, the ClusterLogging, its elasticsearch
route, the ClusterLogForwarder of the `logforwarder` block and its service account are not rendered anymore, even when
`logging.enabled`, `logging.expose.enabled`, `logforwarder.enabled` or `logforwarder.sa.enabled` are `true`. The
`eventrouter` block and the secret of the `logforwarder.secret` block stay available with both generations. With the
default value (`false`), the chart renders exactly what the previous releases rendered.

The `ClusterLogging` API and the `logging.openshift.io/v1` version of the `ClusterLogForwarder` API do not exist anymore
in Logging 6: use the legacy generation only with a Logging 5.x operator (`operator.subscription.version` and
`operator.subscription.operator.channel`).

The new generation requires:

- a **Logging 6.x operator** (`operator.enabled: true`, version `6.5.1` by default)
- a **LokiStack** (`logging-loki` in `openshift-logging` by default) deployed with the
  [cluster-loki](https://helm-repository.readthedocs.io/en/latest/charts/cluster-loki) chart. The Loki operator and the
  logging operator must have the same major and minor versions
- the **Cluster Observability Operator** for the UIPlugin. Enable `operatorObservability` (and
  `operatorObservabilityNamespace`) only when this operator is not already installed in the cluster. A cluster has a
  single UIPlugin of the Logging type (always named `logging`): disable `observability.uiplugin` in the other releases
  of this chart

The OperatorGroup created by the `operator` block targets the namespace of the logging operator only: the
ClusterLogForwarder must be created in this namespace (`project.project.name`), or the OperatorGroup must watch every
namespace (`operator.operatorGroup.target: all-ns`).

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
helm show chart startx/cluster-logging
```

### 4. Install this chart

#### Default values

The default values render nothing: every block is disabled. Enable the blocks of the logging generation you use.

- Legacy generation: deploy the **ClusterLogging** (`instance`) with its elasticsearch log store, kibana, curator and vector collector

```bash
# base configuration running the legacy generation
helm install cluster-logging startx/cluster-logging \
  --set project.project.name=openshift-logging \
  --set logging.enabled=true \
  --set logging.elasticsearch.enabled=true
```

- New generation: deploy the collector **ServiceAccount** (`logging-collector`) allowed to collect the application and
  infrastructure logs and to write them into a LokiStack, the **ClusterLogForwarder** (`instance`) forwarding these logs
  to the LokiStack `logging-loki` and the **UIPlugin** (`logging`) displaying them in the console

```bash
# base configuration running the new generation
helm install cluster-logging startx/cluster-logging \
  --set project.project.name=openshift-logging \
  --set observability.enabled=true
```

The `project.project.name` value is the namespace of the namespaced resources, even when the `project` sub-chart is
disabled.

#### Full deployment with operators and project

Install the namespace and the operators first. Add `operatorObservability.enabled=true` and
`operatorObservabilityNamespace.enabled=true` only when the Cluster Observability Operator is not installed yet. The
`openshift-operators-redhat` namespace of the Loki operator is not created by this chart (the `cluster-config` chart
creates it with `redhat.operators: true`) and it must hold a single OperatorGroup: add
`operatorLoki.operatorGroup.enabled=true` when no other chart creates it.

```bash
helm install cluster-logging startx/cluster-logging \
  --set project.enabled=true \
  --set project.project.name=openshift-logging \
  --set operator.enabled=true \
  --set operatorLoki.enabled=true \
  --set operatorObservability.enabled=true \
  --set operatorObservabilityNamespace.enabled=true
```

When the operators are installed (approve their install plans when `installPlanApproval` is `Manual`) and the
LokiStack is ready, enable the new generation:

```bash
helm upgrade cluster-logging startx/cluster-logging \
  --set project.enabled=true \
  --set project.project.name=openshift-logging \
  --set operator.enabled=true \
  --set operatorLoki.enabled=true \
  --set operatorObservability.enabled=true \
  --set operatorObservabilityNamespace.enabled=true \
  --set observability.enabled=true
```

#### New generation examples

Forward the audit logs to the LokiStack in addition to the application and infrastructure logs. `outputs` and
`pipelines` are lists, and a list is replaced as a whole by your values: this example replaces the default pipeline
and keeps the default output. The rendering fails when `outputs` or `pipelines` are missing and when a pipeline
references an output, an input or a filter that is not defined.

```yaml
project:
  project:
    name: openshift-logging
observability:
  enabled: true
  serviceAccount:
    clusterRoles:
      - collect-application-logs
      - collect-infrastructure-logs
      - collect-audit-logs
      - logging-collector-logs-writer
  forwarder:
    spec:
      pipelines:
        - name: all-logs
          inputRefs:
            - application
            - infrastructure
            - audit
          outputRefs:
            - lokistack-out
```

Forward the application logs to an external Elasticsearch as well, with the credentials of the `logforwarder.secret`
block (or of an ExternalSecret, see [External secrets](#external-secrets)), collect the logs of the infra nodes and
place the console plugin on these nodes:

```yaml
project:
  project:
    name: openshift-logging
logforwarder:
  secret:
    enabled: true
    name: elasticsearch-external
observability:
  enabled: true
  forwarder:
    annotations:
      observability.openshift.io/log-level: info
    spec:
      collector:
        tolerations:
          - effect: NoSchedule
            key: node-role.kubernetes.io/infra
            operator: Exists
      outputs:
        - name: lokistack-out
          type: lokiStack
          lokiStack:
            target:
              name: logging-loki
              namespace: openshift-logging
            authentication:
              token:
                from: serviceAccount
          tls:
            ca:
              key: service-ca.crt
              configMapName: openshift-service-ca.crt
        - name: external-elasticsearch
          type: elasticsearch
          elasticsearch:
            url: https://elasticsearch.example.com:9200
            version: 8
            index: openshift-logs
            authentication:
              username:
                secretName: elasticsearch-external
                key: username
              password:
                secretName: elasticsearch-external
                key: password
          tls:
            ca:
              secretName: elasticsearch-external
              key: ca-bundle.crt
      pipelines:
        - name: infra-app-logs
          inputRefs:
            - application
            - infrastructure
          outputRefs:
            - lokistack-out
        - name: app-logs-to-elasticsearch
          inputRefs:
            - application
          outputRefs:
            - external-elasticsearch
  uiplugin:
    spec:
      deployment:
        nodeSelector:
          node-role.kubernetes.io/infra: ''
        tolerations:
          - effect: NoSchedule
            key: node-role.kubernetes.io/infra
            operator: Exists
```

#### Other available values

- **startx** : logging operators placed on the infra nodes with full STARTX context (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-startx.yaml))
- **startx_noinfra** : same deployment without infra node placement of the operators (see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-startx_noinfra.yaml))

```bash
helm install cluster-logging startx/cluster-logging -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-startx.yaml --set observability.enabled=true
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-logging` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-logging/examples/argocd/
oc apply -k .
```

| Application                | Wave   | Concern                                                                                | Destination         |
| -------------------------- | ------ | -------------------------------------------------------------------------------------- | ------------------- |
| `cluster-logging-project`  | `"1"`  | `project.enabled: true` (namespace `openshift-logging`)                                | `openshift-gitops`  |
| `cluster-logging-operator` | `"5"`  | `operator.enabled: true` and `operatorLoki.enabled: true` (logging and Loki operators) | `openshift-logging` |
| `cluster-logging-app`      | `"10"` | `logging`, `logforwarder` and `eventrouter` blocks (all disabled in the example)       | `openshift-logging` |

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state. To deploy the new generation with these Applications, add `observability.enabled: true` to the values of `cluster-logging-app`. When the Cluster Observability Operator is not installed yet, add `operatorObservability.enabled: true` and `operatorObservabilityNamespace.enabled: true` to the values of `cluster-logging-operator`, and the `openshift-cluster-observability-operator` namespace to the destinations of the AppProject.

## External secrets

The log forwarder secret (`logforwarder.secret`) can come from an external
store (Vault, AWS Secrets Manager...) through the
[External Secrets Operator](https://external-secrets.io) instead of the chart
values. With `logforwarder.secret.externalSecret.enabled: true`, the chart
renders an `ExternalSecret` producing the Secret `logforwarder.secret.name` in
the logging namespace, with the keys of your choice, so the
`ClusterLogForwarder` outputs referencing it are unchanged. Without
`externalSecret`, the chart keeps rendering the Secret from the values.

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
logforwarder:
  secret:
    enabled: true
    name: elasticsearch-external
    externalSecret:
      enabled: true
      dataFrom:
        - extract:
            key: ocp/logging/elasticsearch
```

An `externalSecret` block accepts `secretStoreRef` and `refreshInterval`
(defaults: `externalSecretDefaults`), `remoteRefs` (map of secret key to ESO
`remoteRef`) and the raw ESO fields `data`, `dataFrom` and `template`. Rendering
fails when no store is set or when no key source is provided.

## Values dictionary

### context values dictionary

| Key                 | Default           | Description                                           |
| ------------------- | ----------------- | ----------------------------------------------------- |
| context.scope       | `myscope`         | Name of the global scope for this application         |
| context.cluster     | `default`         | Name of the cluster running this application          |
| context.environment | `myenv`           | Name of the environment (dev, factory, preprod, prod) |
| context.component   | `mycomponent`     | Component name of this application                    |
| context.app         | `default-logging` | Application name                                      |
| context.version     | `6.5.1`           | Version name of this application                      |

### externalSecretDefaults values dictionary

| Key                                        | Default                  | Description                                                      |
| ------------------------------------------ | ------------------------ | ---------------------------------------------------------------- |
| externalSecretDefaults.apiVersion          | `external-secrets.io/v1` | API version of the ExternalSecret CRD                            |
| externalSecretDefaults.refreshInterval     | `1h`                     | How often the Secret is refreshed from the external store        |
| externalSecretDefaults.secretStoreRef.name | `""`                     | Name of the store to read from (required when a secret uses ESO) |
| externalSecretDefaults.secretStoreRef.kind | `ClusterSecretStore`     | Kind of the store (SecretStore or ClusterSecretStore)            |

### observability values dictionary

New generation (Logging 6.x). Requires a Logging 6.x operator, a LokiStack and the Cluster Observability Operator.

| Key                                       | Default                                                                                    | Description                                                                                                                                                                                     |
| ----------------------------------------- | ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| observability.enabled                     | `false`                                                                                    | Select the logging generation: `false` for the legacy generation (Logging 5.x), `true` for the new generation (Logging 6.x)                                                                     |
| observability.hooked                      | `false`                                                                                    | Activate the ClusterLogForwarder and the UIPlugin as helm hooks                                                                                                                                 |
| observability.serviceAccount.enabled      | `true`                                                                                     | Create the service account of the collector and its cluster role bindings                                                                                                                       |
| observability.serviceAccount.name         | `logging-collector`                                                                        | Name of the service account (used by the ClusterLogForwarder)                                                                                                                                   |
| observability.serviceAccount.clusterRoles | `collect-application-logs`, `collect-infrastructure-logs`, `logging-collector-logs-writer` | Cluster roles of the logging operator bound to the service account (add `collect-audit-logs` to forward the audit logs)                                                                         |
| observability.forwarder.enabled           | `true`                                                                                     | Create the ClusterLogForwarder (`observability.openshift.io/v1`), it deploys the collector on every node                                                                                        |
| observability.forwarder.name              | `instance`                                                                                 | Name of the ClusterLogForwarder                                                                                                                                                                 |
| observability.forwarder.annotations       | `{}`                                                                                       | Annotations added to the ClusterLogForwarder (ex: `observability.openshift.io/log-level: debug`)                                                                                                |
| observability.forwarder.spec              | application and infrastructure logs to the LokiStack `logging-loki`                        | Raw spec of the ClusterLogForwarder (`outputs`, `pipelines`, `inputs`, `filters`, `collector`...). `serviceAccount.name` is set with `observability.serviceAccount.name` when it is not defined |
| observability.uiplugin.enabled            | `true`                                                                                     | Create the logging UIPlugin (Observe > Logs view of the console)                                                                                                                                |
| observability.uiplugin.spec               | LokiStack `logging-loki`, `logsLimit: 50`, `timeout: 30s`, `schema: otel`                  | Raw spec of the UIPlugin (`logging`, `deployment`). The name is always `logging` and `type` is always `Logging`                                                                                 |

### logging values dictionary

Legacy generation (Logging 5.x), ignored when `observability.enabled` is `true`.

| Key                                    | Default                       | Description                                                                                |
| -------------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------ |
| logging.enabled                        | `false`                       | Enable the creation of the ClusterLogging                                                  |
| logging.infra_enabled                  | `false`                       | Place elasticsearch and kibana on the infra nodes                                          |
| logging.hooked                         | `false`                       | Activate the ClusterLogging as a helm hook                                                 |
| logging.apiVersion                     | `logging.openshift.io/v1`     | API version of the ClusterLogging                                                          |
| logging.managementState                | `Managed`                     | Management state of the ClusterLogging                                                     |
| logging.expose.enabled                 | `false`                       | Create the route exposing elasticsearch                                                    |
| logging.expose.destinationCACert       | sample certificate            | CA certificate of elasticsearch, used by the reencrypt route                               |
| logging.elasticsearch.enabled          | `false`                       | Enable the elasticsearch log store                                                         |
| logging.elasticsearch.replicas         | `3`                           | Number of elasticsearch nodes                                                              |
| logging.elasticsearch.redundancyPolicy | `SingleRedundancy`            | Redundancy policy (ZeroRedundancy, SingleRedundancy, MultipleRedundancy or FullRedundancy) |
| logging.elasticsearch.resources        | 500m to 1 cpu, 100Mi to 500Mi | Resources of the elasticsearch pods                                                        |
| logging.elasticsearch.storage.class    | `gp3-csi`                     | Storage class of the elasticsearch volumes                                                 |
| logging.elasticsearch.storage.size     | `200G`                        | Size of the elasticsearch volumes                                                          |
| logging.kibana.enabled                 | `true`                        | Enable kibana                                                                              |
| logging.kibana.replicas                | `3`                           | Number of kibana instances                                                                 |
| logging.kibana.resources               | 500m to 1 cpu, 100Mi to 500Mi | Resources of the kibana pods                                                               |
| logging.curation.enabled               | `true`                        | Enable the curator                                                                         |
| logging.curation.schedule              | `30 3 * * *`                  | Schedule of the curator                                                                    |
| logging.collector.enabled              | `true`                        | Enable the collector                                                                       |
| logging.collector.type                 | `vector`                      | Collector engine (vector or fluentd)                                                       |

### logforwarder values dictionary

Legacy generation (Logging 5.x). Only the `logforwarder.secret` block is used when `observability.enabled` is `true`.

| Key                                        | Default                   | Description                                                                          |
| ------------------------------------------ | ------------------------- | ------------------------------------------------------------------------------------ |
| logforwarder.enabled                       | `false`                   | Enable the creation of the ClusterLogForwarder                                       |
| logforwarder.sa.enabled                    | `false`                   | Create the service account of the forwarder with the `collect-*-logs` cluster roles  |
| logforwarder.sa.name                       | `logging-admin`           | Name of the service account                                                          |
| logforwarder.apiVersion                    | `logging.openshift.io/v1` | API version of the ClusterLogForwarder                                               |
| logforwarder.spec                          | pipeline `all-to-default` | Spec of the ClusterLogForwarder (text block)                                         |
| logforwarder.secret.enabled                | `false`                   | Create the secret of an external log store (both generations)                        |
| logforwarder.secret.name                   | `elasticsearch-external`  | Name of the secret                                                                   |
| logforwarder.secret.CABundle               | sample certificate        | CA bundle signing the certificate of the external log store (key `ca-bundle.crt`)    |
| logforwarder.secret.tlsCrt                 | sample certificate        | Client certificate (key `tls.crt`)                                                   |
| logforwarder.secret.tlsKey                 | sample key                | Private key of the client certificate (key `tls.key`)                                |
| logforwarder.secret.username               | `mypwd`                   | Login of the external log store (key `username`)                                     |
| logforwarder.secret.password               | `mypwd`                   | Password of the external log store (key `password`)                                  |
| logforwarder.secret.externalSecret.enabled | `false`                   | Source the secret from an external store (see [External secrets](#external-secrets)) |

### eventrouter values dictionary

| Key                   | Default                          | Description                               |
| --------------------- | -------------------------------- | ----------------------------------------- |
| eventrouter.enabled   | `false`                          | Enable the deployment of the event router |
| eventrouter.replicas  | `1`                              | Number of event router instances          |
| eventrouter.resources | 100m to 400m cpu, 128Mi to 512Mi | Resources of the event router pods        |

### operatorObservabilityNamespace values dictionary

| Key                                    | Default                                    | Description                                                                                       |
| -------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| operatorObservabilityNamespace.enabled | `false`                                    | Create the namespace of the Cluster Observability Operator (keep disabled when it already exists) |
| operatorObservabilityNamespace.name    | `openshift-cluster-observability-operator` | Name of the namespace (must match `operatorObservability.subscription.namespace`)                 |

### project values dictionary

| Key                          | Default                                  | Description                                                   |
| ---------------------------- | ---------------------------------------- | ------------------------------------------------------------- |
| project.enabled              | `false`                                  | Enable the project sub-chart (namespace of the logging stack) |
| project.project.name         | `logging-operator`                       | Name of the namespace hosting the resources of this chart     |
| project.project.display_name | `Operator LOGGING`                       | Display name of the namespace                                 |
| project.project.description  | `LOGGING operators configured by startx` | Description of the namespace                                  |

See the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) for the other keys.

### operator values dictionary

The `operator`, `operatorElastic`, `operatorLoki` and `operatorObservability` blocks configure four instances of the
operator sub-chart and share the same keys.

| Key                                                 | Default                                    | Description                                                               |
| --------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------- |
| operator.enabled                                    | `false`                                    | Enable the subscription of the logging operator                           |
| operator.subscription.name                          | `cluster-logging`                          | Name of the subscription                                                  |
| operator.subscription.namespace                     | `openshift-logging`                        | Namespace of the subscription                                             |
| operator.subscription.version                       | `6.5.1`                                    | Version of the operator                                                   |
| operator.subscription.operator.channel              | `stable-6.5`                               | Channel of the operator                                                   |
| operator.subscription.operator.installPlanApproval  | `Manual`                                   | Approval mode of the operator updates (`Manual` or `Automatic`)           |
| operator.subscription.operator.source.name          | `redhat-operators`                         | Catalog source of the operator                                            |
| operator.subscription.operator.config.infra         | `true`                                     | Place the operator pod on the infra nodes                                 |
| operator.operatorGroup.enabled                      | `true`                                     | Create the OperatorGroup of the `openshift-logging` namespace             |
| operatorElastic.enabled                             | `false`                                    | Enable the subscription of the elasticsearch operator (legacy generation) |
| operatorElastic.subscription.namespace              | `openshift-operators-redhat`               | Namespace of the subscription                                             |
| operatorElastic.subscription.version                | `5.8.14`                                   | Version of the operator                                                   |
| operatorElastic.subscription.operator.channel       | `stable`                                   | Channel of the operator                                                   |
| operatorLoki.enabled                                | `false`                                    | Enable the subscription of the Loki operator (new generation)             |
| operatorLoki.subscription.namespace                 | `openshift-operators-redhat`               | Namespace of the subscription                                             |
| operatorLoki.subscription.version                   | `6.5.1`                                    | Version of the operator                                                   |
| operatorLoki.subscription.operator.channel          | `stable-6.5`                               | Channel of the operator                                                   |
| operatorObservability.enabled                       | `false`                                    | Enable the subscription of the Cluster Observability Operator (UIPlugin)  |
| operatorObservability.subscription.namespace        | `openshift-cluster-observability-operator` | Namespace of the subscription                                             |
| operatorObservability.subscription.version          | `v1.5.5`                                   | Version of the operator                                                   |
| operatorObservability.subscription.operator.channel | `stable`                                   | Channel of the operator                                                   |
| operatorObservability.operatorGroup.enabled         | `true`                                     | Create the OperatorGroup (disable it when the namespace already has one)  |
| operatorObservability.operatorGroup.target          | `all-ns`                                   | Scope of the OperatorGroup (`all-ns` watches every namespace)             |

See the [operator chart](https://helm-repository.readthedocs.io/en/latest/charts/operator) for the other keys.

## History

| Release  | Date       | Description                                                                                                      |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.21 | 2025-03-17 | LogStore is now optional |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.75 | 2026-01-22 | Adding creation of the logging-admin service account |
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
| 21.3.12 | 2026-06-18 | Upgrade cluster-logging to 6.5.1 and add ArgoCD examples |
| 21.3.12 | 2026-06-18 | Improve cluster-logging options |
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
| 21.3.273 | 2026-08-09 | publish stable update for the full repository |
| 21.3.277 | 2026-08-09 | Align all charts to v21.3.277 |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.361 | 2026-11-10 | Release 21.3.361 for all charts |

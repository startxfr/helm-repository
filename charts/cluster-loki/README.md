# ![cluster-loki](https://helm-repository.readthedocs.io/en/latest/img/cluster-loki.svg "Cluster Chart : Loki") Cluster Chart : Loki
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--loki-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+loki+startx)

Configure the Loki log store (LokiStack) of OpenShift Logging with the Red Hat Loki operator.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

It deploys the complete Loki log store of OpenShift Logging 6:

- the **Red Hat Loki operator** (subscription `loki-operator` in `openshift-operators-redhat`, AllNamespaces OperatorGroup) through the `operator` sub-chart
- the **LokiStack** instance (`logging-loki` in `openshift-logging`) with its size, storage schemas, object storage secret, retention, limits, replication, ruler and infra node placement
- the **object storage Secret** read by the LokiStack, either from the chart values or from an External Secrets store
- the optional **AlertingRule**, **RecordingRule** and **RulerConfig** CRs evaluated by the LokiStack ruler

The LokiStack is the log store of the OpenShift Logging collector: deploy the collector and its `ClusterLogForwarder`
with the [cluster-logging](https://helm-repository.readthedocs.io/en/latest/charts/cluster-logging) chart and
reference the LokiStack name (`logging-loki`) in its `lokiStack` output.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

The LokiStack needs an object storage bucket (AWS S3, S3 compatible like MinIO or OpenShift Data Foundation, Azure,
GCS, Swift or Alibaba Cloud) and a storage class for its persistent volumes. The object storage credentials must be
available in a Secret of the LokiStack namespace (`lokistack.storage.secret.name`, default `logging-loki-s3`) before
the LokiStack becomes ready.

### Embedded use by cluster-logging

The `cluster-logging` chart declares this chart as an optional dependency with the alias `loki`
(`loki.enabled: true`). In this embedded mode only the `lokistack`, `storageSecret`, `alertingRules`,
`recordingRules` and `rulerConfig` blocks are used: the `project` and `operator` sub-charts of `cluster-loki` stay
disabled because `cluster-logging` already creates the `openshift-logging` namespace and installs the Loki operator
through its own `operatorLoki` block. The standalone deployment described below is meant for clusters where the
Loki log store is managed independently from the logging collector.

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
helm show chart startx/cluster-loki
```

### 4. Install this chart

#### Default values

The default values render nothing: every block is disabled because the LokiStack needs cluster specific data
(object storage bucket and credentials). Enable the LokiStack and its object storage secret with your own values:

- Deploy the **LokiStack CR** (`openshift-logging/logging-loki`), size `1x.small`, storage class `gp3-csi`, schema `v13`, tenancy mode `openshift-logging`, 7 days of retention
- Deploy the **object storage Secret** (`openshift-logging/logging-loki-s3`) read by the LokiStack
- The operator subscription and namespace are managed separately via the `operator` and `project` sub-charts (both disabled by default)

```bash
# base configuration running default configuration
helm install cluster-loki startx/cluster-loki \
  --set lokistack.enabled=true \
  --set storageSecret.enabled=true \
  --set storageSecret.data.bucketnames=<bucket> \
  --set storageSecret.data.endpoint=https://s3.eu-west-3.amazonaws.com \
  --set storageSecret.data.region=eu-west-3 \
  --set storageSecret.data.access_key_id=<access-key> \
  --set storageSecret.data.access_key_secret=<secret-key>
```

#### Full deployment with operator and project

Enable the Loki operator subscription and the `openshift-logging` namespace alongside the LokiStack. Add
`operatorNamespace.enabled=true` when nothing else creates the `openshift-operators-redhat` namespace of the operator
(the `cluster-config` chart creates it with `redhat.operators: true`):

```bash
helm install cluster-loki startx/cluster-loki \
  --set project.enabled=true \
  --set operator.enabled=true \
  --set operatorNamespace.enabled=true \
  --set lokistack.enabled=true \
  --set storageSecret.enabled=true \
  --set storageSecret.data.bucketnames=<bucket> \
  --set storageSecret.data.endpoint=https://s3.eu-west-3.amazonaws.com \
  --set storageSecret.data.region=eu-west-3 \
  --set storageSecret.data.access_key_id=<access-key> \
  --set storageSecret.data.access_key_secret=<secret-key>
```

Set `operator.operatorGroup.enabled=false` when an OperatorGroup already exists in `openshift-operators-redhat`
(for example created by the `operatorLoki` or `operatorElastic` block of another STARTX chart): a namespace must
hold a single OperatorGroup.

#### Other available values

- **startx** : Loki log store placed on the infra nodes with full STARTX context (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-loki/values-startx.yaml))
- **startx_noinfra** : same deployment without infra node placement (see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-loki/values-startx_noinfra.yaml))

```bash
helm install cluster-loki startx/cluster-loki -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-loki/values-startx.yaml --set lokistack.enabled=true
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-loki` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-loki/examples/argocd/
oc apply -k .
```

| Application             | Wave   | Concern                                                        | Destination                  |
| ----------------------- | ------ | -------------------------------------------------------------- | ---------------------------- |
| `cluster-loki-project`  | `"1"`  | `project.enabled: true` (namespace `openshift-logging`)        | `openshift-logging`          |
| `cluster-loki-operator` | `"5"`  | `operator.enabled: true` (Loki operator subscription)          | `openshift-operators-redhat` |
| `cluster-loki-app`      | `"10"` | `lokistack.enabled: true` (LokiStack CR)                       | `openshift-logging`          |

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state. The `cluster-loki-app` Application ignores the `/metadata/finalizers` added by the operator on the LokiStack. The object storage secret is not part of the examples: add `storageSecret.enabled: true` with your values (or an ExternalSecret) to the `cluster-loki-app` Application, or create it by hand before the sync.

## External secrets

The object storage secret (`storageSecret`) can come from an external store (Vault, AWS Secrets Manager...) through
the [External Secrets Operator](https://external-secrets.io) instead of the chart values. With
`storageSecret.externalSecret.enabled: true`, the chart renders an `ExternalSecret` producing the Secret
`lokistack.storage.secret.name` in the LokiStack namespace, with the keys of your choice, so the LokiStack
referencing it is unchanged. Without `externalSecret`, the chart keeps rendering the Secret from `storageSecret.data`.

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
storageSecret:
  enabled: true
  externalSecret:
    enabled: true
    dataFrom:
      - extract:
          key: ocp/logging/loki-s3
```

An `externalSecret` block accepts `secretStoreRef` and `refreshInterval` (defaults: `externalSecretDefaults`),
`remoteRefs` (map of secret key to ESO `remoteRef`) and the raw ESO fields `data`, `dataFrom` and `template`.
Rendering fails when no store is set or when no key source is provided.

## Values dictionary

### context values dictionary

| Key                 | Default        | Description                                           |
| ------------------- | -------------- | ----------------------------------------------------- |
| context.scope       | `myscope`      | Name of the global scope for this application         |
| context.cluster     | `default`      | Name of the cluster running this application          |
| context.environment | `myenv`        | Name of the environment (dev, factory, preprod, prod) |
| context.component   | `mycomponent`  | Component name of this application                    |
| context.app         | `default-loki` | Application name                                      |
| context.version     | `6.5.1`        | Version name of this application                      |

### externalSecretDefaults values dictionary

| Key                                        | Default                   | Description                                                         |
| ------------------------------------------ | ------------------------- | ------------------------------------------------------------------- |
| externalSecretDefaults.apiVersion          | `external-secrets.io/v1`  | API version of the ExternalSecret CRD                               |
| externalSecretDefaults.refreshInterval     | `1h`                      | How often the Secret is refreshed from the external store           |
| externalSecretDefaults.secretStoreRef.name | `""`                      | Name of the store to read from (required when a secret uses ESO)    |
| externalSecretDefaults.secretStoreRef.kind | `ClusterSecretStore`      | Kind of the store (SecretStore or ClusterSecretStore)               |

### operatorNamespace values dictionary

| Key                       | Default                      | Description                                                                              |
| ------------------------- | ---------------------------- | ---------------------------------------------------------------------------------------- |
| operatorNamespace.enabled | `false`                      | Create the Red Hat operator namespace (keep disabled when cluster-config manages it)     |
| operatorNamespace.name    | `openshift-operators-redhat` | Name of the operator namespace (must match `operator.subscription.namespace`)            |

### lokistack values dictionary

| Key                                      | Default                              | Description                                                                                                   |
| ---------------------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| lokistack.enabled                        | `false`                              | Enable the creation of the LokiStack CR                                                                       |
| lokistack.hooked                         | `false`                              | Deploy as a Helm/ArgoCD post-sync hook                                                                        |
| lokistack.name                           | `logging-loki`                       | Name of the LokiStack (referenced by the ClusterLogForwarder `lokiStack` output)                              |
| lokistack.size                           | `1x.small`                           | Deployment size (`1x.demo`, `1x.pico`, `1x.extra-small`, `1x.small` or `1x.medium`)                          |
| lokistack.storageClassName               | `gp3-csi`                            | Storage class of the Loki persistent volumes                                                                  |
| lokistack.managementState                | `Managed`                            | Management state (`Managed` or `Unmanaged`)                                                                   |
| lokistack.infra_enabled                  | `false`                              | Place every Loki component on the infra nodes (nodeSelector + NoSchedule/NoExecute tolerations)               |
| lokistack.tenants.mode                   | `openshift-logging`                  | Tenancy mode (`openshift-logging`, `openshift-network`, `static`, `dynamic` or `passthrough`)                 |
| lokistack.storage.schemas                | `[{v13, 2024-10-01}]`                | List of storage schemas (`version` v11, v12 or v13 and `effectiveDate`)                                        |
| lokistack.storage.secret.name            | `logging-loki-s3`                    | Name of the object storage secret in the LokiStack namespace                                                  |
| lokistack.storage.secret.type            | `s3`                                 | Object storage provider (`s3`, `azure`, `gcs`, `swift` or `alibabacloud`)                                     |
| lokistack.storage.secret.credentialMode  | `""`                                 | Credential mode of the secret (`static`, `token` or `token-cco`), empty keeps the operator default            |
| lokistack.storage.tls.caName             | `""`                                 | ConfigMap holding the CA of the object storage endpoint (tls rendered only when set)                          |
| lokistack.storage.tls.caKey              | `""`                                 | Key of the CA certificate inside the ConfigMap                                                                |
| lokistack.retention.days                 | `7`                                  | Global retention in days (`0` disables the retention policy, logs are never pruned)                           |
| lokistack.retention.streams              | `[]`                                 | Per-stream retention rules (`days`, `priority`, `selector`), rendered with `retention.days`                   |
| lokistack.limits.ingestion               | `{}`                                 | Raw map rendered under `limits.global.ingestion`                                                              |
| lokistack.limits.queries                 | `{}`                                 | Raw map rendered under `limits.global.queries`                                                                |
| lokistack.replication.factor             | `0`                                  | Replication factor of the ingested data (`0` keeps the default of the size)                                   |
| lokistack.rules.enabled                  | `false`                              | Enable the ruler and the discovery of the AlertingRule/RecordingRule CRs                                      |
| lokistack.rules.selector                 | `{}`                                 | Label selector of the rule CRs evaluated by the ruler                                                         |
| lokistack.rules.namespaceSelector        | `{}`                                 | Label selector of the namespaces where the rule CRs are discovered                                            |
| lokistack.hashRing                       | `{}`                                 | Raw map rendered under `spec.hashRing` (memberlist settings)                                                  |
| lokistack.extraSpec                      | `{}`                                 | Raw map appended to the spec (never repeat a field managed by the values above)                               |

### storageSecret values dictionary

| Key                                          | Default | Description                                                                                         |
| -------------------------------------------- | ------- | --------------------------------------------------------------------------------------------------- |
| storageSecret.enabled                        | `false` | Enable the creation of the object storage secret                                                    |
| storageSecret.name                           | `""`    | Name of the secret (default is `lokistack.storage.secret.name`)                                     |
| storageSecret.data                           | `{}`    | Keys of the secret rendered as `stringData` (S3: `bucketnames`, `endpoint`, `region`, `access_key_id`, `access_key_secret`) |
| storageSecret.externalSecret.enabled         | `false` | Source the secret from an External Secrets store instead of `data`                                  |
| storageSecret.externalSecret.secretStoreRef  | `{}`    | Store to read from (default is `externalSecretDefaults.secretStoreRef`)                             |
| storageSecret.externalSecret.refreshInterval | `""`    | Refresh interval (default is `externalSecretDefaults.refreshInterval`)                              |
| storageSecret.externalSecret.remoteRefs      | `{}`    | Map of secret key to ESO `remoteRef` (`key`, `property`, `version`)                                 |
| storageSecret.externalSecret.data            | `[]`    | Raw ESO `spec.data` list                                                                            |
| storageSecret.externalSecret.dataFrom        | `[]`    | Raw ESO `spec.dataFrom` list                                                                        |
| storageSecret.externalSecret.template        | `{}`    | Raw ESO `spec.target.template`                                                                      |

### alertingRules and recordingRules values dictionary

| Key                                | Default | Description                                                                                      |
| ---------------------------------- | ------- | ------------------------------------------------------------------------------------------------ |
| alertingRules.enabled              | `false` | Enable the creation of the AlertingRule CRs                                                      |
| alertingRules.list                 | `[]`    | List of AlertingRule (`name`, `namespace`, `labels`, raw `spec` with `tenantID` and `groups`)    |
| recordingRules.enabled             | `false` | Enable the creation of the RecordingRule CRs                                                     |
| recordingRules.list                | `[]`    | List of RecordingRule (`name`, `namespace`, `labels`, raw `spec` with `tenantID` and `groups`)   |

The `namespace` of a rule defaults to the LokiStack namespace and its `labels` must match `lokistack.rules.selector`.
In `openshift-logging` tenancy mode the `tenantID` is `application`, `infrastructure` or `audit`, and the application
rules must live in the namespace of the logs they query.

### rulerConfig values dictionary

| Key                 | Default                                     | Description                                                                      |
| ------------------- | ------------------------------------------- | -------------------------------------------------------------------------------- |
| rulerConfig.enabled | `false`                                     | Enable the creation of the RulerConfig CR                                        |
| rulerConfig.name    | `logging-loki-ruler`                        | Name of the RulerConfig (read by the LokiStack of the same namespace)            |
| rulerConfig.spec    | `evaluationInterval: 1m, pollInterval: 1m`  | Raw spec of the RulerConfig (`alertmanager`, `remoteWrite`, `overrides`...)      |

### project values dictionary

| Key                         | Default                                | Description                                                       |
| --------------------------- | -------------------------------------- | ----------------------------------------------------------------- |
| project.enabled             | `false`                                | Enable the project sub-chart (namespace of the LokiStack)         |
| project.project.name        | `openshift-logging`                    | Name of the namespace hosting the LokiStack                       |
| project.project.display_name | `Loki log store`                      | Display name of the namespace                                     |
| project.project.description | `Loki log store configured by STARTX`  | Description of the namespace                                      |

See the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) for the other keys.

### operator values dictionary

| Key                                              | Default                      | Description                                                                 |
| ------------------------------------------------ | ---------------------------- | --------------------------------------------------------------------------- |
| operator.enabled                                 | `false`                      | Enable the operator sub-chart (Loki operator subscription)                  |
| operator.subscription.name                       | `loki-operator`              | Name of the subscription                                                    |
| operator.subscription.namespace                  | `openshift-operators-redhat` | Namespace of the subscription                                               |
| operator.subscription.version                    | `6.5.1`                      | Version of the operator                                                     |
| operator.subscription.operator.channel           | `stable-6.5`                 | Channel of the operator                                                     |
| operator.subscription.operator.installPlanApproval | `Manual`                   | Approval mode of the operator updates (`Manual` or `Automatic`)             |
| operator.subscription.operator.source.name       | `redhat-operators`           | Catalog source of the operator                                              |
| operator.subscription.operator.config.infra      | `false`                      | Place the operator pod on the infra nodes                                   |
| operator.operatorGroup.enabled                   | `true`                       | Create the OperatorGroup (disable it when the namespace already has one)    |
| operator.operatorGroup.target                    | `all-ns`                     | Scope of the OperatorGroup (`all-ns` watches every namespace)               |
| operator.operatorGroup.providedAPIs              | `AlertingRule...RulerConfig` | APIs provided by the operator                                               |

See the [operator chart](https://helm-repository.readthedocs.io/en/latest/charts/operator) for the other keys.

## History

| Release  | Date       | Description            |
| -------- | ---------- | ---------------------- |
| 21.3.321 | 2026-11-08 | Initial chart creation |

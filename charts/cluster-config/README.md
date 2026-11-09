# ![cluster-config](https://helm-repository.readthedocs.io/en/latest/img/cluster-config.svg "Cluster Chart : Config") Cluster Chart : Config
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--config-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+config+startx)

This helm chart is used to create a personnalized cluster configuration with various cluster level components configured as required.

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
helm show chart startx/cluster-config
```

### 4. Install this chart

```bash
helm install cluster-config startx/cluster-config
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **ClusterAutoscaler:** named **default** that is disabled by default but could enable autoscaling with the following limits
  - No lest than **4 cores**
  - No lest than **16Gi RAM**
  - No lest than **2 nodes**
  - No more than **40 cores**
  - No more than **160Gi RAM**
  - No more than **20 nodes**
  - Cluster could **scale down**
- 1 **ClusterVersion:** named **version** that is disabled by default but could enable and is related to
  - The **candidate** channel
  - The **4.5** version
- 1 **Secret:** named **alertmanager-main** that configure
  - The **PagerDutyStartx** receiver as default alert receiver using the startx pagerDutty key (fake ;)
  - An api endpoint pointing to the **_api_endpoint_** endpoint
- 1 **ImagePruner:** named **cluster** that define an image prunner that will
  - Run every **15min** but is **suspended**
  - Preserve **5 failed** history
  - Preserve **5 successful** history
- 1 **namespace:** named **openshift-operators-redhat** to host redhat operators

```bash
# base configuration running default configuration
helm install cluster-config startx/cluster-config
```

## Cluster monitoring

The `monitoring` block manages the `cluster-monitoring-config` ConfigMap of the `openshift-monitoring`
namespace (platform Prometheus and Alertmanager) and, with `monitoring.userWorkload.enabled`, the
`user-workload-monitoring-config` ConfigMap of the `openshift-user-workload-monitoring` namespace.
Both ConfigMaps replace any existing configuration, which is validated by the monitoring admission
webhook of OpenShift 4.19+: unknown keys and the reserved external labels `prometheus`,
`prometheus_replica` and `cluster` are rejected, this is why the cluster name is exposed as
`cluster_name`. Dashboards, alert routes or remote write relabelings keyed on the former `cluster`
external label must be updated to `cluster_name` when upgrading an existing deployment.

```yaml
monitoring:
  enabled: true
  infra_enabled: false
  storageClass: ocs-storagecluster-ceph-rbd   # block RWO storage class of the cluster
  storageSize: "50Gi"                          # per Prometheus replica (2 PVC)
  storageSizeAlert: "5Gi"                      # per Alertmanager replica (2 PVC)
  retentionPeriod: 15d
  retentionSize: 40GB                          # about 80% of storageSize
  enableUserWorkload: true
  externalLabels:
    custom:
      site: paris
  userWorkload:
    enabled: true
    retentionPeriod: 7d
    storageSize: "10Gi"
```

| Key                                   | Default        | Description                                                                                   |
| ------------------------------------- | -------------- | --------------------------------------------------------------------------------------------- |
| monitoring.enabled                    | `false`        | Manage the cluster-monitoring-config ConfigMap                                                |
| monitoring.infra_enabled              | `false`        | Deploy the monitoring components (except node-exporter) on the infra nodes                    |
| monitoring.storageClass               | `gp3-csi`      | Storage class of the Prometheus and Alertmanager persistent volumes                           |
| monitoring.storageSize                | `20Gi`         | Size of the Prometheus persistent volume (one per replica)                                    |
| monitoring.storageSizeAlert           | `5Gi`          | Size of the Alertmanager persistent volume (one per replica)                                  |
| monitoring.enableUserWorkload         | `false`        | Enable the monitoring of user-defined projects                                                |
| monitoring.retentionPeriod            | `7d`           | Prometheus data retention duration                                                            |
| monitoring.retentionSize              | `""`           | Prometheus maximum data size on disk (ex: `40GB`), empty keeps only the time-based retention  |
| monitoring.resources                  | 200m / 2Gi     | Resource requests and limits of the Prometheus pods                                           |
| monitoring.externalLabels.contextLabels | `true`       | Add the `scope`, `environment` and `cluster_name` labels from the deployment context          |
| monitoring.externalLabels.custom      | `{}`           | Additional external labels (reserved keys are rejected)                                       |
| monitoring.remoteWrite                | `[]`           | Remote write endpoints of the platform Prometheus                                             |
| monitoring.alertmanager.enabled       | `true`         | Deploy the platform Alertmanager                                                              |
| monitoring.extraConfig                | `{}`           | Additional cluster-monitoring-config settings added as-is (managed keys must not be repeated) |
| monitoring.userWorkload.enabled       | `false`        | Manage the user-workload-monitoring-config ConfigMap (requires `enableUserWorkload`)          |
| monitoring.userWorkload.retentionPeriod | `24h`        | Data retention duration of the user workload Prometheus                                       |
| monitoring.userWorkload.retentionSize | `""`           | Maximum data size on disk of the user workload Prometheus                                     |
| monitoring.userWorkload.storageClass  | `""`           | Storage class of the user workload Prometheus volume (empty uses `monitoring.storageClass`)   |
| monitoring.userWorkload.storageSize   | `10Gi`         | Size of the user workload Prometheus persistent volume (one per replica)                      |
| monitoring.userWorkload.resources     | `{}`           | Resource requests and limits of the user workload Prometheus pods                             |
| monitoring.userWorkload.extraConfig   | `{}`           | Additional user-workload-monitoring-config settings added as-is                               |

Switching from the default ephemeral storage to persistent volumes restarts the Prometheus and
Alertmanager pods: the metrics history and the active silences are lost. Growing `storageSize` later
does not resize existing PersistentVolumeClaims.

## Other available values

- **startx** : Startx cluster default configuration with 30min enabled image prunnning scheduling, pagerdutty alert enabled and cluster auto-scaling topped to 64 core and 400Gi RAM consumed (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-config/values-startx.yaml))

```bash
helm install cluster-config startx/cluster-config -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-config/values-startx.yaml
```

## Deploy with ArgoCD

This chart configures multiple cluster domains. Deploy one ArgoCD Application per domain.

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-config/examples/argocd/
oc apply -k .
```

### Applications



## External secrets

Secrets rendered from values can come from an external store (Vault, AWS
Secrets Manager...) through the [External Secrets Operator](https://external-secrets.io)
instead. With `externalSecret.enabled: true` in one of the sections below, the
chart renders an `ExternalSecret` producing the very same Secret, so the objects
that reference it (`APIServer`, `IngressController`, image registry, monitoring)
are unchanged. Without `externalSecret`, the chart keeps rendering the Secret
from the values.

| Section | Secret produced (namespace) | Required keys |
| ------- | --------------------------- | ------------- |
| `api.externalSecret` | `api.name` (openshift-config, `kubernetes.io/tls`) | `tls.crt`, `tls.key` |
| `ingresscontroller.list[].certificate.externalSecret` | `<name>-ingress-cert` (openshift-ingress, `kubernetes.io/tls`) | `tls.crt`, `tls.key` |
| `alertmanager.externalSecret` | `alertmanager-main` (openshift-monitoring) | `alertmanager.yaml` |
| `registryconfig.externalSecret` | `image-registry-private-configuration-user` (openshift-image-registry) | `REGISTRY_STORAGE_S3_ACCESSKEY`, `REGISTRY_STORAGE_S3_SECRETKEY` |

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
api:
  enabled: true
  url: api.mycluster.example.com
  externalSecret:
    enabled: true
    remoteRefs:
      tls.crt:
        key: ocp/certificates/api
        property: tls.crt
      tls.key:
        key: ocp/certificates/api
        property: tls.key
```

An `externalSecret` block accepts `secretStoreRef` and `refreshInterval`
(defaults: `externalSecretDefaults`), `remoteRefs` (map of secret key to ESO
`remoteRef`) and the raw ESO fields `data`, `dataFrom` and `template` (e.g. to
build `alertmanager.yaml` from individual keys). Rendering fails when no store
is set or when a required key is not provided.

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.21 | 2025-03-31 | Add NoExecute toleration for node-role.kubernetes.io/infra |
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
| 21.3.12 | 2026-06-18 | Update context version to 4.21.3, loki operator to v6.5.1, add multi-app ArgoCD deployment examples |
| 21.3.13 | 2026-06-18 | Improve cluster-config options |
| 21.3.14 | 2026-06-18 | Improve cluster-config options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
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
| 21.3.107 | 2026-06-21 | publish stable update for the full repository |
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
| 21.3.321 | 2026-11-08 | Monitoring: configurable retention size, resources, external labels (cluster_name replaces the reserved cluster label), remote write, Alertmanager toggle, extra settings and user workload monitoring storage. With monitoring.enabled the rendered ConfigMap changes: metricsServer and monitoringPlugin replace k8sPrometheusAdapter, label app.kubernetes.io/name ends with -monitoring- |

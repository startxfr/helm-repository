# ![cluster-prometheus](https://helm-repository.readthedocs.io/en/latest/img/cluster-prometheus.svg "Cluster Chart : Prometheus") Cluster Chart : Prometheus
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--prometheus-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+prometheus+startx)

Configure the Cluster Observability Operator and the Prometheus monitoring stacks of the application workloads, in standard namespaces or in user-defined networks.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

Custom Prometheus instances (a `Prometheus` resource managed by a Prometheus operator installed next to the one of OpenShift) are
not supported on OpenShift. Standalone, fully configurable Prometheus instances are provided by the Red Hat
**Cluster Observability Operator** (COO): its `MonitoringStack` resource deploys a highly available Prometheus (with a Thanos
sidecar) and an Alertmanager that are independent from the platform monitoring and from the user workload monitoring, and that
can be deployed next to them. This chart installs the operator and manages:

- the **monitoring stacks** (`MonitoringStack`) and the RBAC they need (federation of the platform metrics, discovery limited to some namespaces)
- the **scrape configuration** of the workloads (`ServiceMonitor`, `PodMonitor`, `ScrapeConfig`), their **rules** (`PrometheusRule`)
  and the **routing of the alerts** (`AlertmanagerConfig`), linked to a stack with a label
- the **global query endpoints** (`ThanosQuerier`)
- the **network policies** opening the metrics ports of the workloads, the optional **routes** and the **secrets** (from values or
  through an `ExternalSecret`)

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

### Prerequisites

- Access to the `redhat-operators` catalog of the software catalog
- `cluster-admin` privileges
- A storage class when the stacks use a persistent volume (`spec.prometheusConfig.persistentVolumeClaim`)
- At least two nodes matching the node selector of a stack: its Prometheus pods and its Alertmanager pods are always scheduled on
  distinct nodes (two replicas each by default)

The operator only supports the `AllNamespaces` install mode. It is installed in the `openshift-cluster-observability-operator`
namespace, created by the `operatorNamespace` block with the `openshift.io/cluster-monitoring` label. The stacks run in the
`default-prometheus` namespace created by the `project` sub-chart.

### The monitoring.rhobs API group

The operator ships its own copy of the Prometheus operator, with the same resources in a different API group: `monitoring.rhobs`
instead of `monitoring.coreos.com`. A stack only reads the `monitoring.rhobs` resources: an existing `ServiceMonitor` of the
`monitoring.coreos.com` group (the one handled by the monitoring of OpenShift) is ignored and must be declared again with this
chart. The specifications are identical.

### How a stack selects what it monitors

| Setting of the stack             | Role                                                                                                                                         | Default of the operator                              |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `spec.resourceSelector`          | Labels of the `ServiceMonitor`, `PodMonitor`, `ScrapeConfig`, `PrometheusRule` and `AlertmanagerConfig` resources read by the stack          | not set: no scrape configuration and no rule is read |
| `spec.namespaceSelector`         | Labels of the namespaces where these resources are read                                                                                      | not set: the namespace of the stack                  |
| `spec.createClusterRoleBindings` | With a namespace selector, bind the Prometheus service account to a cluster role reading the services, endpoints and pods of every namespace | `CreateClusterRoleBindings`                          |

This chart links the resources to the stacks with the `monitoring.rhobs/stack` label:

- when `spec.resourceSelector` is not set, the chart selects `monitoring.rhobs/stack: <name of the stack>`
- every `serviceMonitors`, `podMonitors`, `scrapeConfigs`, `prometheusRules` and `alertmanagerConfigs` item declared with
  `stack: <name>` gets this label

The namespaces are selected with their own labels (`matchLabels`), by name with the `kubernetes.io/metadata.name` label that
every namespace carries (`matchExpressions`), or all at once with an empty selector (`{}`).

To avoid the cluster wide read access, set `spec.createClusterRoleBindings: NoClusterRoleBindings` and list the monitored
namespaces in `monitoredNamespaces`: the chart binds the cluster role of the stack in these namespaces only.

### Workloads attached to a user-defined network

A pod of a namespace attached to a **primary** user-defined network (`UserDefinedNetwork` or `ClusterUserDefinedNetwork`) keeps an
address on the default pod network, and this is the address Kubernetes publishes in the pod status and in the endpoints of the
services. Prometheus therefore discovers this address, but OVN-Kubernetes only lets the kubelet health checks reach it: without any
other setting, the targets are discovered and every scrape times out. To monitor these workloads:

1. Keep the stack in a namespace of the default pod network (the `default-prometheus` project). A stack running inside a
   user-defined network cannot scrape its own components, reach its Alertmanager or reach the discovered targets.
2. Open the metrics port of the workload pods on the default network with the `k8s.ovn.org/open-default-ports` annotation, set in
   the pod template of the workload:

   ```yaml
   spec:
     template:
       metadata:
         annotations:
           k8s.ovn.org/open-default-ports: |
             - protocol: tcp
               port: 8080
   ```

3. Declare the `ServiceMonitor` or `PodMonitor` in the namespace of the workload, as for any other namespace, and make this
   namespace match the namespace selector of the stack (the [cluster-cudn](https://helm-repository.readthedocs.io/en/latest/charts/cluster-cudn)
   chart sets labels on the namespaces it creates).

Keep in mind:

- the opened port is reachable by every pod of the default network, and the network policies of the namespace do not filter it:
  only open the metrics port, and protect the metrics with TLS and an authentication when they are sensitive
- a pod of a primary user-defined network cannot reach the services of the default network (the Kubernetes API and the DNS
  excepted): it cannot push its metrics to a stack (remote write, OTLP), the metrics have to be scraped
- the namespaces that only use **secondary** networks (Localnet, secondary user-defined network) keep the default pod network as
  primary network: nothing specific is required

### Access to the metrics

| Component      | Service                 | Port           |
| -------------- | ----------------------- | -------------- |
| Prometheus     | `<stack>-prometheus`    | `9090` (web)   |
| Alertmanager   | `<stack>-alertmanager`  | `9093` (web)   |
| Thanos Querier | `thanos-querier-<name>` | `10902` (http) |

These services have no authentication. Inside the cluster, use them as a Prometheus data source (Perses dashboards of the operator,
Grafana) and protect them with network policies of the `project` sub-chart. The `routes` block publishes a service outside of the
cluster: every client able to reach the router can then read the metrics and use the administration API, restrict the clients
(`haproxy.router.openshift.io/ip_allowlist` annotation) or prefer `oc port-forward`.

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
helm show chart startx/cluster-prometheus
```

### 4. Install this chart

#### Default values

The default values keep every feature disabled and render nothing: the stacks and the monitored workloads are specific to each
cluster and must be provided in a values file.

- No stack and no scrape configuration are created
- The operator subscription and namespaces are managed separately via the `operator` and `project` sub-charts and the
  `operatorNamespace` block (all disabled by default)

```bash
# base configuration running default configuration
helm install cluster-prometheus startx/cluster-prometheus
```

#### Full deployment with operator and project

Helm cannot create a custom resource before its API exists: install the namespaces and the operator first, approve its
InstallPlan (the subscription uses `installPlanApproval: Manual`), then enable a stack and the monitoring of a workload.

```bash
# 1. namespaces and operator
helm install cluster-prometheus startx/cluster-prometheus \
  --set project.enabled=true \
  --set operatorNamespace.enabled=true \
  --set operator.enabled=true
oc -n openshift-cluster-observability-operator get installplan
oc -n openshift-cluster-observability-operator patch installplan <name> --type merge -p '{"spec":{"approved":true}}'

# 2. stack, scrape configuration and alert of the my-app workload, once the operator is running
cat > my-prometheus.yaml <<EOF
monitoringStacks:
  enabled: true
  list:
    - name: apps
      spec:
        retention: 7d
        namespaceSelector:
          matchExpressions:
            - key: kubernetes.io/metadata.name
              operator: In
              values:
                - default-prometheus
                - my-app
        prometheusConfig:
          persistentVolumeClaim:
            resources:
              requests:
                storage: 20Gi
serviceMonitors:
  enabled: true
  list:
    - name: my-app
      namespace: my-app
      stack: apps
      spec:
        selector:
          matchLabels:
            app.kubernetes.io/name: my-app
        endpoints:
          - port: metrics
            interval: 30s
prometheusRules:
  enabled: true
  list:
    - name: my-app
      namespace: my-app
      stack: apps
      spec:
        groups:
          - name: my-app
            rules:
              - alert: MyAppDown
                expr: up{job="my-app"} == 0
                for: 5m
                labels:
                  severity: critical
EOF
helm upgrade cluster-prometheus startx/cluster-prometheus -f my-prometheus.yaml \
  --set project.enabled=true \
  --set operatorNamespace.enabled=true \
  --set operator.enabled=true
```

Check the targets of the stack with `oc -n default-prometheus port-forward svc/apps-prometheus 9090` and
`http://localhost:9090/targets`.

#### Workload of a user-defined network

The values are the same as for a standard namespace. Only the workload changes: its pod template carries the
`k8s.ovn.org/open-default-ports` annotation (see [Workloads attached to a user-defined network](#workloads-attached-to-a-user-defined-network)).
A `PodMonitor` scrapes the pods directly:

```yaml
podMonitors:
  enabled: true
  list:
    - name: my-udn-app
      namespace: my-udn-app
      stack: apps
      spec:
        selector:
          matchLabels:
            app.kubernetes.io/name: my-udn-app
        podMetricsEndpoints:
          - port: metrics
            interval: 30s
```

#### Metrics of the platform monitoring

The CPU, memory and state metrics of the pods (`container_*`, `kube_*`) are collected by the platform monitoring of OpenShift. A
stack reads the ones it needs from the federation endpoint of the platform Prometheus: `clusterMonitoringView: true` grants the
access, and a `ServiceMonitor` selecting the Prometheus service of the stack itself is relabeled to the platform Prometheus:

```yaml
monitoringStacks:
  enabled: true
  list:
    - name: apps
      clusterMonitoringView: true
serviceMonitors:
  enabled: true
  list:
    - name: federate-platform
      stack: apps
      spec:
        selector:
          matchLabels:
            app.kubernetes.io/managed-by: observability-operator
            app.kubernetes.io/name: apps-prometheus
        endpoints:
          - port: web
            scheme: https
            path: /federate
            interval: 30s
            honorLabels: true
            params:
              'match[]':
                - '{__name__=~"container_cpu_usage_seconds_total|container_memory_working_set_bytes", namespace="my-app"}'
                - '{__name__=~"kube_pod_.*", namespace="my-app"}'
            relabelings:
              - action: replace
                targetLabel: __address__
                replacement: prometheus-k8s.openshift-monitoring.svc:9091
              - action: labeldrop
                regex: pod|namespace|service|endpoint|container
            bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
            tlsConfig:
              serverName: prometheus-k8s.openshift-monitoring.svc
              ca:
                configMap:
                  name: openshift-service-ca.crt
                  key: service-ca.crt
```

Only federate the metrics you need: the request is evaluated by the platform Prometheus at every scrape.

#### Other available values

- **startx** : one `startx` stack on the infra nodes (two Prometheus replicas with a 20Gi volume, seven days of retention, Alertmanager) monitoring the namespaces labelled `monitoring.rhobs/stack: startx`, operator on the infra nodes (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-prometheus/values-startx.yaml))
- **startx_noinfra** : same deployment without infra nodes placement (see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-prometheus/values-startx_noinfra.yaml))

```bash
helm install cluster-prometheus startx/cluster-prometheus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-prometheus/values-startx.yaml
```

### Annotations and sync-waves

Every resource list (`monitoringStacks`, `serviceMonitors`, `podMonitors`, `prometheusRules`, `scrapeConfigs`, `alertmanagerConfigs`, `thanosQueriers`, `networkPolicies`, `routes` and `secrets`) accepts an `annotations` map per item. It is merged over the default ArgoCD sync-wave of the resource, so `argocd.argoproj.io/sync-wave` and `argocd.argoproj.io/sync-options` can be overridden. A `MonitoringStack` also accepts an explicit `spec.resourceSelector`.

## Values files

Example values files shipped with the chart, to use with `helm install -f <file>` :

- **startx** : context `startx/default/infra`; against `values.yaml`: differ on 18 keys, by top-level key: `project` (6), `operator` (5), `context` (4), `monitoringStacks` (2), ... (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-prometheus/values-startx.yaml))
- **startx_noinfra** : context `startx/default/infra`; against `values-startx.yaml`: differ on `monitoringStacks.list`, `operator.subscription.operator.config.infra` (true → false) (see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-prometheus/values-startx_noinfra.yaml))
- `examples/argocd/` : 5 example manifest(s) (see the ArgoCD or usage sections)

```bash
helm install cluster-prometheus startx/cluster-prometheus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-prometheus/values-startx.yaml
```

## Values dictionary

### context values dictionary

| Key                 | Default              | Description                                           |
| ------------------- | -------------------- | ----------------------------------------------------- |
| context.scope       | `myscope`            | Name of the global scope for this application         |
| context.cluster     | `default`            | Name of the cluster running this application          |
| context.environment | `myenv`              | Name of the environment (dev, factory, preprod, prod) |
| context.component   | `mycomponent`        | Component name of this application                    |
| context.app         | `default-prometheus` | Application name                                      |
| context.version     | `1.5.5`              | Version name of this application                      |

### externalSecretDefaults values dictionary

| Key                                        | Default                  | Description                                                                        |
| ------------------------------------------ | ------------------------ | ---------------------------------------------------------------------------------- |
| externalSecretDefaults.apiVersion          | `external-secrets.io/v1` | API version of the ExternalSecret CRD                                              |
| externalSecretDefaults.refreshInterval     | `1h`                     | How often the Secret is refreshed from the external store                          |
| externalSecretDefaults.secretStoreRef.name | `""`                     | Name of the (Cluster)SecretStore, required as soon as a secret uses externalSecret |
| externalSecretDefaults.secretStoreRef.kind | `ClusterSecretStore`     | Kind of the store (`ClusterSecretStore` or `SecretStore`)                          |

### operatorNamespace values dictionary

| Key                       | Default                                    | Description                                                                        |
| ------------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------- |
| operatorNamespace.enabled | `false`                                    | Enable the creation of the operator namespace (sync-wave `-10`, kept on uninstall) |
| operatorNamespace.name    | `openshift-cluster-observability-operator` | Name of the operator namespace (must match `operator.subscription.namespace`)      |

### monitoringStacks values dictionary

| Key                                                | Default                          | Description                                                                                                      |
| -------------------------------------------------- | -------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| monitoringStacks.enabled                           | `false`                          | Enable the creation of the `MonitoringStack` resources (sync-wave `15`)                                          |
| monitoringStacks.hooked                            | `false`                          | Activate the resources as helm hooks                                                                             |
| monitoringStacks.list                              | `[]`                             | List of stacks                                                                                                   |
| monitoringStacks.list[].name                       |                                  | Name of the stack (required), prefix of the objects created by the operator                                      |
| monitoringStacks.list[].namespace                  | project name                     | Namespace of the stack (a namespace of the default pod network)                                                  |
| monitoringStacks.list[].labels                     | `{}`                             | Additional labels (matched by the selector of a `ThanosQuerier`)                                                 |
| monitoringStacks.list[].clusterMonitoringView      | `false`                          | Bind the `cluster-monitoring-view` cluster role to the Prometheus service account of the stack (federation)      |
| monitoringStacks.list[].monitoredNamespaces        | `[]`                             | Namespaces where the cluster role of the stack is bound with a `RoleBinding` (used with `NoClusterRoleBindings`) |
| monitoringStacks.list[].spec                       | `{}`                             | Specification of the stack, rendered as is                                                                       |
| ...spec.resourceSelector                           | `monitoring.rhobs/stack: <name>` | Label selector of the resources read by the stack (`{}`: every resource)                                         |
| ...spec.namespaceSelector                          | namespace of the stack           | Label selector of the namespaces where the resources are read (`{}`: every namespace)                            |
| ...spec.createClusterRoleBindings                  | `CreateClusterRoleBindings`      | `NoClusterRoleBindings` keeps the discovery to the `monitoredNamespaces`                                         |
| ...spec.logLevel                                   | `info`                           | Log level (`debug`, `info`, `warn`, `error`)                                                                     |
| ...spec.retention                                  | `120h`                           | Retention of the metrics                                                                                         |
| ...spec.retentionSize                              | unlimited                        | Maximum size of the data                                                                                         |
| ...spec.resources                                  |                                  | Resources of the Prometheus container                                                                            |
| ...spec.nodeSelector, tolerations                  |                                  | Placement of the Prometheus and Alertmanager pods                                                                |
| ...spec.prometheusConfig.replicas                  | `2`                              | Number of Prometheus pods                                                                                        |
| ...spec.prometheusConfig.scrapeInterval            |                                  | Default interval between two scrapes                                                                             |
| ...spec.prometheusConfig.externalLabels            |                                  | Labels added to the metrics and alerts leaving this Prometheus                                                   |
| ...spec.prometheusConfig.persistentVolumeClaim     |                                  | Persistent volume of each Prometheus pod                                                                         |
| ...spec.prometheusConfig.remoteWrite               |                                  | Remote write endpoints                                                                                           |
| ...spec.prometheusConfig.enableRemoteWriteReceiver | `false`                          | Accept metrics pushed with the remote write protocol                                                             |
| ...spec.prometheusConfig.enableOtlpHttpReceiver    | `false`                          | Accept metrics pushed with OTLP over HTTP                                                                        |
| ...spec.prometheusConfig.webTLSConfig              |                                  | Serve the Prometheus web interface with TLS                                                                      |
| ...spec.alertmanagerConfig.disabled                | `false`                          | Do not deploy Alertmanager                                                                                       |
| ...spec.alertmanagerConfig.replicas                | `2`                              | Number of Alertmanager pods                                                                                      |

### thanosQueriers values dictionary

| Key                             | Default                  | Description                                                           |
| ------------------------------- | ------------------------ | --------------------------------------------------------------------- |
| thanosQueriers.enabled          | `false`                  | Enable the creation of the `ThanosQuerier` resources (sync-wave `30`) |
| thanosQueriers.hooked           | `false`                  | Activate the resources as helm hooks                                  |
| thanosQueriers.list             | `[]`                     | List of queriers                                                      |
| thanosQueriers.list[].name      |                          | Name of the querier (required)                                        |
| thanosQueriers.list[].namespace | project name             | Namespace of the querier                                              |
| thanosQueriers.list[].labels    | `{}`                     | Additional labels                                                     |
| thanosQueriers.list[].spec      |                          | Specification, rendered as is (required)                              |
| ...spec.selector                |                          | Label selector of the queried stacks (required, `{}`: every stack)    |
| ...spec.namespaceSelector       | namespace of the querier | Namespaces of the queried stacks (`matchNames` or `any: true`)        |
| ...spec.replicaLabels           |                          | Additional replica labels                                             |

### Scrape, rules and alert routing values dictionary

The `serviceMonitors`, `podMonitors`, `scrapeConfigs`, `prometheusRules` and `alertmanagerConfigs` blocks share the same keys,
relative to the block (sync-wave `30`):

| Key              | Default      | Description                                                                      |
| ---------------- | ------------ | -------------------------------------------------------------------------------- |
| enabled          | `false`      | Enable the creation of the resources of the block                                |
| list             | `[]`         | List of resources                                                                |
| list[].name      |              | Name of the resource (required)                                                  |
| list[].namespace | project name | Namespace of the resource (must be selected by the stack)                        |
| list[].stack     |              | Name of the stack reading the resource (sets the `monitoring.rhobs/stack` label) |
| list[].labels    | `{}`         | Additional labels                                                                |
| list[].spec      |              | Specification, rendered as is (required)                                         |

| Block               | Kind                 | API version                 |
| ------------------- | -------------------- | --------------------------- |
| serviceMonitors     | `ServiceMonitor`     | `monitoring.rhobs/v1`       |
| podMonitors         | `PodMonitor`         | `monitoring.rhobs/v1`       |
| scrapeConfigs       | `ScrapeConfig`       | `monitoring.rhobs/v1alpha1` |
| prometheusRules     | `PrometheusRule`     | `monitoring.rhobs/v1`       |
| alertmanagerConfigs | `AlertmanagerConfig` | `monitoring.rhobs/v1alpha1` |

### networkPolicies, routes and secrets values dictionary

| Key                               | Default            | Description                                                                                 |
| --------------------------------- | ------------------ | ------------------------------------------------------------------------------------------- |
| networkPolicies.enabled           | `false`            | Enable the creation of the `NetworkPolicy` resources (sync-wave `15`)                       |
| networkPolicies.list              | `[]`               | List of policies: `name` and `namespace` (required), `labels`, `spec` (rendered as is)      |
| routes.enabled                    | `false`            | Enable the creation of the `Route` resources (sync-wave `20`)                               |
| routes.list                       | `[]`               | List of routes                                                                              |
| routes.list[].name                |                    | Name of the route (required)                                                                |
| routes.list[].namespace           | project name       | Namespace of the route and of its service                                                   |
| routes.list[].labels, annotations | `{}`               | Additional labels and annotations                                                           |
| routes.list[].service             |                    | Name of the exposed service (required)                                                      |
| routes.list[].port                | `web`              | Port of the service (`web`, or `http` for Thanos Querier)                                   |
| routes.list[].host                | generated          | Hostname of the route                                                                       |
| routes.list[].termination         | `edge`             | TLS termination (`edge`, `reencrypt`, `passthrough`)                                        |
| routes.list[].tls                 | `{}`               | Additional fields of the tls block (`insecureEdgeTerminationPolicy` defaults to `Redirect`) |
| secrets.enabled                   | `false`            | Enable the creation of the secrets (sync-wave `1`)                                          |
| secrets.list                      | `[]`               | List of secrets                                                                             |
| secrets.list[].name               |                    | Name of the secret (required)                                                               |
| secrets.list[].namespace          | project name       | Namespace of the secret                                                                     |
| secrets.list[].type               | `Opaque`           | Type of the secret                                                                          |
| secrets.list[].labels             | `{}`               | Additional labels                                                                           |
| secrets.list[].data               |                    | Key/value pairs rendered as `stringData` (required without `externalSecret`)                |
| secrets.list[].externalSecret     | `{enabled: false}` | Source the secret from an external store (see [External secrets](#external-secrets))        |

### project values dictionary

| Key                          | Default                                             | Description                                                  |
| ---------------------------- | --------------------------------------------------- | ------------------------------------------------------------ |
| project.enabled              | `false`                                             | Enable the project sub-chart (namespace of the stacks)       |
| project.project.name         | `default-prometheus`                                | Namespace of the stacks, attached to the default pod network |
| project.project.display_name | `Prometheus`                                        | Display name of the namespace                                |
| project.project.description  | `Prometheus monitoring stacks configured by STARTX` | Description of the namespace                                 |

### operator values dictionary

| Key                                                | Default                                    | Description                                                                                                               |
| -------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| operator.enabled                                   | `false`                                    | Enable the operator sub-chart (subscription and operator group)                                                           |
| operator.subscription.name                         | `cluster-observability-operator`           | Name of the Subscription and of the package                                                                               |
| operator.subscription.namespace                    | `openshift-cluster-observability-operator` | Namespace of the operator                                                                                                 |
| operator.subscription.version                      | `v1.5.5`                                   | Version of the operator (used with `csv` for startingCSV)                                                                 |
| operator.subscription.operator.channel             | `stable`                                   | Channel of the subscription (`stable` follows the version validated for the OpenShift release, `fast` the latest version) |
| operator.subscription.operator.installPlanApproval | `Manual`                                   | Approval mode of the InstallPlans                                                                                         |
| operator.subscription.operator.source.name         | `redhat-operators`                         | Catalog source of the operator                                                                                            |
| operator.subscription.operator.config.infra        | `false`                                    | Run the operator on infra nodes                                                                                           |
| operator.operatorGroup.enabled                     | `true`                                     | Create the OperatorGroup of the namespace                                                                                 |
| operator.operatorGroup.target                      | `all-ns`                                   | OperatorGroup without target namespace (only install mode supported by the operator)                                      |

## Deploy with ArgoCD

### Deploy via ArgoCD Application

Deploy `cluster-prometheus` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-prometheus/examples/argocd/
oc apply -k .
```

| Application                   | Wave   | Enabled flags                                                                  | Destination                                |
| ----------------------------- | ------ | ------------------------------------------------------------------------------ | ------------------------------------------ |
| `cluster-prometheus-project`  | `"1"`  | `project.enabled: true`, `operatorNamespace.enabled: true`, all others `false` | `default-prometheus`                       |
| `cluster-prometheus-operator` | `"5"`  | `operator.enabled: true`, all others `false`                                   | `openshift-cluster-observability-operator` |
| `cluster-prometheus-app`      | `"10"` | `monitoringStacks.enabled: true`, all others `false`                           | `default-prometheus`                       |

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.
The `cluster-prometheus-app` Application only creates the `startx` stack: the scrape configuration of the workloads is specific to
each cluster, add `serviceMonitors`, `podMonitors`, `prometheusRules` and `alertmanagerConfigs` to its values and switch them to
`enabled: true`. The Subscription uses `installPlanApproval: Manual`: the `cluster-prometheus-app` Application stays out of sync
until the InstallPlan of the operator is approved (`SkipDryRunOnMissingResource=true` lets the sync start before the
`monitoring.rhobs` APIs exist).

## External secrets

The secrets of the `secrets` block (credentials of a remote write, of an alert receiver or of a scrape, web TLS certificates) can
come from an external store (Vault, AWS Secrets Manager...) through the [External Secrets Operator](https://external-secrets.io)
instead of the chart values. With `externalSecret.enabled: true`, the chart renders an `ExternalSecret` producing the Secret of the
same name, namespace and type, so the resource referencing it is unchanged. Without `externalSecret`, the chart renders the Secret
from `data`. Never commit a real credential in a values file.

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
secrets:
  enabled: true
  list:
    - name: remote-write
      externalSecret:
        enabled: true
        remoteRefs:
          username:
            key: ocp/prometheus/remote-write
            property: username
          password:
            key: ocp/prometheus/remote-write
            property: password
monitoringStacks:
  enabled: true
  list:
    - name: apps
      spec:
        prometheusConfig:
          remoteWrite:
            - url: https://metrics.example.com/api/v1/write
              basicAuth:
                username:
                  name: remote-write
                  key: username
                password:
                  name: remote-write
                  key: password
```

An `externalSecret` block accepts `secretStoreRef` and `refreshInterval` (defaults: `externalSecretDefaults`),
`remoteRefs` (map of secret key to ESO `remoteRef`) and the raw ESO fields `data`, `dataFrom` and `template`.
Rendering fails when no store is set or when no key source is provided.

## History

| Release  | Date       | Description            |
| -------- | ---------- | ---------------------- |
| 21.3.361 | 2026-11-17 | Initial chart creation |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |
| 21.3.412 | 2026-11-22 | full repository release: internal pins on the previous published version (ADR-0006) |
| 21.3.416 | 2026-11-23 | stable update: chart fixes (project, cluster-mongo, cluster-oadp, cluster-pipeline, cluster-machine, example-catalog); cluster-dvo accepts the grafana keys next to graphana, which keeps priority |

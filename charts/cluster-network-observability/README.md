# ![cluster-network-observability](https://helm-repository.readthedocs.io/en/latest/img/cluster-network-observability.svg "Cluster Chart : Network Observability") Cluster Chart : Network Observability
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--network--observability-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+network+observability+startx)

Configure the Network Observability operator and its FlowCollector to collect and visualize network flows.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

The Network Observability operator (`netobserv-operator`, channel `stable` of the `redhat-operators` catalog) is installed
in the `openshift-netobserv-operator` namespace and watches the whole cluster. It is driven by a single cluster-scoped
`FlowCollector` named `cluster` whose `spec.namespace` (default `netobserv`) receives the flow processor and the console
plugin. The operator creates this namespace when it does not exist and runs the eBPF agents in `netobserv-privileged`.
The cluster must use the OVN-Kubernetes network plugin.

- **Deployment model**: `Service` (operator default) runs the processor as a scalable Deployment, `Direct` pairs a processor
  DaemonSet with the agents through the host network (small clusters below 15 nodes) and `Kafka` buffers the flows in a Kafka
  topic (large clusters). The Kafka cluster and its topic must exist, see the
  [cluster-kafka](https://helm-repository.readthedocs.io/en/latest/charts/cluster-kafka) chart.
- **Loki**: the raw flows are stored in Loki only when `flowcollector.loki.enabled` is `true`. Deploy a dedicated LokiStack
  with the [cluster-loki](https://helm-repository.readthedocs.io/en/latest/charts/cluster-loki) chart using
  `lokistack.tenants.mode: openshift-network` (a LokiStack must not be shared with the OpenShift Logging stack). The operator
  manages itself the `netobserv-loki-writer` ClusterRoleBinding of the processor, no manual binding is needed. Non-admin users
  need the `netobserv-loki-reader` cluster role (and `netobserv-metrics-reader`) to see the flows of their projects.
  When the LokiStack lives in another namespace than the FlowCollector, enable the `lokiRbac` block so that the operator can
  read the LokiStack certificates.
- **eBPF features**: `DNSTracking`, `FlowRTT`, `PacketTranslation`, `IPSec` and `TLSTracking` run with the default
  capabilities while `PacketDrop`, `NetworkEvents` and `UDNMapping` require `flowcollector.agent.privileged: true`.
- **Infra nodes**: `flowcollector.infra_enabled` places the processor and the console plugin on the infra nodes. The eBPF
  agents are never constrained (they must run on every node) and the processor is not constrained in the `Direct` model.

### Sizing

Sampling (`flowcollector.agent.sampling`, default `50`) is the main cost driver: 1 means every packet is sampled, which
multiplies the CPU and memory usage of the agents and processors and the volume stored in Loki. Red Hat measured about
1.35 CPU and 16 GB of memory for a 25-node cluster with every feature enabled at sampling 50 (1.82 CPU and 22 GB at
sampling 1), and about 5.4 CPU and 63 GB for a 250-node cluster (12 CPU and 87 GB at sampling 1). Start from the default
and refine empirically. Each eBPF feature adds flows and labels, so enable only the needed ones. Clusters above 25 nodes
should use the `Kafka` model with more processor replicas (`consumerReplicas` 6 to 18) and a `1x.small` or `1x.medium`
LokiStack. Disabling Loki saves 20 to 65% of the memory footprint, the console plugin then relies on the Prometheus metrics
only (no raw flows table, no per-pod details).

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
helm show chart startx/cluster-network-observability
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics:

- Deploy the **FlowCollector CR** (`cluster`) with the `Service` deployment model, eBPF sampling 50, the console plugin
  enabled and Loki disabled (Prometheus metrics only)
- The operator subscription and namespace are managed separately via the `operator` and `project` sub-charts (both disabled by default)

```bash
# base configuration running default configuration
helm install cluster-network-observability startx/cluster-network-observability --set flowcollector.enabled=true
```

#### Full deployment with operator and project

Enable the operator subscription and project namespace alongside the FlowCollector CR:

```bash
helm install cluster-network-observability startx/cluster-network-observability \
  --set project.enabled=true \
  --set operator.enabled=true \
  --set flowcollector.enabled=true
```

#### Deployment with Loki storage

Store the raw flows in the `loki` LokiStack of the `netobserv` namespace (deployed with the `cluster-loki` chart and the
`openshift-network` tenant mode):

```bash
helm install cluster-network-observability startx/cluster-network-observability \
  --set flowcollector.enabled=true \
  --set flowcollector.loki.enabled=true \
  --set flowcollector.loki.lokiStack.name=loki \
  --set flowcollector.loki.lokiStack.namespace=netobserv
```

#### Other available values

- **startx** : Network Observability operator with full STARTX context, infra nodes placement (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-network-observability/values-startx.yaml))
- **startx_noinfra** : Network Observability operator with full STARTX context, without infra nodes placement (see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-network-observability/values-startx_noinfra.yaml))

```bash
helm install cluster-network-observability startx/cluster-network-observability -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-network-observability/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-network-observability` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-network-observability/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.
The operator adds a finalizer to the FlowCollector, ignored by the `cluster-network-observability-app` Application. Delete the
`-app` Application first (the operator removes the netobserv workloads), then the `-operator` and `-project` ones.

## Values dictionary

### context values dictionary

| Key                 | Default             | Description                                           |
| ------------------- | ------------------- | ----------------------------------------------------- |
| context.scope       | `myscope`           | Name of the global scope for this application         |
| context.cluster     | `default`           | Name of the cluster running this application          |
| context.environment | `myenv`             | Name of the environment (dev, factory, preprod, prod) |
| context.component   | `mycomponent`       | Component name of this application                    |
| context.app         | `default-netobserv` | Application name                                      |
| context.version     | `2.0.0`             | Version name of this application                      |

### flowcollector values dictionary

| Key                                          | Default     | Description                                                                                                                                   |
| -------------------------------------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| flowcollector.enabled                        | `false`     | Enable the creation of the FlowCollector CR (cluster-scoped, a single FlowCollector is allowed per cluster)                                  |
| flowcollector.hooked                         | `false`     | Deploy as a Helm/ArgoCD post-sync hook                                                                                                        |
| flowcollector.name                           | `cluster`   | Name of the FlowCollector (must be `cluster` for the operator to reconcile it)                                                                |
| flowcollector.namespace                      | `netobserv` | Namespace of the netobserv components (created by the operator, agents run in `<namespace>-privileged`, immutable)                            |
| flowcollector.deploymentModel                | `Service`   | Flow processing deployment model: `Service`, `Direct` (small clusters) or `Kafka` (large clusters, requires the `kafka` block)                |
| flowcollector.infra_enabled                  | `false`     | Place the processor (except in the `Direct` model) and the console plugin on the infra nodes                                                  |
| flowcollector.networkPolicy.enabled          | `true`      | Deploy the network policies isolating the netobserv components                                                                                |
| flowcollector.networkPolicy.additionalNamespaces | `[]`    | Additional namespaces allowed to connect to the netobserv namespace                                                                           |
| flowcollector.agent.sampling                 | `50`        | Sampling interval of the eBPF probe (1 samples every packet)                                                                                  |
| flowcollector.agent.privileged               | `false`     | Run the eBPF agents as privileged (required by `PacketDrop`, `NetworkEvents`, `UDNMapping` and SR-IOV interfaces)                             |
| flowcollector.agent.features                 | `[]`        | eBPF features: `PacketDrop`, `DNSTracking`, `FlowRTT`, `NetworkEvents`, `PacketTranslation`, `EbpfManager`, `UDNMapping`, `IPSec`, `TLSTracking` |
| flowcollector.agent.resources                | `{}`        | Compute resources of the eBPF agent container (raw map, empty keeps the operator defaults)                                                    |
| flowcollector.processor.logTypes             | `Flows`     | Record types to generate: `Flows`, `Conversations`, `EndedConversations` or `All`                                                             |
| flowcollector.processor.consumerReplicas     | `0`         | Processor replicas in the `Service` and `Kafka` models (0 keeps the operator default of 3)                                                    |
| flowcollector.processor.metrics.includeList  | `[]`        | Prometheus metrics to generate without the `netobserv_` prefix (raw list, empty keeps the operator default list)                             |
| flowcollector.processor.resources            | `{}`        | Compute resources of the processor container (raw map, empty keeps the operator defaults)                                                     |
| flowcollector.loki.enabled                   | `false`     | Store the raw flows in Loki                                                                                                                   |
| flowcollector.loki.mode                      | `LokiStack` | Loki installation mode: `LokiStack`, `Monolithic`, `Microservices` or `Manual`                                                                |
| flowcollector.loki.lokiStack.name            | `loki`      | Name of the LokiStack CR (tenants mode `openshift-network`)                                                                                   |
| flowcollector.loki.lokiStack.namespace       | `netobserv` | Namespace of the LokiStack CR (default is the flowcollector namespace)                                                                        |
| flowcollector.loki.extraSpec                 | `{}`        | Additional `spec.loki` fields appended as is (raw map): URLs of the other modes, timeouts, batch sizes                                        |
| flowcollector.consolePlugin.enabled          | `true`      | Deploy the Network Traffic console plugin                                                                                                     |
| flowcollector.consolePlugin.quickFilters     | `[]`        | Quick filter presets of the console plugin (raw list, empty keeps the operator defaults)                                                      |
| flowcollector.kafka                          | `{}`        | Kafka connection rendered as `spec.kafka` when the model is `Kafka` (address, topic, tls, sasl)                                               |
| flowcollector.exporters                      | `[]`        | Exporters receiving the enriched flows (raw list rendered as `spec.exporters`: `Kafka`, `IPFIX`, `OpenTelemetry`)                             |
| flowcollector.extraSpec                      | `{}`        | Additional FlowCollector spec fields appended as is (raw map), never repeat a field managed by the values above                               |

### flowMetrics values dictionary

| Key                 | Default | Description                                                                                             |
| ------------------- | ------- | ------------------------------------------------------------------------------------------------------- |
| flowMetrics.enabled | `false` | Enable the creation of the FlowMetric CRs                                                               |
| flowMetrics.hooked  | `false` | Deploy as Helm/ArgoCD post-sync hooks                                                                   |
| flowMetrics.list    | `[]`    | List of FlowMetric CRs: `name`, `namespace` (default is the flowcollector namespace) and raw `spec` text |

### lokiRbac values dictionary

| Key                        | Default                         | Description                                                                                                          |
| -------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| lokiRbac.enabled           | `false`                         | Create the `netobserv-secret-watcher` (LokiStack namespace) and `netobserv-secret-creator` (flowcollector namespace) RoleBindings |
| lokiRbac.operatorNamespace | `openshift-netobserv-operator`  | Namespace hosting the Network Observability operator                                                                 |
| lokiRbac.serviceAccount    | `netobserv-controller-manager`  | Service account of the operator controller manager                                                                   |

## History

| Release  | Date       | Description            |
| -------- | ---------- | ---------------------- |
| 21.3.321 | 2026-11-08 | Initial chart creation |

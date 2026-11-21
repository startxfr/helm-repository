# ![chaos-pipeline](https://helm-repository.readthedocs.io/en/latest/img/chaos-pipeline.svg "Chaos Chart : Pipeline") Chaos Chart : Pipeline
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--pipeline-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+pipeline+startx)

This helm chart deploys Tekton chaos testing pipelines on an Openshift or Kubernetes cluster.
The pipelines run [krkn](https://helm-repository.readthedocs.io/en/latest/charts/chaos-kraken) scenarios, one task per
scenario, gated by the [cerberus](https://helm-repository.readthedocs.io/en/latest/charts/chaos-cerberus) health signal:

- **chaos-infra**: chaos testing of the cluster infrastructure (platform pods, node pressure, node reboot).
- **chaos-application**: chaos testing of an application stack, chosen with the parameters of the run.

**Upstream project**: [krkn-chaos/krkn](https://github.com/krkn-chaos/krkn) version `v5.2.15`, image `quay.io/krkn-chaos/krkn`,
and [krkn-chaos/krkn-hub](https://github.com/krkn-chaos/krkn-hub) ([documentation](https://krkn-chaos.dev/docs/)).
The tasks use the `tekton.dev/v1` API.

Installing this chart runs nothing: it creates the tasks and the pipelines. A chaos run starts only when you create a
`PipelineRun`.

This chart is part of the [chaos startx helm chart series](https://helm-repository.readthedocs.io#chaos-helm-charts) focused on deploying various kind of chaos tools for cluster infrastructure or applications chaos-testing.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

- OpenShift Pipelines (see the [cluster-pipeline chart](https://helm-repository.readthedocs.io/en/latest/charts/cluster-pipeline)) or Tekton Pipelines with the `v1` API.
- Optional: a cerberus instance (see the [chaos-cerberus chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-cerberus)) whose `allowedNamespaces` contains the namespace of the pipelines.

Chaos scenarios destroy resources. Read each scenario before enabling it, start with pod scenarios, and never run node
scenarios on a cluster you cannot afford to lose.

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
helm show chart startx/chaos-pipeline
```

### 4. Install this component

```bash
# Install the pipeline project
helm install --set project.enabled=true chaos-pipeline-project startx/chaos-pipeline
# Deploy the tasks and the pipelines
helm install --set pipeline.enabled=true -n chaos-pipeline chaos-pipeline-instance startx/chaos-pipeline
# Start a run of the infrastructure pipeline
oc create -n chaos-pipeline -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-pipeline/examples/tekton/pipelinerun-infra.yaml
```

## Default values

Nothing is deployed by default. With `project.enabled=true` and `pipeline.enabled=true` the chart creates:

- 1 **project** named **chaos-pipeline**
- 1 **serviceaccount** named **chaos-pipeline**, with a chaos **clusterrole** and its binding
- 1 **configmap** named **chaos-pipeline-scenarios** with the enabled scenarios
- 3 **tasks**: **cerberus-check**, **krkn-run** and **krkn-hub-scenario**
- 2 **pipelines**: **chaos-infra** (3 platform pod scenarios enabled) and **chaos-application** (pod and container scenarios enabled)
- no **pipelinerun**

## Other available values

- **startx-project** : [values-startx-project.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-pipeline/values-startx-project.yaml) creates the `startx-chaos-pipeline` namespace
- **startx-deploy** : [values-startx-deploy.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-pipeline/values-startx-deploy.yaml) deploys the pipelines in `startx-chaos-pipeline`, gated by the cerberus of `startx-chaos-cerberus`

```bash
helm install chaos-pipeline-project startx/chaos-pipeline -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-pipeline/values-startx-project.yaml
helm install chaos-pipeline-deploy startx/chaos-pipeline -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-pipeline/values-startx-deploy.yaml
```

## Values dictionary

### context values dictionary

| Key                 | Default     | Description                                                                      |
| ------------------- | ----------- | -------------------------------------------------------------------------------- |
| context.scope       | companyname | Name of the global scope for this application (organizational tenant)            |
| context.cluster     | clustername | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev         | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | chaos       | Component name of this application (logical tenant)                              |
| context.app         | pipeline    | Application name (functional tenant, default use Chart name)                     |
| context.version     | 5.2.15      | Version name of this application (default use Chart appVersion)                  |

### chaos-pipeline values dictionary

| Key                                    | Default                                               | Description                                                                                                                                    |
| -------------------------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| project                                | {...}                                                 | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) |
| project.enabled                        | false                                                 | Enable creation of the namespace                                                                                                               |
| pipeline.enabled                       | false                                                 | Deploy the chaos tasks and pipelines                                                                                                           |
| pipeline.images.krkn.repository        | quay.io/krkn-chaos/krkn                               | krkn image repository (task `krkn-run`)                                                                                                        |
| pipeline.images.krkn.tag               | v5.2.15                                               | krkn image tag, used when no digest is set                                                                                                     |
| pipeline.images.krkn.digest            | sha256:43b3efda...                                    | krkn image digest, takes precedence over the tag                                                                                               |
| pipeline.images.hub.repository         | quay.io/krkn-chaos/krkn-hub                           | krkn-hub image repository (task `krkn-hub-scenario`)                                                                                           |
| pipeline.images.hub.pullPolicy         | Always                                                | krkn-hub image pull policy (rolling tags)                                                                                                      |
| pipeline.images.check.repository       | registry.access.redhat.com/ubi9/ubi-minimal           | Image with curl (task `cerberus-check`)                                                                                                        |
| pipeline.images.check.tag              | 9.9                                                   | Check image tag, used when no digest is set                                                                                                    |
| pipeline.images.check.digest           | sha256:08d4c70f...                                    | Check image digest, takes precedence over the tag                                                                                              |
| pipeline.privileged                    | false                                                 | Run the krkn steps as privileged and bind the service account to the `privileged` SCC                                                          |
| pipeline.privilegedWorkloads           | auto                                                  | Give the service account the `privileged` SCC in `privilegedNamespaces` (`auto`: when an enabled scenario needs it)                            |
| pipeline.privilegedNamespaces          | [default]                                             | Namespaces where krkn starts its privileged helper pods                                                                                        |
| pipeline.imageSignatureVerification    | true                                                  | Verify the signature of the workload images started by krkn                                                                                    |
| pipeline.resources                     | {}                                                    | Resources requests and limits of the krkn steps                                                                                                |
| pipeline.checkResources                | {}                                                    | Resources requests and limits of the cerberus-check step                                                                                       |
| pipeline.rbac.clusterAdmin             | false                                                 | Bind the service account to `cluster-admin` instead of the chaos ClusterRole of this chart                                                     |
| pipeline.rbac.extraRules               | []                                                    | Rules added to the chaos ClusterRole of this chart                                                                                             |
| pipeline.cloud.existingSecret          | ""                                                    | Name of an existing Secret exposed as environment variables (cloud credentials of the node scenarios)                                          |
| pipeline.cerberus.enabled              | true                                                  | Default of the `cerberus-enabled` pipeline parameter: gate the pipelines with the cerberus signal                                              |
| pipeline.cerberus.url                  | http://cerberus.chaos-cerberus.svc.cluster.local:8080 | Default of the `cerberus-url` pipeline parameter                                                                                               |
| pipeline.cerberus.timeout              | 300                                                   | Default of the `cerberus-timeout` pipeline parameter (seconds)                                                                                 |
| pipeline.infra.enabled                 | true                                                  | Deploy the `chaos-infra` pipeline                                                                                                              |
| pipeline.infra.healthCheckUrl          | ""                                                    | Default of the `health-check-url` parameter: HTTP endpoint checked by krkn before and after each scenario                                      |
| pipeline.infra.scenarios               | {...}                                                 | Scenarios of the `chaos-infra` pipeline (see below)                                                                                            |
| pipeline.application.enabled           | true                                                  | Deploy the `chaos-application` pipeline                                                                                                        |
| pipeline.application.targetNamespace   | ""                                                    | Default of the `target-namespace` parameter                                                                                                    |
| pipeline.application.labelSelector     | ""                                                    | Default of the `label-selector` parameter                                                                                                      |
| pipeline.application.healthCheckUrl    | ""                                                    | Default of the `health-check-url` parameter                                                                                                    |
| pipeline.application.scenarios         | {...}                                                 | Scenarios of the `chaos-application` pipeline (see below)                                                                                      |

### Scenarios

Each enabled scenario of `pipeline.infra.scenarios` and `pipeline.application.scenarios` becomes one task of its
pipeline. Tasks run one after the other, in alphabetical order of the scenario names: prefix them with a number.

| Key          | Default | Description                                                                              |
| ------------ | ------- | ---------------------------------------------------------------------------------------- |
| enabled      | false   | Add this scenario to the pipeline                                                        |
| engine       | core    | `core` runs the krkn image (task `krkn-run`), `hub` a krkn-hub image (`krkn-hub-scenario`) |
| type         |         | krkn scenario type, ex `pod_disruption_scenarios` (core engine)                          |
| content      |         | Scenario definition, in the krkn format of this type (core engine)                       |
| tag          | NAME    | krkn-hub image tag (hub engine)                                                          |
| digest       | ""      | krkn-hub image digest, takes precedence over the tag (hub engine)                        |
| env          | {}      | Environment variables of the krkn-hub scenario (hub engine)                              |
| waitDuration | 30      | Time to wait after the scenario, in seconds (core engine)                                |
| timeout      | 1h0m0s  | Timeout of the task                                                                      |

Scenarios shipped with the chart:

| Pipeline          | Name                      | Enabled | Effect                                                            |
| ----------------- | ------------------------- | ------- | ----------------------------------------------------------------- |
| chaos-infra       | 10-pods-monitoring        | yes     | Kill one prometheus pod of `openshift-monitoring`                 |
| chaos-infra       | 11-pods-ingress           | yes     | Kill one router pod of the default ingress controller             |
| chaos-infra       | 12-pods-apiserver         | yes     | Kill one pod of `openshift-apiserver`                             |
| chaos-infra       | 20-hog-cpu-worker         | no      | CPU pressure on one worker node                                   |
| chaos-infra       | 21-hog-memory-worker      | no      | Memory pressure on one worker node                                |
| chaos-infra       | 22-network-latency-worker | no      | Latency and packet loss on one worker node                        |
| chaos-infra       | 30-node-reboot-worker     | no      | Reboot one worker node (needs `cloud_type` and cloud credentials) |
| chaos-application | 10-pods                   | yes     | Kill one pod of the target application                            |
| chaos-application | 20-container              | yes     | Kill the main process of one container of the target application  |
| chaos-application | 30-service-disruption     | no      | Delete objects of the target namespace                            |

No scenario targets etcd or the control plane nodes. In the scenarios of `chaos-application`, `${TARGET_NAMESPACE}`
and `${LABEL_SELECTOR}` are replaced at run time by the `target-namespace` and `label-selector` parameters.

### Pipeline parameters

| Parameter        | Pipelines         | Description                                                           |
| ---------------- | ----------------- | --------------------------------------------------------------------- |
| cerberus-enabled | both              | `true` to gate the run with the cerberus signal                       |
| cerberus-url     | both              | URL of the cerberus signal                                            |
| cerberus-timeout | both              | Maximum time to wait for a healthy signal (seconds)                   |
| health-check-url | both              | HTTP endpoint checked by krkn before and after each scenario          |
| target-namespace | chaos-application | Namespace of the application under chaos                              |
| label-selector   | chaos-application | Label selector of the application pods (empty for every pod)          |

A run is: `cerberus-gate` (waits for a healthy signal, fails after the timeout) → one task per scenario (each one fails
the run when krkn, its health check or the cerberus signal fails) → `cerberus-final-check`, always executed.

### Access rights

The PipelineRuns must use the `chaos-pipeline` service account (`taskRunTemplate.serviceAccountName`). Its ClusterRole
covers the pod, container, application and node scenarios shipped with the chart. It is derived from the
[upstream RBAC documentation](https://krkn-chaos.dev/docs/krkn/rbac/) and may be too small for other scenario types: add
rules with `pipeline.rbac.extraRules`, or set `pipeline.rbac.clusterAdmin=true`. The default `pipeline` service account
of OpenShift Pipelines receives no right from this chart.
The `krkn-hub-scenario` task takes its image from a parameter: whoever can create a PipelineRun in this namespace can run
any image with the rights of the `chaos-pipeline` service account. Restrict who can create PipelineRuns there.
The node level scenarios (`hog_scenarios`, `network_chaos_scenarios`, `network_chaos_ng_scenarios`,
`pod_network_scenarios`, `time_scenarios`, `syn_flood_scenarios`, `storage_throttle_scenarios`) start privileged helper
pods on the target nodes, in the namespace given by the key `namespace` of the scenario (always `default` for the time
scenarios). When such a scenario is enabled, the chart binds the service account to the `privileged` SCC in the
namespaces of `pipeline.privilegedNamespaces` (`pipeline.privilegedWorkloads: auto`). The pod, container, application outage,
service disruption and pvc scenarios need no privileged SCC.

## Usage examples

### Example 1 — Infrastructure chaos gated by cerberus (default)

```bash
helm install chaos-cerberus startx/chaos-cerberus -n chaos-cerberus --create-namespace --set cerberus.enabled=true
helm install chaos-pipeline-project startx/chaos-pipeline --set project.enabled=true
helm install chaos-pipeline startx/chaos-pipeline -n chaos-pipeline --set pipeline.enabled=true
cat <<YAML | oc create -n chaos-pipeline -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: chaos-infra-
spec:
  pipelineRef:
    name: chaos-infra
  taskRunTemplate:
    serviceAccountName: chaos-pipeline
YAML
tkn pipelinerun logs -n chaos-pipeline --last -f
```

### Example 2 — Minimal application chaos, without cerberus

```bash
helm install chaos-pipeline startx/chaos-pipeline -n chaos-pipeline \
  --set pipeline.enabled=true --set pipeline.infra.enabled=false --set pipeline.cerberus.enabled=false
cat <<YAML | oc create -n chaos-pipeline -f -
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  generateName: chaos-application-
spec:
  pipelineRef:
    name: chaos-application
  taskRunTemplate:
    serviceAccountName: chaos-pipeline
  params:
    - name: target-namespace
      value: my-application
    - name: label-selector
      value: app=my-application
YAML
```

### Example 3 — Node pressure, node reboot and a krkn-hub scenario

```yaml
pipeline:
  enabled: true
  cloud:
    existingSecret: chaos-cloud-credentials
  infra:
    healthCheckUrl: https://console-openshift-console.apps.example.com/health
    scenarios:
      20-hog-cpu-worker:
        enabled: true
      22-network-latency-worker:
        enabled: true
      30-node-reboot-worker:
        enabled: true
      40-time-skew:
        enabled: true
        engine: hub
        tag: time-scenarios
        env:
          OBJECT_TYPE: node
          LABEL_SELECTOR: node-role.kubernetes.io/worker
          ACTION: skew_time
```

## ArgoCD deployment

`chaos-pipeline` follows the project/instance pattern: one AppProject, one Application creating the namespace (wave 1,
no finalizer) and one Application deploying the tasks and pipelines (wave 5). Syncing never starts a chaos run. The
examples are in [`examples/argocd/`](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-pipeline/examples/argocd).

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/chaos-pipeline
oc apply -k examples/argocd/
```

## History

| Release  | Date       | Description                                                                                                  |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------------ |
| 21.3.391 | 2026-11-21 | chaos charts: krkn v5.2.15, new chaos-pipeline chart, security fixes for litmus and monkey; breaking, see README migration notes |

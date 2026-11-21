# ![chaos-kraken](https://helm-repository.readthedocs.io/en/latest/img/chaos-kraken.svg "Chaos Chart : Kraken") Chaos Chart : Kraken
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--kraken-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+kraken+startx)

This helm chart runs krkn (formerly Kraken) chaos scenarios on an Openshift or Kubernetes cluster.
krkn is a chaos engine injecting failures in the cluster infrastructure (pods of the platform, nodes, network, time) and
in applications (pods, containers, network outage, storage), then checking that the platform recovers.

**Upstream project**: [krkn-chaos/krkn](https://github.com/krkn-chaos/krkn), a CNCF sandbox project, version `v5.2.15`,
image `quay.io/krkn-chaos/krkn` ([documentation](https://krkn-chaos.dev/docs/)).

| Period    | Repository             | Image                            |
| --------- | ---------------------- | -------------------------------- |
| 2020-2022 | cloud-bulldozer/kraken | quay.io/openshift-scale/kraken   |
| 2022      | chaos-kubox/krkn       | quay.io/chaos-kubox/krkn         |
| 2022-2024 | redhat-chaos/krkn      | quay.io/redhat-chaos/krkn        |
| 2024-     | krkn-chaos/krkn        | quay.io/krkn-chaos/krkn          |

A chaos run is a one-shot Job. Two engines are available:

- **core** (default): one Job runs the krkn image with the scenarios enabled in `kraken.scenarios`. Several scenarios per
  run, full krkn configuration, image pinned by tag and digest.
- **hub**: one Job per scenario enabled in `kraken.hub.scenarios`, each running a [krkn-hub](https://github.com/krkn-chaos/krkn-hub)
  image configured by environment variables. krkn-hub tags are rolling (rebuilt every week).

To run the scenarios from Tekton pipelines, see the [chaos-pipeline chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-pipeline).

This chart is part of the [chaos startx helm chart series](https://helm-repository.readthedocs.io#chaos-helm-charts) focused on deploying various kind of chaos tools for cluster infrastructure or applications chaos-testing.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

Chaos scenarios destroy resources. Read each scenario before enabling it, start with pod scenarios, and never run node,
network or time scenarios on a cluster you cannot afford to lose.

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
helm show chart startx/chaos-kraken
```

### 4. Install this component

```bash
# Install the kraken project
helm install --set project.enabled=true chaos-kraken-project startx/chaos-kraken
# Run one scenario: kill a prometheus pod of the cluster monitoring
helm install -n chaos-kraken chaos-kraken-run startx/chaos-kraken \
  --set kraken.enabled=true --set kraken.scenarios.pods-monitoring.enabled=true
# Follow the run
oc logs -n chaos-kraken -f job/kraken-test
```

The Job is immutable: uninstall the release (`helm uninstall chaos-kraken-run`) before running another set of scenarios.

## Default values

Nothing is deployed by default, and every scenario is disabled. With `project.enabled=true` and `kraken.enabled=true`
the chart creates:

- 1 **project** named **chaos-kraken**
- 1 **serviceaccount** named **kraken**, with a chaos **clusterrole** and its binding (local mode)
- 1 **configmap** with the krkn configuration and 1 **configmap** with the enabled scenarios
- 1 **job** named **kraken-test**, unprivileged, running the enabled scenarios against the cluster it runs in

## Other available values

- **startx-project** : [values-startx-project.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-kraken/values-startx-project.yaml) creates the `startx-chaos-kraken` namespace
- **startx-deploy** : [values-startx-deploy.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-kraken/values-startx-deploy.yaml) runs two pod scenarios (monitoring, ingress) with the core engine and the cerberus signal
- **startx-deploy-hub** : [values-startx-deploy-hub.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-kraken/values-startx-deploy-hub.yaml) runs the `pod-scenarios` krkn-hub image

```bash
helm install chaos-kraken-project startx/chaos-kraken -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-kraken/values-startx-project.yaml
helm install chaos-kraken-deploy startx/chaos-kraken -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-kraken/values-startx-deploy.yaml
```

## Values dictionary

### context values dictionary

| Key                 | Default     | Description                                                                      |
| ------------------- | ----------- | -------------------------------------------------------------------------------- |
| context.scope       | companyname | Name of the global scope for this application (organizational tenant)            |
| context.cluster     | clustername | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev         | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | chaos       | Component name of this application (logical tenant)                              |
| context.app         | kraken      | Application name (functional tenant, default use Chart name)                     |
| context.version     | 5.2.15      | Version name of this application (default use Chart appVersion)                  |

### chaos-kraken values dictionary

| Key                                   | Default                     | Description                                                                                                                                    |
| ------------------------------------- | --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| project                               | {...}                       | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) |
| project.enabled                       | false                       | Enable creation of the namespace                                                                                                               |
| kraken.enabled                        | false                       | Unleash the kraken ;)                                                                                                                          |
| kraken.engine                         | core                        | Engine used to run the chaos: `core` or `hub`                                                                                                  |
| kraken.image.repository               | quay.io/krkn-chaos/krkn     | Image repository (core engine)                                                                                                                 |
| kraken.image.tag                      | v5.2.15                     | Image tag, used when no digest is set                                                                                                          |
| kraken.image.digest                   | sha256:43b3efda...          | Image digest, takes precedence over the tag                                                                                                    |
| kraken.image.pullPolicy               | IfNotPresent                | Image pull policy                                                                                                                              |
| kraken.privileged                     | false                       | Run the krkn container as privileged and bind the service account to the `privileged` SCC                                                      |
| kraken.privilegedWorkloads            | auto                        | Give the service account the `privileged` SCC in `privilegedNamespaces` (`auto`: when an enabled scenario needs it)                            |
| kraken.privilegedNamespaces           | [default]                   | Namespaces where krkn starts its privileged helper pods                                                                                        |
| kraken.runAsUser                      | ""                          | User id of the container. Leave empty on OpenShift (assigned by the SCC), set it on plain Kubernetes (ex: 1001)                                |
| kraken.resources                      | {}                          | Resources requests and limits of the krkn container                                                                                            |
| kraken.rbac.clusterAdmin              | false                       | Bind the service account to `cluster-admin` instead of the chaos ClusterRole of this chart                                                     |
| kraken.rbac.extraRules                | []                          | Rules added to the chaos ClusterRole of this chart                                                                                             |
| kraken.job.name                       | kraken-test                 | Job name (prefix of the job names with the hub engine)                                                                                         |
| kraken.job.activeDeadlineSeconds      | 7200                        | Maximum duration of the job (seconds)                                                                                                          |
| kraken.job.suspend                    | false                       | Create the job suspended                                                                                                                       |
| kraken.job.ttlSecondsAfterFinished    | ""                          | Delete the finished job after this delay (seconds), kept when empty                                                                            |
| kraken.config.exitOnFailure           | false                       | Stop the run when a scenario fails                                                                                                             |
| kraken.config.waitDuration            | 60                          | Duration to wait between each scenario (seconds)                                                                                               |
| kraken.config.iterations              | 1                           | Number of times to execute the scenarios                                                                                                       |
| kraken.config.daemonMode              | false                       | Run the scenarios forever                                                                                                                      |
| kraken.config.autoRollback            | true                        | Roll back the changes of a scenario that failed                                                                                                |
| kraken.config.imageSignatureVerification | true                     | Verify the signature of the workload images started by krkn                                                                                    |
| kraken.config.reportFormats           | []                          | Formats of the report generated at the end of the run (`html`, `pdf`)                                                                          |
| kraken.config.resiliencyRunMode       | disabled                    | Resiliency score mode (`standalone`, `detailed` or `disabled`)                                                                                 |
| kraken.cerberus.enabled               | false                       | Check the [cerberus](https://helm-repository.readthedocs.io/en/latest/charts/chaos-cerberus) signal after each scenario                        |
| kraken.cerberus.url                   | ""                          | URL of the cerberus signal (ex: `http://cerberus.chaos-cerberus.svc.cluster.local:8080`)                                                       |
| kraken.cerberus.checkApplicationRoutes | false                      | Fail the run when a route watched by cerberus was unavailable                                                                                  |
| kraken.healthChecks.interval          | 2                           | Interval of the HTTP health checks run by krkn (seconds)                                                                                       |
| kraken.healthChecks.runDuring         | post                        | When to run the checks (`pre`, `during`, `post` or a list)                                                                                     |
| kraken.healthChecks.exitOnFailure     | false                       | Fail the run when a check fails                                                                                                                |
| kraken.healthChecks.endpoints         | []                          | Endpoints to check (`url`, `bearer_token`, `auth`)                                                                                             |
| kraken.objectStateChecks.runDuring    | []                          | When to run the object condition checks (list of `pre`, `during`, `post`). Disabled when empty                                                 |
| kraken.objectStateChecks.exitOnFailure | false                      | Fail the run when a check fails                                                                                                                |
| kraken.objectStateChecks.checks       | []                          | Object checks (`name`, `kind`, `object_name`, `namespace`, `label_selector`, `condition`)                                                      |
| kraken.monitoring.enableAlerts        | false                       | Evaluate the krkn alert profile during the run                                                                                                 |
| kraken.monitoring.checkCriticalAlerts | false                       | Fail the run when a critical alert is firing after the chaos                                                                                   |
| kraken.monitoring.enableMetrics       | false                       | Collect the metrics of the krkn metrics profile                                                                                                |
| kraken.monitoring.prometheusUrl       | ""                          | Prometheus URL (discovered on OpenShift, mandatory on plain Kubernetes)                                                                        |
| kraken.monitoring.prometheusToken     | ""                          | Prometheus bearer token (discovered on OpenShift, mandatory on plain Kubernetes)                                                               |
| kraken.cloud.existingSecret           | ""                          | Name of an existing Secret exposed as environment variables (cloud credentials of the node and zone scenarios)                                 |
| kraken.scenarios                      | {...}                       | Scenarios of the core engine, run in alphabetical order of their name (see below)                                                              |
| kraken.scenarios.NAME.enabled         | false                       | Run this scenario                                                                                                                              |
| kraken.scenarios.NAME.type            |                             | krkn scenario type (`pod_disruption_scenarios`, `hog_scenarios`, `node_scenarios`...)                                                          |
| kraken.scenarios.NAME.content         |                             | Scenario definition, in the krkn format of this type                                                                                           |
| kraken.scenarios.NAME.file            |                             | Scenario file shipped in the krkn image, used instead of `content` (ex: `scenarios/openshift/prom_kill.yml`)                                   |
| kraken.hub.repository                 | quay.io/krkn-chaos/krkn-hub | Image repository of the krkn-hub images                                                                                                        |
| kraken.hub.pullPolicy                 | Always                      | Image pull policy of the krkn-hub images                                                                                                       |
| kraken.hub.scenarios.NAME.enabled     | false                       | Run this krkn-hub scenario                                                                                                                     |
| kraken.hub.scenarios.NAME.tag         | NAME                        | krkn-hub image tag                                                                                                                             |
| kraken.hub.scenarios.NAME.digest      | ""                          | Image digest, takes precedence over the tag                                                                                                    |
| kraken.hub.scenarios.NAME.env         | {}                          | Environment variables of the scenario, documented in the krkn-hub repository                                                                   |
| kraken.kubeconfig.mode                | local                       | Connection mode to the cluster under chaos: `local` (in-cluster service account), `token` or `file` (stored in a Secret)                       |
| kraken.kubeconfig.token.server        | https://localhost:6443      | If mode is token, the server URL of the target cluster API                                                                                     |
| kraken.kubeconfig.token.token         | sha256~XXX                  | If mode is token, the bearer token. Its rights must cover the scenarios you run                                                                |
| kraken.kubeconfig.token.ca            | ""                          | If mode is token, PEM content of the certificate authority of the target cluster API                                                           |
| kraken.kubeconfig.token.insecure      | false                       | If mode is token and no ca is given, skip the TLS verification                                                                                 |
| kraken.kubeconfig.file                | ""                          | If mode is file, a full kubeconfig content                                                                                                     |

### Scenarios shipped with the chart

All are disabled by default. Enable one with `--set kraken.scenarios.<name>.enabled=true` and adapt its `content`.

| Name                           | krkn type                     | Effect                                                              | Blast radius   |
| ------------------------------ | ----------------------------- | ------------------------------------------------------------------- | -------------- |
| pods-monitoring                | pod_disruption_scenarios      | Kill one prometheus pod of `openshift-monitoring`                   | platform pods  |
| pods-ingress                   | pod_disruption_scenarios      | Kill one router pod of the default ingress controller               | platform pods  |
| pods-apiserver                 | pod_disruption_scenarios      | Kill one pod of `openshift-apiserver`                               | platform pods  |
| pods-network                   | pod_disruption_scenarios      | Kill one `ovnkube-node` pod                                         | platform pods  |
| pods-application               | pod_disruption_scenarios      | Kill pods of an application namespace                               | application    |
| container-application          | container_scenarios           | Kill the main process of an application container                   | application    |
| outage-application             | application_outages_scenarios | Block the network traffic of an application                         | application    |
| service-disruption-application | service_disruption_scenarios  | Delete objects of the namespaces matching a pattern                 | application    |
| pvc-fill-application           | pvc_scenarios                 | Fill a persistent volume of an application                          | application    |
| hog-cpu-worker                 | hog_scenarios                 | CPU pressure on one worker node                                     | node           |
| hog-memory-worker              | hog_scenarios                 | Memory pressure on one worker node                                  | node           |
| network-latency-worker         | network_chaos_ng_scenarios    | Latency and packet loss on one worker node                          | node           |
| time-skew-worker               | time_scenarios                | Skew the clock of one worker node                                   | node           |
| node-reboot-worker             | node_scenarios                | Reboot one worker node (needs `cloud_type` and cloud credentials)   | node           |

No scenario targets etcd or the control plane nodes. The krkn image also ships the upstream scenarios
(`scenarios/openshift/*`, `scenarios/kube/*`): use them with the `file` key.

### Access rights

In `local` mode the `kraken` service account gets a ClusterRole covering the pod, container, application and node
scenarios above. It is derived from the [upstream RBAC documentation](https://krkn-chaos.dev/docs/krkn/rbac/) and may be
too small for other scenario types: add rules with `kraken.rbac.extraRules`, or set `kraken.rbac.clusterAdmin=true`.
The node level scenarios (`hog_scenarios`, `network_chaos_scenarios`, `network_chaos_ng_scenarios`,
`pod_network_scenarios`, `time_scenarios`, `syn_flood_scenarios`, `storage_throttle_scenarios`) start privileged helper
pods on the target nodes, in the namespace given by the key `namespace` of the scenario (always `default` for the time
scenarios). When such a scenario is enabled, the chart binds the service account to the `privileged` SCC in the
namespaces of `kraken.privilegedNamespaces` (`kraken.privilegedWorkloads: auto`). The pod, container, application outage,
service disruption and pvc scenarios need no privileged SCC.

## Migration from releases before 21.3.391

This release follows the upstream changes of krkn and is not compatible with the previous values.

- `kraken.version` is replaced by `kraken.image.tag` and `kraken.image.digest`; the image moved from `quay.io/redhat-chaos/krkn` to `quay.io/krkn-chaos/krkn`.
- `kraken.mode` is removed. The job mode is the `core` engine. The pipeline mode moved to the [chaos-pipeline chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-pipeline), which no longer starts a run at install time.
- `kraken.job.prefix` becomes `kraken.job.name`; `kraken.cerberusUrl` becomes `kraken.cerberus.url`, and cerberus is disabled by default.
- `kraken.aws.*` is replaced by `kraken.cloud.existingSecret`: the chart no longer stores cloud credentials.
- `kraken.kubeconfig.mode` defaults to `local`. In `token` and `file` modes the kubeconfig is stored in a Secret and TLS is verified unless `kraken.kubeconfig.token.insecure` is set.
- The scenario ConfigMaps tied to a specific environment (cloud identifiers, application names, provider scripts) are removed. Scenarios are declared in `kraken.scenarios`.
- The custom `privileged-kraken` SCC, the Service and the Route are removed. The `pipeline` service account no longer receives any right.
- The krkn configuration follows the current upstream format: the litmus, kube-burner and dashboard settings are gone.

## Usage examples

### Example 1 — Platform pod chaos with the core engine (default)

```bash
helm install chaos-kraken-project startx/chaos-kraken --set project.enabled=true
helm install -n chaos-kraken chaos-kraken-run startx/chaos-kraken \
  --set kraken.enabled=true \
  --set kraken.scenarios.pods-monitoring.enabled=true \
  --set kraken.scenarios.pods-ingress.enabled=true
oc logs -n chaos-kraken -f job/kraken-test
```

### Example 2 — Minimal run with a krkn-hub image

One Job per scenario, configured by environment variables.

```yaml
kraken:
  enabled: true
  engine: hub
  hub:
    scenarios:
      pod-scenarios:
        enabled: true
        env:
          NAMESPACE: "^my-application$"
          POD_LABEL: app=my-application
          DISRUPTION_COUNT: "1"
```

### Example 3 — Application chaos gated by cerberus and krkn health checks

```yaml
kraken:
  enabled: true
  config:
    exitOnFailure: true
    waitDuration: 30
  cerberus:
    enabled: true
    url: http://cerberus.chaos-cerberus.svc.cluster.local:8080
  healthChecks:
    runDuring: [pre, post]
    exitOnFailure: true
    endpoints:
      - url: https://myapp.apps.example.com/health
  objectStateChecks:
    runDuring: [post]
    exitOnFailure: true
    checks:
      - name: myapp-available
        kind: Deployment
        object_name: ".*"
        namespace: my-application
        label_selector: ""
        condition: {type: Available, status: "True"}
  scenarios:
    pods-application:
      enabled: true
      content:
        - id: kill-pods
          config:
            namespace_pattern: ^my-application$
            label_selector: app=my-application
            kill: 1
            krkn_pod_recovery_time: 120
    outage-application:
      enabled: true
      content:
        application_outage:
          duration: 60
          namespace: my-application
          pod_selector: {app: my-application}
          block: [Ingress]
```

### Example 4 — Node reboot on a cloud provider

```bash
oc create secret generic kraken-cloud -n chaos-kraken \
  --from-literal=AWS_ACCESS_KEY_ID=... --from-literal=AWS_SECRET_ACCESS_KEY=... --from-literal=AWS_DEFAULT_REGION=eu-west-3
helm install -n chaos-kraken chaos-kraken-run startx/chaos-kraken \
  --set kraken.enabled=true --set kraken.cloud.existingSecret=kraken-cloud \
  --set kraken.scenarios.node-reboot-worker.enabled=true
```

## ArgoCD deployment

`chaos-kraken` follows the project/instance pattern: one AppProject, one Application creating the namespace (wave 1,
no finalizer) and one Application running the chaos Job (wave 5). The instance Application has **no automated sync**:
every sync starts a chaos run. The examples are in [`examples/argocd/`](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-kraken/examples/argocd).

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/chaos-kraken
oc apply -k examples/argocd/
```

## History

| Release  | Date       | Description                                                                                                                      |
| -------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.111 | 2026-06-22 | fix mountPath: use /home/krkn instead of /root for kraken image paths |
| 21.3.113 | 2026-06-22 | fix: add missing elastic and telemetry sections to kraken-config-all |
| 21.3.115 | 2026-06-22 | fix: replace plugin_scenarios with pod_disruption_scenarios for krkn v5 compatibility |
| 21.3.117 | 2026-06-22 | fix scenarios: correct pod labels for monitoring/machines, rewrite machines to krkn v5 format |
| 21.3.121 | 2026-06-22 | split logging scenario into loki and elastic variants |
| 21.3.123 | 2026-06-22 | migrate kraken-scenarios-all to individual kraken-scenario-<name> ConfigMaps |
| 21.3.125 | 2026-06-22 | split scenario and chaos-config ConfigMaps into grouped template files by category |
| 21.3.127 | 2026-06-22 | tuning scenarios timings |
| 21.3.128 | 2026-06-22 | reduce wait_duration 60s and monitoring kill |
| 21.3.130 | 2026-06-22 | add ingress, OVN and kube-apiserver chaos scenarios |
| 21.3.131 | 2026-06-22 | fix container scenarios syntax and add ingress OVN kube-apiserver scenarios |
| 21.3.134 | 2026-06-22 | improve monitoring apiserver machines podmonkey and app-outage scenarios |
| 21.3.203 | 2026-06-24 | Improve chaos-kraken options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.313 | 2026-11-04 | Add cluster-unifai and cluster-qdrant, align all charts to 21.3.313 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.373 | 2026-11-19 | align inter-chart dependency pins |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.391 | 2026-11-21 | chaos charts: krkn v5.2.15, new chaos-pipeline chart, security fixes for litmus and monkey; breaking, see README migration notes |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |

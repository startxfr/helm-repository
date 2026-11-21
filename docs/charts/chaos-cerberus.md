# ![chaos-cerberus](https://helm-repository.readthedocs.io/en/latest/img/chaos-cerberus.svg "Chaos Chart : Cerberus") Chaos Chart : Cerberus
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--cerberus-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+cerberus+startx)

This helm chart deploys Cerberus on an Openshift or Kubernetes cluster.
Cerberus is a watchdog that monitors the health of a cluster (nodes, cluster operators, critical namespaces, routes) and
publishes a go/no-go signal (`True` or `False`) on an HTTP endpoint. Chaos tools such as [krkn](https://helm-repository.readthedocs.io/en/latest/charts/chaos-kraken)
and the [chaos pipelines](https://helm-repository.readthedocs.io/en/latest/charts/chaos-pipeline) read this signal before and after injecting failures.

**Upstream project**: [krkn-chaos/cerberus](https://github.com/krkn-chaos/cerberus) (formerly `openshift-scale/cerberus`, then `chaos-kubox` and `redhat-chaos`),
version `1.0.4`, image `quay.io/krkn-chaos/cerberus` ([documentation](https://krkn-chaos.dev/docs/cerberus/)).
The project is in maintenance mode and publishes no versioned image tag: this chart pins the image by digest.
Cerberus is optional: krkn has its own health checks, and upstream warns that a Cerberus running inside the cluster it
watches can itself be disrupted by a chaos scenario.

This chart is part of the [chaos startx helm chart series](https://helm-repository.readthedocs.io#chaos-helm-charts) focused on deploying various kind of chaos tools for cluster infrastructure or applications chaos-testing.

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
helm install --set project.enabled=true chaos-cerberus-project startx/chaos-cerberus
# Deploy the cerberus instance
helm install --set cerberus.enabled=true -n chaos-cerberus chaos-cerberus-instance startx/chaos-cerberus
```

## Default values

Nothing is deployed by default. With `project.enabled=true` and `cerberus.enabled=true` the chart creates:

- 1 **project** named **chaos-cerberus**
- 1 **serviceaccount** named **cerberus**, with a read-only **clusterrole** and its binding (local mode)
- 1 **configmap** with the cerberus configuration
- 1 **networkpolicy** allowing the pods of the `chaos-kraken` and `chaos-pipeline` namespaces to read the signal
- 1 **deployment** named **cerberus**, unprivileged, watching the cluster it runs in
- 1 **service** named **cerberus** (port 8080)

## Other available values

- **startx-deploy** : [values-startx-deploy.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-cerberus/values-startx-deploy.yaml) deploys cerberus in the `startx-chaos-cerberus` namespace, exposed by a route
- **startx-project** : [values-startx-project.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-cerberus/values-startx-project.yaml) creates the `startx-chaos-cerberus` namespace

```bash
helm install chaos-cerberus-project startx/chaos-cerberus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-cerberus/values-startx-project.yaml
helm install chaos-cerberus-deploy startx/chaos-cerberus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-cerberus/values-startx-deploy.yaml
```

## Values dictionary

### context values dictionary

| Key                 | Default     | Description                                                                      |
| ------------------- | ----------- | -------------------------------------------------------------------------------- |
| context.scope       | companyname | Name of the global scope for this application (organizational tenant)            |
| context.cluster     | clustername | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev         | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | chaos       | Component name of this application (logical tenant)                              |
| context.app         | cerberus    | Application name (functional tenant, default use Chart name)                     |
| context.version     | 1.0.4       | Version name of this application (default use Chart appVersion)                  |

### chaos-cerberus values dictionary

| Key                                      | Default                               | Description                                                                                                                                                                                              |
| ---------------------------------------- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project                                  | {...}                                 | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project)                                                           |
| project.enabled                          | false                                 | Enable creation of the namespace                                                                                                                                                                         |
| cerberus.enabled                         | false                                 | Enable deploying the cerberus watchdog                                                                                                                                                                   |
| cerberus.image.repository                | quay.io/krkn-chaos/cerberus           | Image repository                                                                                                                                                                                         |
| cerberus.image.tag                       | latest                                | Image tag, used when no digest is set                                                                                                                                                                    |
| cerberus.image.digest                    | sha256:59abd5d1...                    | Image digest, takes precedence over the tag                                                                                                                                                              |
| cerberus.image.pullPolicy                | IfNotPresent                          | Image pull policy                                                                                                                                                                                        |
| cerberus.privileged                      | false                                 | Run the container as privileged and bind the service account to the `privileged` SCC                                                                                                                     |
| cerberus.resources                       | {}                                    | Resources requests and limits of the container                                                                                                                                                           |
| cerberus.expose                          | false                                 | Expose the signal outside of the cluster (route based)                                                                                                                                                   |
| cerberus.allowedNamespaces               | [chaos-kraken, chaos-pipeline]        | Namespaces allowed to read the signal (networkpolicy)                                                                                                                                                    |
| cerberus.distribution                    | openshift                             | Kind of cluster watched (`openshift` or `kubernetes`)                                                                                                                                                    |
| cerberus.isDaemon                        | true                                  | Run as a daemon (infinite loop instead of `iterations` checks)                                                                                                                                           |
| cerberus.iterations                      | 25                                    | Number of iterations when cerberus is not a daemon                                                                                                                                                       |
| cerberus.sleep_time                      | 15                                    | Sleep time between 2 checks (seconds)                                                                                                                                                                    |
| cerberus.timeout                         | 10                                    | Timeout of a single check (seconds)                                                                                                                                                                      |
| cerberus.watch_nodes                     | true                                  | Watch nodes health as part of the global health signal                                                                                                                                                   |
| cerberus.watch_cluster_operators         | true                                  | Watch cluster operators health as part of the global health signal                                                                                                                                       |
| cerberus.watch_terminating_namespaces    | true                                  | Watch terminating namespaces as part of the global health signal                                                                                                                                         |
| cerberus.watch_master_schedulable        | true                                  | Watch for schedulable control plane nodes                                                                                                                                                                |
| cerberus.controlPlaneLabel               | node-role.kubernetes.io/control-plane | Label identifying the control plane nodes                                                                                                                                                                |
| cerberus.watch_url_routes                | []                                    | Url list of endpoints to watch as part of the global healthcheck (double array)                                                                                                                          |
| cerberus.watch_namespaces                | [...]                                 | List of namespaces to watch (supports regex patterns). Defaults to the critical OpenShift namespaces                                                                                                     |
| cerberus.watch_namespaces_ignore_pattern | ["^installer.*"]                      | Regex patterns for namespaces to exclude from watching                                                                                                                                                   |
| cerberus.custom_checks                   | []                                    | List of custom check scripts to run (path relative to the working directory). Example: ["custom/my_check.py"]                                                                                            |
| cerberus.customCheckScripts              | {}                                    | Custom check scripts copied in the `custom` directory (file name: python content exposing a `main()` function)                                                                                           |
| cerberus.prometheus.enabled              | false                                 | Enable the prometheus checks (API server latency, etcd leader changes). In local mode, binds the service account to `cluster-monitoring-view`                                                            |
| cerberus.prometheus.url                  | https://thanos-querier...:9091        | Prometheus or thanos querier URL                                                                                                                                                                         |
| cerberus.prometheus.token                | ""                                    | Bearer token used to query prometheus (in local mode, defaults to the service account token)                                                                                                             |
| cerberus.runAsUser                       | ""                                    | User id of the container. Leave empty on OpenShift (assigned by the SCC), set it on plain Kubernetes (ex: 1001)                                                                                          |
| cerberus.kubeconfig.mode                 | local                                 | Connection mode to the watched cluster: `local` (in-cluster service account, read-only), `token` or `file` (stored in a Secret)                                                                          |
| cerberus.kubeconfig.token.server         | https://localhost:6443                | If mode is token, the server URL of the target cluster API                                                                                                                                               |
| cerberus.kubeconfig.token.token          | sha256~XXX                            | If mode is token, the bearer token. A read-only access (`cluster-reader`) is enough                                                                                                                      |
| cerberus.kubeconfig.token.ca             | ""                                    | If mode is token, PEM content of the certificate authority of the target cluster API                                                                                                                     |
| cerberus.kubeconfig.token.insecure       | false                                 | If mode is token and no ca is given, skip the TLS verification                                                                                                                                           |
| cerberus.kubeconfig.file                 | ""                                    | If mode is file, a full kubeconfig content                                                                                                                                                               |

## Migration from releases before 21.3.391

- `cerberus.version` is replaced by `cerberus.image.tag` and `cerberus.image.digest`; the image moved from `quay.io/redhat-chaos/cerberus` to `quay.io/krkn-chaos/cerberus`.
- `cerberus.kraken_allowed` and `cerberus.kraken_ns` are replaced by the `cerberus.allowedNamespaces` list. The policy opening the signal to every pod is gone.
- `cerberus.kubeconfig.mode` defaults to `local`; `cerberus.expose` defaults to `false`.
- In `token` and `file` modes the kubeconfig is stored in a Secret, and TLS is verified unless `cerberus.kubeconfig.token.insecure` is set.
- The custom `privileged-cerberus` SCC is removed: the container runs unprivileged (`cerberus.privileged=true` restores a privileged container).
- The `startx_check.py` script is no longer shipped; use `cerberus.customCheckScripts`.
- Custom checks are declared in `cerberus.customCheckScripts` and referenced as `custom/<file>.py`.
- The `ClusterRole` and `ClusterRoleBinding` of the local mode are suffixed with the namespace.

## Usage examples

### Example 1 — Watch the local cluster (default)

Cerberus watches the cluster it runs in, with its own service account and a read-only role.

```bash
helm install chaos-cerberus-project startx/chaos-cerberus --set project.enabled=true
helm install chaos-cerberus startx/chaos-cerberus -n chaos-cerberus --set cerberus.enabled=true
# Read the signal from an allowed namespace
curl http://cerberus.chaos-cerberus.svc.cluster.local:8080
```

### Example 2 — Minimal watchdog for a Kubernetes cluster

Only the nodes and two namespaces are watched.

```yaml
cerberus:
  enabled: true
  distribution: kubernetes
  # the image has no default user: required outside of OpenShift
  runAsUser: 1001
  watch_cluster_operators: false
  watch_master_schedulable: false
  watch_namespaces:
    - kube-system
    - ingress-nginx
```

### Example 3 — Watch a remote cluster, application routes and a custom check

```yaml
cerberus:
  enabled: true
  expose: true
  allowedNamespaces:
    - my-chaos-namespace
  watch_url_routes:
    - ["https://myapp.apps.example.com/health"]
    - ["https://api.example.com/ready", "Bearer mytoken"]
  custom_checks:
    - custom/ready_nodes.py
  customCheckScripts:
    ready_nodes.py: |
      import subprocess
      def main():
          out = subprocess.check_output("kubectl get nodes --no-headers | grep -c ' Ready '", shell=True, universal_newlines=True)
          return int(out.strip()) >= 3
  kubeconfig:
    mode: token
    token:
      server: https://api.example.com:6443
      token: sha256~my-read-only-token
      ca: |
        -----BEGIN CERTIFICATE-----
        ...
        -----END CERTIFICATE-----
```

A read-only token can be created on the remote cluster with:

```bash
oc create serviceaccount cerberus-monitor -n chaos-cerberus
oc adm policy add-cluster-role-to-user cluster-reader -z cerberus-monitor -n chaos-cerberus
oc create token cerberus-monitor -n chaos-cerberus --duration=8760h
```

## ArgoCD deployment

`chaos-cerberus` follows the project/instance pattern: one AppProject, one Application creating the namespace (wave 1,
no finalizer) and one Application deploying cerberus (wave 5). The examples are in [`examples/argocd/`](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-cerberus/examples/argocd).

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/chaos-cerberus
oc apply -k examples/argocd/
```

In local mode the chart creates the `ClusterRole` and `ClusterRoleBinding` of the `cerberus` service account: the
AppProject must allow these two cluster kinds.

## History

| Release  | Date       | Description                                                                                                                        |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.110 | 2026-06-22 | improve cerberus config: fix kraken version ref, networkpolicy scope, add upstream fields, local mode schema, ArgoCD examples |
| 21.3.111 | 2026-06-22 | fix local mode: generate kubeconfig from SA token at startup (tokenFile unsupported by Python k8s client) |
| 21.3.112 | 2026-06-22 | fix local mode ClusterRole: add nodes/status, CSR, routes, serviceaccounts/token permissions |
| 21.3.203 | 2026-06-24 | Improve chaos-cerberus options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.313 | 2026-11-04 | Add cluster-unifai and cluster-qdrant, align all charts to 21.3.313 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.391 | 2026-11-21 | chaos charts: krkn v5.2.15, new chaos-pipeline chart, security fixes for litmus and monkey; breaking, see README migration notes |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |

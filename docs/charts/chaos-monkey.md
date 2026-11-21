# ![chaos-monkey](https://helm-repository.readthedocs.io/en/latest/img/chaos-monkey.svg "Chaos Chart : Monkeys") Chaos Chart : ChaosMonkeys
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--monkey-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+monkey+startx)

This helm chart is used to deploy [kube-monkey](https://github.com/asobti/kube-monkey) on an Openshift or Kubernetes cluster.
Kube-monkey randomly terminates pods, during a daily time window, in the workloads that opted in with labels.

**Upstream project** : [asobti/kube-monkey](https://github.com/asobti/kube-monkey), deployed with the upstream helm chart [`kube-monkey`](https://asobti.github.io/kube-monkey/charts/repo) version `1.5.2` ; image `ayushsobti/kube-monkey:v0.5.2`.

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
helm show chart startx/chaos-monkey
```

### 4. Install this component

```bash
# Create the chaos-monkey namespace
helm install chaos-monkey-project startx/chaos-monkey --set project.enabled=true
# Deploy the monkey instance
helm install chaos-monkey-instance startx/chaos-monkey --set monkey.enabled=true -n chaos-monkey
```

## Default values

The default [values.yaml](https://github.com/startxfr/helm-repository/blob/master/charts/chaos-monkey/values.yaml) deploys
nothing : each part is switched on by its `enabled` key.

- `project.enabled=true` : 1 **namespace** `chaos-monkey` (see the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project))
- `monkey.enabled=true` : the kube-monkey deployment, its configuration and its service account, with 1 **ClusterRole** and 1 **ClusterRoleBinding** from the upstream chart (read the workloads and the namespaces, delete pods : nothing else)
- `monkey.privileged=true` : 1 **SecurityContextConstraints** `privileged-monkey` with its Role and RoleBinding, for the kube-monkey service account

A workload is terminated only if it opted in (see the last usage example).

**Migration from 21.3.390 and earlier** (breaking changes) :

- the ClusterRoleBinding `kube-monkey-edit-rb`, which gave the cluster role `edit` on the whole cluster to the
  kube-monkey and `default` service accounts of the namespace, is removed. Kube-monkey keeps the rights of the upstream
  ClusterRole. Anything else that relied on this binding (a workload running with the `default` service account of the
  namespace) needs its own RoleBinding.
- the privileged SecurityContextConstraints `privileged-monkey` is no longer created by default : kube-monkey runs with
  the restricted one. Set `monkey.privileged=true` to get it back.
- the log directory is now an `emptyDir` volume (`monkey.additionalVolumes`), writable by an arbitrary user.

| Key                                 | Default                    | Description                                                                                                                 |
| ----------------------------------- | -------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| context.scope                       | companyname                | Name of the global scope for this application (organizational tenant)                                                       |
| context.cluster                     | clustername                | Name of the cluster running this application (platform tenant)                                                              |
| context.environment                 | dev                        | Name of the environment for this application (ex: dev, factory, preprod or prod)                                            |
| context.component                   | chaos                      | Component name of this application (logical tenant)                                                                         |
| context.app                         | kube-monkey                | Application name (functional tenant, default use Chart name)                                                                |
| context.version                     | 1.5.2                      | Version name of this application (default use Chart appVersion)                                                             |
| project                             | {...}                      | Values of the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project), which creates the namespace |
| project.enabled                     | false                      | Create the namespace                                                                                                        |
| project.project.name                | chaos-monkey               | Name of the namespace ; also the namespace of the resources created by this chart                                           |
| monkey                              | {...}                      | Values of the upstream [kube-monkey chart](https://github.com/asobti/kube-monkey/tree/master/helm/kubemonkey), passed as is |
| monkey.enabled                      | false                      | Deploy kube-monkey with the ClusterRole of the upstream chart                                                               |
| monkey.privileged                   | false                      | Grant the privileged SecurityContextConstraints `privileged-monkey` to the kube-monkey service account                      |
| monkey.fullnameOverride             | example-monkey             | Name of the deployment and of its service account ; the SecurityContextConstraints follows it                               |
| monkey.config.dryRun                | false                      | `true` logs the terminations without doing them                                                                             |
| monkey.config.runHour               | 8                          | Hour of the day when the terminations of the day are scheduled                                                              |
| monkey.config.startHour / endHour   | 10 / 16                    | Time window of the terminations                                                                                             |
| monkey.config.timeZone              | Europe/Paris               | Time zone of the three hours above                                                                                          |
| monkey.config.whitelistedNamespaces | default, demo-*, example-* | Namespaces where pods can be terminated                                                                                     |
| monkey.config.blacklistedNamespaces | kube-system, openshift-*   | Namespaces never touched                                                                                                    |

## Other available values

- **startx-project** : [values-startx-project.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-monkey/values-startx-project.yaml), namespace `startx-chaos-monkey` only
- **startx-deploy** : [values-startx-deploy.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-monkey/values-startx-deploy.yaml), kube-monkey named `startx-monkey` in the namespace `startx-chaos-monkey`

```bash
helm install chaos-monkey-project startx/chaos-monkey -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-monkey/values-startx-project.yaml
helm install chaos-monkey-instance startx/chaos-monkey -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-monkey/values-startx-deploy.yaml -n startx-chaos-monkey
```

## Usage examples

### Default : namespace then kube-monkey

Two releases of the same chart, the namespace first.

```bash
helm install chaos-monkey-project startx/chaos-monkey --set project.enabled=true
helm install chaos-monkey-instance startx/chaos-monkey --set monkey.enabled=true -n chaos-monkey
```

### Minimal : dry-run

Kube-monkey schedules and logs the terminations without doing them : use it to validate the schedule and the opt-in labels.

```yaml
# my-monkey-dryrun-values.yaml
monkey:
  enabled: true
  config:
    dryRun: true
```

```bash
helm install chaos-monkey-instance startx/chaos-monkey -f my-monkey-dryrun-values.yaml -n chaos-monkey
```

### Advanced : own schedule and an opted-in workload

Terminations on working days hours of another time zone, limited to two namespaces, then the labels a Deployment needs to become a target.

```yaml
# my-monkey-values.yaml
context:
  scope: myorg
  cluster: mycluster
  environment: prod
  component: chaos
  app: kube-monkey
monkey:
  enabled: true
  config:
    dryRun: false
    runHour: 7
    startHour: 9
    endHour: 17
    timeZone: America/New_York
    whitelistedNamespaces: [ "myapp-dev", "myapp-test" ]
```

```bash
helm install chaos-monkey-instance startx/chaos-monkey -f my-monkey-values.yaml -n chaos-monkey
# opt a Deployment in : one pod killed, at most every 3 days (the labels go on the Deployment and on its pod template)
oc -n myapp-dev patch deployment myapp --type merge -p '{
  "metadata": {"labels": {"kube-monkey/enabled": "enabled", "kube-monkey/identifier": "myapp", "kube-monkey/mtbf": "3", "kube-monkey/kill-mode": "fixed", "kube-monkey/kill-value": "1"}},
  "spec": {"template": {"metadata": {"labels": {"kube-monkey/enabled": "enabled", "kube-monkey/identifier": "myapp"}}}}}'
```

## ArgoCD deployment

One AppProject and two Applications : `chaos-monkey-project` (wave 1, the namespace) then `chaos-monkey-instance` (wave 5, kube-monkey in dry-run mode).
The files are in [examples/argocd](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-monkey/examples/argocd).

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/chaos-monkey
oc apply -k examples/argocd/
```

Each Application sets the `enabled` key of the other part to `false`, so that the two Applications never render the
same resource. Delete `chaos-monkey-instance` first, wait for it to be gone, then delete `chaos-monkey-project` (it has no
finalizer : a namespace can be slow to terminate).

## History

| Release  | Date       | Description                                                                                                                                                 |
| -------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same release |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all charts to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.203 | 2026-06-24 | Improve chaos-monkey options |
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

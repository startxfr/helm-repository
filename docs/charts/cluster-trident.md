# ![cluster-trident](https://helm-repository.readthedocs.io/en/latest/img/cluster-trident.svg "Cluster Chart : Trident") Cluster Chart : Trident

[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--trident-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+trident+startx)

This helm chart is used to deploy and configure **NetApp Trident CSI** at the cluster level, handled by the certified `trident-operator`.
It configures the Trident control-plane (`TridentOrchestrator`), one or more ONTAP backends (`TridentBackendConfig` + credentials `Secret`),
the related `StorageClass` and the `VolumeSnapshotClass` used by backup tools like Kasten K10.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

- A reachable NetApp ONTAP cluster (management and data LIF, SVM, aggregate) and an SVM account
- Access to the `certified-operators` catalog

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
helm show chart startx/cluster-trident
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **trident** without constraints
- 1 **operator:** named **trident-operator** configured with
  - The **stable** channel of the certified catalog
  - The **v26.2.1** version
  - Deployed under the **openshift-operators** project (AllNamespaces, global OperatorGroup)
- 1 **TridentOrchestrator:** named **trident** deploying the CSI control-plane in the **trident** namespace
- 1 **TridentBackendConfig** (ONTAP-NAS) and its credentials **secret** per entry of `backends.list`
- 4 **storageClasses:** **ontap-nas-standard** (default), **ontap-nas-premium**, **ontap-nas-bronze** and **ontap-nas-backup**
- 1 **volumeSnapshotClass:** named **ontap-nas-snapclass** flagged as default for Kasten K10

```bash
# Create the project
helm install cluster-trident-project startx/cluster-trident --set project.enabled=true,project.project.enabled=true,operator.enabled=false
# Deploy the Trident operator
helm install cluster-trident-operator startx/cluster-trident --set project.enabled=false,operator.enabled=true && sleep 10
# Configure the Trident orchestrator, backends and storage classes
helm install cluster-trident-instance startx/cluster-trident -f my-backends.yaml --set project.enabled=false,operator.enabled=false,orchestrator.enabled=true,backends.enabled=true,storageClasses.enabled=true,volumeSnapshotClasses.enabled=true
```

#### Other available values

- **startx** : Trident operator, orchestrator, ONTAP-NAS backend and storage classes (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-trident/values-startx.yaml))

```bash
helm install cluster-trident startx/cluster-trident -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-trident/values-startx.yaml
```

## Values files

Example values files shipped with the chart, to use with `helm install -f <file>` :

- **startx** : STARTX cluster configuration, see values.yaml for the parameters (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-trident/values-startx.yaml))
- `examples/argocd/` : 5 example manifest(s) (see the ArgoCD or usage sections)

```bash
helm install cluster-trident startx/cluster-trident -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-trident/values-startx.yaml
```

## Values overview

See `values.yaml` for the full list. The most important keys are:

- `orchestrator.enabled` / `orchestrator.spec.*` : controls the `TridentOrchestrator` CR.
- `backends.enabled` / `backends.list[*]` : declares one or more `TridentBackendConfig` CR.
  Each entry must set `name`, `storageDriverName`, `managementLIF`, `dataLIF`, `svm` and `credentials.username` / `credentials.password`
  (or `credentials.secretName` to use an existing secret).
- `storageClasses.enabled` / `storageClasses.list[*]` : StorageClass created on top of the backends.
- `volumeSnapshotClasses.enabled` / `volumeSnapshotClasses.list[*]` : VolumeSnapshotClass (with the `k10.kasten.io/is-snapshot-class` annotation).
- `project.*` : passed to the [project](https://helm-repository.readthedocs.io/en/latest/charts/project) sub-chart.
- `operator.*` : passed to the [operator](https://helm-repository.readthedocs.io/en/latest/charts/operator) sub-chart.

## Resources rendered

| Resource                              | Sync wave |
| ------------------------------------- | --------- |
| Namespace (via `project` sub-chart)   | `-10`     |
| Subscription (via `operator` sub-chart) | `-5`    |
| Backend Secret                        | `1`       |
| TridentOrchestrator                   | `15`      |
| TridentBackendConfig                  | `30`      |
| StorageClass                          | `40`      |
| VolumeSnapshotClass                   | `40`      |

## Deploy with ArgoCD

### AppProject

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/cluster-trident/examples/argocd/
oc apply -k .
```

### Applications

| Application                | Wave   | Enabled flags                                                                                          | Destination           |
| -------------------------- | ------ | ------------------------------------------------------------------------------------------------------ | --------------------- |
| `cluster-trident-project`  | `"1"`  | `project.enabled: true`, all others `false`                                                            | `trident`             |
| `cluster-trident-operator` | `"5"`  | `operator.enabled: true` (`operatorGroup.enabled: false`), all others `false`                          | `openshift-operators` |
| `cluster-trident-app`      | `"10"` | `orchestrator`, `backends`, `storageClasses`, `volumeSnapshotClasses` enabled, `project`/`operator` `false` | `trident`        |

The backend credentials must be provided by overriding `backends.list` in the `cluster-trident-app` Application
(or by referencing an existing secret with `credentials.secretName`).

## History

| Release  | Date       | Description                                                       |
| -------- | ---------- | ----------------------------------------------------------------- |
| 21.3.3   | 2026-06-26 | Initial release of NetApp Trident CSI chart                       |
| 21.3.278 | 2026-10-21 | Align name, icon, metadata, sync-waves and docs to conventions   |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |

# ![cluster-kasten](https://helm-repository.readthedocs.io/en/latest/img/cluster-kasten.svg "Cluster Chart : Kasten K10") Cluster Chart : Kasten K10

[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--kasten-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+kasten+startx)

This helm chart is used to deploy and configure **Kasten K10** (Veeam) at the cluster level, handled by the certified `k10-kasten-operator-rhmp` operator.
It configures the K10 data management instance (`K10` CR), the backup locations (`Profile` CR + credentials `Secret`)
and the backup / export policies (`Policy` CR).

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

- Access to the `certified-operators` catalog
- A CSI driver with a `VolumeSnapshotClass` annotated `k10.kasten.io/is-snapshot-class: "true"`
  (see [cluster-trident](https://helm-repository.readthedocs.io/en/latest/charts/cluster-trident))
- An S3-compatible bucket for the location profiles

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
helm show chart startx/cluster-kasten
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **kasten-io** without constraints
- 1 **operator:** named **k10-kasten-operator-rhmp** configured with
  - The **stable** channel of the certified catalog
  - The **v8.5.8** version
  - Deployed under the **kasten-io** project (OwnNamespace, dedicated OperatorGroup)
- 1 **K10:** named **k10** with token authentication and the dashboard exposed through a TLS route
- 1 **profile** (and its credentials **secret**) per entry of `profiles.list`
- 1 **policy** per entry of `policies.list`

```bash
# Create the project
helm install cluster-kasten-project startx/cluster-kasten --set project.enabled=true,project.project.enabled=true,operator.enabled=false,k10.enabled=false,profiles.enabled=false
# Deploy the Kasten K10 operator
helm install cluster-kasten-operator startx/cluster-kasten --set project.enabled=false,operator.enabled=true,k10.enabled=false,profiles.enabled=false && sleep 10
# Configure the K10 instance
helm install cluster-kasten-instance startx/cluster-kasten --set project.enabled=false,operator.enabled=false,k10.enabled=true
```

#### Other available values

- **startx** : Kasten K10 operator and instance (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kasten/values-startx.yaml))

```bash
helm install cluster-kasten startx/cluster-kasten -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kasten/values-startx.yaml
```

## Values overview

See `values.yaml` for the full list. The most important keys are:

- `k10.enabled` / `k10.auth.*` : enables the K10 CR and chooses between token and basic authentication.
- `k10.global.persistence.*` : overrides the catalog PVC size and storage class.
- `k10.route.*` : exposes the K10 dashboard through an OpenShift route (TLS by default).
- `profiles.enabled` / `profiles.list[*]` : location profiles (S3 object store) and their credentials.
- `policies.enabled` / `policies.list[*]` : backup policies with optional export to a remote profile.
- `project.*` : passed to the [project](https://helm-repository.readthedocs.io/en/latest/charts/project) sub-chart.
- `operator.*` : passed to the [operator](https://helm-repository.readthedocs.io/en/latest/charts/operator) sub-chart (Subscription + OperatorGroup).

## Resources rendered

| Resource                                 | Sync wave |
| ---------------------------------------- | --------- |
| Namespace (via `project` sub-chart)      | `-10`     |
| OperatorGroup (via `operator` sub-chart) | `-6`      |
| Subscription (via `operator` sub-chart)  | `-5`      |
| Profile Secret                           | `1`       |
| K10                                      | `15`      |
| Profile                                  | `30`      |
| Policy                                   | `40`      |

`Profile` and `Policy` are rendered as helm hooks by default (`hooked: true`) because their CRD only exists once K10 is running.

## Deploy with ArgoCD

### AppProject

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/cluster-kasten/examples/argocd/
oc apply -k .
```

### Applications

| Application               | Wave   | Enabled flags                                                         | Destination |
| ------------------------- | ------ | --------------------------------------------------------------------- | ----------- |
| `cluster-kasten-project`  | `"1"`  | `project.enabled: true`, all others `false`                           | `kasten-io` |
| `cluster-kasten-operator` | `"5"`  | `operator.enabled: true`, all others `false`                          | `kasten-io` |
| `cluster-kasten-app`      | `"10"` | `k10`, `profiles`, `policies` enabled, `project`/`operator` `false`  | `kasten-io` |

## History

| Release  | Date       | Description                                                       |
| -------- | ---------- | ----------------------------------------------------------------- |
| 21.3.3   | 2026-06-26 | Initial release of Kasten K10 chart                               |
| 21.3.278 | 2026-10-21 | Align name, icon, metadata, sync-waves and docs to conventions   |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |

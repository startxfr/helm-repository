# ![cluster-dell-csm](https://helm-repository.readthedocs.io/en/latest/img/cluster-dell-csm.svg "Cluster Chart : Dell CSM") Cluster Chart : Dell CSM
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--dell--csm-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+dell+csm+startx)

Configure the Dell Container Storage Modules (CSM) operator and a Dell CSI storage driver.

This chart installs the certified `dell-csm-operator-certified` operator, deploys a Dell CSI driver (PowerStore by default, PowerMax, PowerFlex, PowerScale and Unity XT are supported through the `csm.driverType` value) with a `ContainerStorageModule` CR, manages the array credentials `Secret` read by the driver and creates the `StorageClass` and `VolumeSnapshotClass` objects consuming the array.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

### Prerequisites

- A Dell storage array (PowerStore, PowerMax, PowerFlex, PowerScale or Unity XT) whose management endpoint is reachable from the cluster nodes, and an array account allowed to provision storage (the **Storage Operator** role on PowerStore)
- The array credentials `Secret` named `<csm.name>-config` (`powerstore-config` by default) in the driver namespace, holding the Dell `arrays:` configuration under the `config` key. The chart renders it from `arraySecret.config` or through an `ExternalSecret` (see [External secrets](#external-secrets)); it can also be created outside of the chart. The CR always carries `authSecret`, so the same name is used whatever the driver (the operator would otherwise look for `<name>-config` on PowerStore and PowerFlex, `<name>-creds` on PowerMax, PowerScale and Unity); PowerFlex, PowerScale and Unity use the same `config` key with their own layout
- The node side prerequisites of the chosen protocol are **not** handled by this chart and must be applied through MachineConfigs before enabling the driver: `iscsid` and `multipathd` services for iSCSI, `multipathd` and FC zoning for Fibre Channel, unique host NQN and the `nvme` reconnect and round-robin settings for NVMe/TCP or NVMe/FC, NFS client for NFS volumes (see the [Dell CSM documentation](https://dell.github.io/csm-docs/docs/getting-started/installation/openshift/powerstore/csmoperator/))
- Access to the `certified-operators` catalog of OperatorHub

The operator is installed in the `openshift-operators` namespace (AllNamespaces mode, the default of OperatorHub and of the Dell documentation), so no dedicated OperatorGroup is created. The driver runs in the `default-dell-csm` namespace created by the `project` sub-chart.

The `csm.version` value must be a CSM release supported by the installed operator: operator 1.13.x supports CSM `v1.16.0` to `v1.18.2`, the full list being the `operatorconfig/common/csm-releases.yaml` file of the [csm-operator](https://github.com/dell/csm-operator) release tag (`oc get csv -n openshift-operators` gives the installed operator version, `oc get packagemanifests -n openshift-marketplace dell-csm-operator-certified -o jsonpath='{.status.channels[0].currentCSV}'` the version proposed by the `stable` channel). Operators older than CSM 1.16 use the deprecated driver configuration version instead (`csm.configVersion`, ex: `v2.18.1` for PowerStore, see `operatorconfig/driverconfig/<driver>/`).

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
helm show chart startx/cluster-dell-csm
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics:

- Deploy the **ContainerStorageModule CR** (`default-dell-csm/powerstore`) installing the PowerStore CSI driver (CSM `v1.18.2`, 2 controller replicas) when `csm.enabled` is set
- Deploy the array credentials **Secret** `powerstore-config` from `arraySecret.config` when `arraySecret.enabled` is set
- Deploy the **StorageClass** `powerstore-xfs` and the **VolumeSnapshotClass** `powerstore-snapshot` when `storageClasses.enabled` and `volumeSnapshotClasses.enabled` are set
- The operator subscription and namespace are managed separately via the `operator` and `project` sub-charts (both disabled by default)

```bash
# base configuration running default configuration
helm install cluster-dell-csm startx/cluster-dell-csm
```

#### Full deployment with operator and project

Enable the project namespace, the operator subscription, the array credentials and the driver with its storage classes
(the subscription uses `installPlanApproval: Manual`, approve the InstallPlan before the CR is reconciled):

```bash
cat > my-array.yaml <<EOF
arraySecret:
  enabled: true
  config: |
    arrays:
      - endpoint: "https://powerstore.example.com/api/rest"
        globalID: "PS000000000000"
        username: "csmadmin"
        password: "changeme"
        skipCertificateValidation: true
        isDefault: true
        blockProtocol: "ISCSI"
        nasName: "nas-server"
EOF
helm install cluster-dell-csm startx/cluster-dell-csm -f my-array.yaml \
  --set project.enabled=true \
  --set operator.enabled=true \
  --set csm.enabled=true \
  --set storageClasses.enabled=true \
  --set volumeSnapshotClasses.enabled=true
```

#### Other available values

- **startx** : Dell CSM driver, storage classes and snapshot class with full STARTX context and infra nodes placement (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-dell-csm/values-startx.yaml))
- **startx_noinfra** : same deployment without infra nodes placement (see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-dell-csm/values-startx_noinfra.yaml))

```bash
helm install cluster-dell-csm startx/cluster-dell-csm -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-dell-csm/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-dell-csm` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-dell-csm/examples/argocd/
oc apply -k .
```

| Application                 | Wave   | Enabled flags                                                                      | Destination           |
| --------------------------- | ------ | ---------------------------------------------------------------------------------- | --------------------- |
| `cluster-dell-csm-project`  | `"1"`  | `project.enabled: true`, all others `false`                                        | `default-dell-csm`    |
| `cluster-dell-csm-operator` | `"5"`  | `operator.enabled: true` (`operatorGroup.enabled: false`), all others `false`      | `openshift-operators` |
| `cluster-dell-csm-app`      | `"10"` | `csm`, `storageClasses` and `volumeSnapshotClasses` enabled, all others `false`    | `default-dell-csm`    |

The array credentials are not part of the example: enable `arraySecret` in the `cluster-dell-csm-app` Application with
your own `arraySecret.config` or `arraySecret.externalSecret`, or create the `powerstore-config` Secret outside of ArgoCD.
The `ignoreDifferences` of the `-app` Application covers the finalizer and the `storage.dell.com/*` annotations added by
the operator on the `ContainerStorageModule`; add `.spec.version` to it when `csm.extraSpec.upgrade: auto` is used because
the operator then rewrites the CSM version itself.

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## External secrets

The array credentials (`arraySecret`) can come from an external store (Vault, AWS Secrets Manager...)
through the [External Secrets Operator](https://external-secrets.io) instead of the chart values.
With `arraySecret.externalSecret.enabled: true`, the chart renders an `ExternalSecret` producing the
Secret `<csm.name>-config` in the driver namespace with the `config` key, so the driver configuration is
unchanged. Without `externalSecret`, the chart keeps rendering the Secret from `arraySecret.config`.

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
arraySecret:
  enabled: true
  externalSecret:
    enabled: true
    remoteRefs:
      config:
        key: ocp/storage/powerstore
        property: config
```

An `externalSecret` block accepts `secretStoreRef` and `refreshInterval` (defaults: `externalSecretDefaults`),
`remoteRefs` (map of secret key to ESO `remoteRef`) and the raw ESO fields `data`, `dataFrom` and `template`.
Rendering fails when no store is set or when the `config` key is not provided.

## Values dictionary

### context values dictionary

| Key                 | Default            | Description                                                  |
| ------------------- | ------------------ | ------------------------------------------------------------ |
| context.scope       | `myscope`          | Name of the global scope for this application                |
| context.cluster     | `default`          | Name of the cluster running this application                 |
| context.environment | `myenv`            | Name of the environment (dev, factory, preprod, prod)        |
| context.component   | `mycomponent`      | Component name of this application                           |
| context.app         | `default-dell-csm` | Application name                                             |
| context.version     | `1.13.2`           | Version name of this application                             |

### externalSecretDefaults values dictionary

| Key                                        | Default                   | Description                                                           |
| ------------------------------------------ | ------------------------- | --------------------------------------------------------------------- |
| externalSecretDefaults.apiVersion          | `external-secrets.io/v1`  | API version of the ExternalSecret CRD                                 |
| externalSecretDefaults.refreshInterval     | `1h`                      | How often the Secret is refreshed from the external store             |
| externalSecretDefaults.secretStoreRef.name | `""`                      | Name of the (Cluster)SecretStore, required as soon as a secret uses externalSecret |
| externalSecretDefaults.secretStoreRef.kind | `ClusterSecretStore`      | Kind of the store (`ClusterSecretStore` or `SecretStore`)             |

### csm values dictionary

| Key                            | Default                      | Description                                                                                                  |
| ------------------------------ | ---------------------------- | ------------------------------------------------------------------------------------------------------------ |
| csm.enabled                    | `false`                      | Enable the creation of the ContainerStorageModule CR                                                         |
| csm.hooked                     | `false`                      | Deploy as a Helm/ArgoCD post-sync hook                                                                       |
| csm.name                       | `powerstore`                 | Name of the CR (the driver reads the array credentials from the Secret `<name>-config`)                      |
| csm.driverType                 | `powerstore`                 | Dell CSI driver (`csiDriverType`): `powerstore`, `powermax`, `powerflex`, `isilon` (PowerScale) or `unity`   |
| csm.version                    | `v1.18.2`                    | CSM release deployed by the operator (`spec.version`), must be supported by the installed operator           |
| csm.configVersion              | `""`                         | Deprecated driver configuration version (`spec.driver.configVersion`) for operators older than CSM 1.16      |
| csm.replicas                   | `2`                          | Number of replicas of the controller plugin                                                                  |
| csm.authSecret                 | `""`                         | Name of the array credentials Secret (empty = `<csm.name>-config`, always set in the CR)                     |
| csm.common.image               | `""`                         | Custom driver image (empty = image shipped with the operator release)                                        |
| csm.common.imagePullPolicy     | `IfNotPresent`               | Pull policy of the driver image                                                                              |
| csm.common.envs                | `[]`                         | Environment variables merged in `spec.driver.common.envs` (operator defaults apply when empty)               |
| csm.dnsPolicy                  | `ClusterFirstWithHostNet`    | DNS policy of the node plugin daemonset                                                                      |
| csm.forceRemoveDriver          | `true`                       | Remove the driver deployment when the CR is deleted                                                          |
| csm.csiDriverSpec              | `{fSGroupPolicy, storageCapacity}` | CSIDriver object settings (`fSGroupPolicy: ReadWriteOnceWithFSType`, `storageCapacity: true`), `null` for operator defaults |
| csm.controller.infra_enabled   | `false`                      | Run the controller plugin on infra nodes (infra nodeSelector and toleration)                                 |
| csm.controller.nodeSelector    | `{}`                         | Node selector of the controller plugin (ignored when `infra_enabled`)                                        |
| csm.controller.tolerations     | `[]`                         | Tolerations of the controller plugin (ignored when `infra_enabled`)                                          |
| csm.controller.envs            | `[]`                         | Environment variables merged in `spec.driver.controller.envs`                                                |
| csm.node.infra_enabled         | `false`                      | Let the node plugin run on infra nodes too (adds the infra toleration, no nodeSelector)                      |
| csm.node.nodeSelector          | `{}`                         | Node selector of the node plugin                                                                             |
| csm.node.tolerations           | `[]`                         | Tolerations of the node plugin (ignored when `infra_enabled`)                                                |
| csm.node.envs                  | `[]`                         | Environment variables merged in `spec.driver.node.envs`                                                      |
| csm.sideCars                   | `[]`                         | CSI sidecar overrides rendered in `spec.driver.sideCars` (raw list)                                          |
| csm.modules                    | `[]`                         | CSM modules rendered in `spec.modules` (raw list): `replication`, `observability`, `resiliency`, `authorization` |
| csm.extraSpec                  | `{}`                         | Extra fields appended to the CR spec (raw map, ex: `upgrade: auto`, `customRegistry`)                        |

### arraySecret values dictionary

| Key                                 | Default                    | Description                                                                                     |
| ----------------------------------- | -------------------------- | ----------------------------------------------------------------------------------------------- |
| arraySecret.enabled                 | `false`                    | Enable the creation of the array credentials Secret                                             |
| arraySecret.name                    | `""`                       | Name of the Secret (empty = `csm.authSecret`, then `<csm.name>-config`)                         |
| arraySecret.config                  | PowerStore example         | Dell `arrays:` configuration stored in the `config` key (raw YAML text, one entry per array)    |
| arraySecret.externalSecret.enabled  | `false`                    | Source the Secret from an external store (renders an ExternalSecret with the `config` key)      |
| arraySecret.externalSecret.*        |                            | `secretStoreRef`, `refreshInterval`, `remoteRefs`, `data`, `dataFrom`, `template` (see above)   |

### storageClasses values dictionary

| Key                                      | Default                 | Description                                                                                             |
| ---------------------------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------- |
| storageClasses.enabled                   | `false`                 | Enable the creation of the StorageClasses                                                               |
| storageClasses.hooked                    | `false`                 | Deploy as a Helm/ArgoCD post-sync hook                                                                  |
| storageClasses.provisioner               | `""`                    | CSIDriver name used as provisioner (empty = driver of `csm.driverType`, ex: `csi-powerstore.dellemc.com`) |
| storageClasses.list[].name               | `powerstore-xfs`        | Name of the StorageClass                                                                                |
| storageClasses.list[].isDefault          | `false`                 | Make this StorageClass the default one of the cluster                                                   |
| storageClasses.list[].parameters         | `csi.storage.k8s.io/fstype: "xfs"` | Driver parameters (raw YAML text): `arrayID`, `csi.storage.k8s.io/fstype`, `nasName`, `allowRoot`, `nfsAcls`... |
| storageClasses.list[].reclaimPolicy      | `Delete`                | Reclaim policy of the volumes (`Delete` or `Retain`)                                                    |
| storageClasses.list[].allowVolumeExpansion | `true`                | Enable the expansion of the volumes                                                                     |
| storageClasses.list[].volumeBindingMode  | `Immediate`             | Binding mode of the volumes (`Immediate` or `WaitForFirstConsumer`)                                     |
| storageClasses.list[].mountOptions       | `[]`                    | Mount options applied to the volumes                                                                    |
| storageClasses.list[].provisioner        |                         | Per class provisioner override                                                                          |

### volumeSnapshotClasses values dictionary

| Key                                        | Default               | Description                                                              |
| ------------------------------------------ | --------------------- | ------------------------------------------------------------------------ |
| volumeSnapshotClasses.enabled              | `false`               | Enable the creation of the VolumeSnapshotClasses                         |
| volumeSnapshotClasses.hooked               | `false`               | Deploy as a Helm/ArgoCD post-sync hook                                   |
| volumeSnapshotClasses.driver               | `""`                  | CSIDriver name handling the snapshots (empty = driver of `csm.driverType`) |
| volumeSnapshotClasses.list[].name          | `powerstore-snapshot` | Name of the VolumeSnapshotClass                                          |
| volumeSnapshotClasses.list[].isDefault     | `false`               | Make this VolumeSnapshotClass the default one of the cluster             |
| volumeSnapshotClasses.list[].veleroEnabled | `false`               | Add the `velero.io/csi-volumesnapshot-class` label (Velero / OADP)       |
| volumeSnapshotClasses.list[].deletionPolicy | `Delete`             | Deletion policy of the snapshots (`Delete` or `Retain`)                  |
| volumeSnapshotClasses.list[].parameters    | `""`                  | Driver parameters (raw YAML text)                                        |
| volumeSnapshotClasses.list[].driver        |                       | Per class driver override                                                |

### project values dictionary

| Key                      | Default                                              | Description                                           |
| ------------------------ | ---------------------------------------------------- | ----------------------------------------------------- |
| project.enabled          | `false`                                              | Enable the project sub-chart (driver namespace)       |
| project.project.name     | `default-dell-csm`                                   | Namespace where the driver and its Secret are created |
| project.project.display_name | `Dell CSM storage`                               | Display name of the namespace                         |
| project.project.description  | `Dell Container Storage Modules configured by STARTX` | Description of the namespace                      |

### operator values dictionary

| Key                                              | Default                       | Description                                                |
| ------------------------------------------------ | ----------------------------- | ---------------------------------------------------------- |
| operator.enabled                                 | `false`                       | Enable the operator sub-chart (subscription)               |
| operator.subscription.name                       | `dell-csm-operator-certified` | Name of the Subscription and of the OperatorHub package    |
| operator.subscription.namespace                  | `openshift-operators`         | Namespace of the operator (AllNamespaces mode)             |
| operator.subscription.version                    | `v1.13.2`                     | Version of the operator (used with `csv` for startingCSV)  |
| operator.subscription.operator.channel           | `stable`                      | Channel of the subscription                                |
| operator.subscription.operator.installPlanApproval | `Manual`                    | Approval mode of the InstallPlans                          |
| operator.subscription.operator.source.name       | `certified-operators`         | Catalog source of the operator                             |
| operator.subscription.operator.config.infra      | `false`                       | Run the operator on infra nodes                            |
| operator.operatorGroup.enabled                   | `false`                       | Disabled: `openshift-operators` already has a global OperatorGroup |

## History

| Release  | Date       | Description            |
| -------- | ---------- | ---------------------- |
| 21.3.321 | 2026-11-08 | Initial chart creation |

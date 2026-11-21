# ![cluster-kubevirt](https://helm-repository.readthedocs.io/en/latest/img/cluster-kubevirt.svg "Cluster Chart : KubeVirt") Cluster Chart : KubeVirt
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--kubevirt-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+kubevirt+startx)

This helm chart is used to configure code ready kubevirt via it's operator and deploy a VM into Openshift.

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
helm show chart startx/cluster-kubevirt
```

### 4. Install this chart

```bash
helm install cluster-kubevirt startx/cluster-kubevirt
```

## Default values

Complete deployment of a KubeVirt configuration with the following characteristics :

- 1 **operator** named **kubevirt-hyperconverged** deployed under **openshift-cnv**
- 1 **HyperConverged** cluster instance enabling OpenShift Virtualization
- Optional **VirtualMachine** instances configurable via the vms list
- Optional **NetworkAttachmentDefinition** resources configurable via the nads list

### Live migration on a dedicated network

The live migration traffic can leave the pod network and use a dedicated interface of the nodes
(a bond, a VLAN or a physical NIC present on every node hosting virtual machines). Declare a
NetworkAttachmentDefinition in the HyperConverged namespace and reference it in the live migration
settings:

```yaml
hyperconvergedCluster:
  enabled: true
  liveMigration:
    # NetworkAttachmentDefinition created by the nads block below
    network: live-migration
    parallelOutboundMigrationsPerNode: 2
nads:
  enabled: true
  list:
    - name: live-migration
      config: |
        cniVersion: "0.3.1"
        type: macvlan
        master: bond1
        mode: bridge
        ipam:
          type: whereabouts
          range: 192.168.250.0/24
```

The interface (`master`) must exist with the same name on every node hosting virtual machines and the
IPAM range must be dedicated to the migration network. The virt-handler pods are restarted with an
additional interface on this network; running virtual machines are not affected. Check a migration with
`oc get vmi <name> -o jsonpath='{.status.migrationState.targetNodeAddress}'`: the address must belong to
the migration range.

The `config` field accepts the CNI configuration in YAML or JSON; it is stored as the JSON string expected
by Multus and its `name` defaults to the resource name. Any CNI type is accepted (bridge, macvlan, ipvlan,
sriov, ovn-k8s-cni-overlay...). The default namespace of a network attachment is the project namespace
(`openshift-cnv`); use `namespace: default` to make a network available to every namespace.

### hyperconvergedCluster values dictionary

| Key                                                              | Default                  | Description                                                                                            |
| ---------------------------------------------------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------ |
| hyperconvergedCluster.enabled                                    | `true`                   | Enable the HyperConverged CR                                                                           |
| hyperconvergedCluster.hooked                                     | `false`                  | Deploy the CR as a Helm/ArgoCD post-sync hook                                                          |
| hyperconvergedCluster.name                                       | `kubevirt-hyperconverged` | Name of the HyperConverged CR                                                                         |
| hyperconvergedCluster.evictionStrategy                           | `None`                   | Eviction strategy of the virtual machines on node drain (None, LiveMigrate, LiveMigrateIfPossible)    |
| hyperconvergedCluster.liveMigration.network                      | `""`                     | NetworkAttachmentDefinition carrying the live migration traffic (empty = pod network)                 |
| hyperconvergedCluster.liveMigration.allowAutoConverge            | `false`                  | Allow the migration to slow down the virtual machine so that it converges                              |
| hyperconvergedCluster.liveMigration.allowPostCopy                | `false`                  | Allow post-copy migrations                                                                             |
| hyperconvergedCluster.liveMigration.completionTimeoutPerGiB      | `800`                    | Maximum time in seconds, per GiB of memory, for a migration to complete                                |
| hyperconvergedCluster.liveMigration.parallelMigrationsPerCluster | `5`                      | Maximum number of migrations running in parallel in the cluster                                        |
| hyperconvergedCluster.liveMigration.parallelOutboundMigrationsPerNode | `2`                 | Maximum number of outbound migrations per node                                                         |
| hyperconvergedCluster.liveMigration.progressTimeout              | `150`                    | Time in seconds without progress before a migration is aborted                                         |

### nads values dictionary

| Key                      | Default | Description                                                                                 |
| ------------------------ | ------- | ------------------------------------------------------------------------------------------- |
| nads.enabled             | `false` | Enable the creation of the NetworkAttachmentDefinition list                                 |
| nads.hooked              | `false` | Deploy the resources as a Helm/ArgoCD post-sync hook                                        |
| nads.list                | `[]`    | List of NetworkAttachmentDefinition to create                                               |
| nads.list[].name         |         | Name of the NetworkAttachmentDefinition                                                     |
| nads.list[].namespace    | project | Namespace of the NetworkAttachmentDefinition (default is the project namespace)             |
| nads.list[].annotations  | `{}`    | Additional annotations (ex: `k8s.v1.cni.cncf.io/resourceName` for SR-IOV networks)          |
| nads.list[].config       |         | CNI configuration (YAML/JSON text or map), stored as the JSON string expected by Multus     |

## Other available values

- **cdf-poc** : [values-cdf-poc.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kubevirt/values-cdf-poc.yaml)
- **demo** : [values-demo.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kubevirt/values-demo.yaml)
- **startx** : [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kubevirt/values-startx.yaml)
- **startx_noinfra** : [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kubevirt/values-startx_noinfra.yaml)

```bash
helm install cluster-kubevirt startx/cluster-kubevirt -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kubevirt/values-cdf-poc.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-kubevirt/examples/argocd/
oc apply -k .
```

### Applications



## History

| Release  | Date       | Description                                                                                                |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.12 | 2026-06-18 | Improve cluster-kubevirt options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-08 | Add live migration settings (dedicated network, eviction strategy) and NetworkAttachmentDefinition list |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |

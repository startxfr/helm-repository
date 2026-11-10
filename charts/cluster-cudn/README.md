# ![cluster-cudn](https://helm-repository.readthedocs.io/en/latest/img/cluster-cudn.svg "Cluster Chart : User-defined networks") Cluster Chart : User-defined networks
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--cudn-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+cudn+startx)

Configure OVN-Kubernetes user-defined networks (ClusterUserDefinedNetwork and UserDefinedNetwork).

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

User-defined networks (UDN) are a native feature of the OVN-Kubernetes network plugin: they create isolated layer 2 or layer 3
network segments that replace (primary network) or complete (secondary network) the default pod network of the selected namespaces,
with optional persistent IP addresses for virtual machines. No operator is required, the `ClusterUserDefinedNetwork` and
`UserDefinedNetwork` APIs (`k8s.ovn.org/v1`) are shipped with OpenShift. This chart manages:

- **Namespaces** attached to a primary user-defined network, created with the mandatory `k8s.ovn.org/primary-user-defined-network` label
- **ClusterUserDefinedNetwork** resources (cluster-scoped, shared across the namespaces matched by a selector, `Layer2`, `Layer3` or `Localnet` topology)
- **UserDefinedNetwork** resources (namespace-scoped, `Layer2` or `Layer3` topology)

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

### Prerequisites

- An OpenShift cluster running the **OVN-Kubernetes** network plugin (the only plugin providing the user-defined network APIs)
- **OpenShift 4.18 or later**, the first release where user-defined network segmentation is generally available
- For `Localnet` networks, an OVS bridge mapping on the nodes created with a `NodeNetworkConfigurationPolicy` (see the
  [cluster-nmstate](https://helm-repository.readthedocs.io/en/latest/charts/cluster-nmstate) chart): the `physicalNetworkName`
  of the network must match the `localnet` value of the `ovn.bridge-mappings` item of the policy
- `cluster-admin` privileges: `ClusterUserDefinedNetwork` resources and namespaces are cluster-scoped

### Namespaces and the primary network label

OVN-Kubernetes only attaches a namespace to a **primary** user-defined network when the namespace carries the
`k8s.ovn.org/primary-user-defined-network: ""` label. This label can only be set when the namespace is created (it cannot be
added afterwards) and must exist before any pod runs in the namespace. The `namespaces` block of this chart therefore creates
the tenant namespaces itself (sync-wave `-10`, annotated `helm.sh/resource-policy: keep` so that they survive a chart removal),
with the label and the additional labels used by the `ClusterUserDefinedNetwork` namespace selectors. Create these namespaces
with this chart (or with the `project` chart and its `additionalLabels` option), never with an ArgoCD `CreateNamespace=true`
sync option that would create them without the label.

Additional rules to keep in mind:

- the `default` namespace and the `openshift-*` namespaces must never be selected by a primary network
- a namespace can only have one primary network; namespaces that only consume a secondary network do not need the label
- `ClusterUserDefinedNetwork` and `UserDefinedNetwork` resources are immutable: delete and recreate them to change a network
- the network subnets must not overlap the cluster network, the service network, the join subnet (`100.64.0.0/16`, `100.65.0.0/16`)
  and the masquerade subnet (`169.254.0.0/17`) of the cluster
- the namespace and the network must exist before the pods: a pod created in a labelled namespace stays pending until its
  primary network is created
- `Localnet` is only available with `ClusterUserDefinedNetwork`, with the `Secondary` role only

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
helm show chart startx/cluster-cudn
```

### 4. Install this chart

#### Default values

The default values keep every feature disabled and render nothing: the networks and namespaces are cluster-specific and
must be provided in a values file.

```bash
# base configuration running default configuration
helm install cluster-cudn startx/cluster-cudn
```

#### Full deployment with tenant namespaces and networks

Create a values file describing the namespaces and the networks of your cluster, then enable the features:

```yaml
namespaces:
  enabled: true
  list:
    - name: demo-cudn-blue
      display_name: "Demo blue tenant"
      labels:
        app.startx.fr/network: blue
clusterNetworks:
  enabled: true
  list:
    # Layer2 primary network with persistent IP addresses (virtual machines live migration)
    - name: blue-layer2
      namespaceSelector:
        matchLabels:
          app.startx.fr/network: blue
      network:
        topology: Layer2
        layer2:
          role: Primary
          subnets:
            - 10.200.0.0/16
          ipam:
            lifecycle: Persistent
    # Localnet secondary network bridged to the physical VLAN 100 (needs a NNCP bridge mapping named localnet-datacenter)
    - name: datacenter-vlan100
      namespaceSelector:
        matchLabels:
          app.startx.fr/network: datacenter
      network:
        topology: Localnet
        localnet:
          role: Secondary
          physicalNetworkName: localnet-datacenter
          vlan:
            mode: Access
            access:
              id: 100
          subnets:
            - 192.168.100.0/24
          excludeSubnets:
            - 192.168.100.0/26
          ipam:
            lifecycle: Persistent
          mtu: 1500
```

```bash
helm install cluster-cudn startx/cluster-cudn -f my-networks.yaml
```

The `NodeNetworkConfigurationPolicy` required by the `Localnet` example above can be deployed with the `cluster-nmstate` chart:

```yaml
nncp:
  enabled: true
  name: ovs-br1-datacenter
  nodeSelector:
    node-role.kubernetes.io/worker: ""
  desiredState: |
    interfaces:
      - name: ovs-br1
        type: ovs-bridge
        state: up
        bridge:
          allow-extra-patch-ports: true
          options:
            stp: false
          port:
            - name: eth1
    ovn:
      bridge-mappings:
        - localnet: localnet-datacenter
          bridge: ovs-br1
          state: present
```

#### Other available values

- **startx** : STARTX demo tenants (`startx-cudn-blue` on a Layer2 primary cluster network, `startx-cudn-green` on a Layer3 namespaced network), see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-cudn/values-startx.yaml)
- **startx_noinfra** : same content, used by the ArgoCD examples, see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-cudn/values-startx_noinfra.yaml)

```bash
helm install cluster-cudn startx/cluster-cudn -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-cudn/values-startx.yaml \
  --set namespaces.enabled=true \
  --set clusterNetworks.enabled=true \
  --set networks.enabled=true
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-cudn` using two dedicated ArgoCD Applications - one per concern - sharing the same AppProject (there is no
operator Application because the user-defined network APIs are built into OpenShift):

- `cluster-cudn-project` (sync-wave `1`) creates the `default-cudn` project with the `project` sub-chart
- `cluster-cudn-app` (sync-wave `10`) creates the tenant namespaces, the `ClusterUserDefinedNetwork` and the `UserDefinedNetwork` resources

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-cudn/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.
The `cluster-cudn-app` Application must **not** use the `CreateNamespace=true` sync option: the tenant namespaces have to be created
by the chart templates so that they carry the `k8s.ovn.org/primary-user-defined-network` label from the start. The AppProject
whitelists the cluster-scoped kinds created by the chart (`Namespace` and `ClusterUserDefinedNetwork`) and the Application ignores
the `k8s.ovn.org/user-defined-network-protection` finalizer added by OVN-Kubernetes on every network.

## Values dictionary

### context values dictionary

| Key                 | Default        | Description                                                  |
| ------------------- | -------------- | ------------------------------------------------------------ |
| context.scope       | `myscope`      | Name of the global scope for this application                |
| context.cluster     | `default`      | Name of the cluster running this application                 |
| context.environment | `myenv`        | Name of the environment (dev, factory, preprod, prod)        |
| context.component   | `mycomponent`  | Component name of this application                           |
| context.app         | `default-cudn` | Application name                                             |
| context.version     | `4.22.0`       | Version name of this application                             |

### namespaces values dictionary

| Key                               | Default | Description                                                                                   |
| --------------------------------- | ------- | --------------------------------------------------------------------------------------------- |
| namespaces.enabled                | `false` | Enable the creation of the namespaces attached to a primary user-defined network              |
| namespaces.list                   | `[]`    | List of namespaces to create (sync-wave `-10`, kept on uninstall)                             |
| namespaces.list[].name            |         | Name of the namespace (never `default` or `openshift-*`)                                      |
| namespaces.list[].display_name    | name    | Display name of the namespace (`openshift.io/display-name` annotation)                        |
| namespaces.list[].description     |         | Description of the namespace (`openshift.io/description` annotation)                          |
| namespaces.list[].labels          | `{}`    | Additional labels, added to the `k8s.ovn.org/primary-user-defined-network` label              |
| namespaces.list[].primary         | `true`  | Set the `k8s.ovn.org/primary-user-defined-network` label (`false`: secondary networks only)   |

### clusterNetworks values dictionary

| Key                                        | Default | Description                                                                                    |
| ------------------------------------------ | ------- | ---------------------------------------------------------------------------------------------- |
| clusterNetworks.enabled                    | `false` | Enable the creation of the `ClusterUserDefinedNetwork` resources                               |
| clusterNetworks.list                       | `[]`    | List of `ClusterUserDefinedNetwork` resources (sync-wave `15`)                                 |
| clusterNetworks.list[].name                |         | Name of the cluster-scoped network                                                             |
| clusterNetworks.list[].labels              | `{}`    | Additional labels set on the resource                                                          |
| clusterNetworks.list[].namespaceSelector   |         | Label selector of the attached namespaces (`spec.namespaceSelector`, rendered as is, required) |
| clusterNetworks.list[].network             |         | Network definition (`spec.network`, rendered as is, required)                                  |
| ...network.topology                        |         | `Layer2` (one switch for all nodes), `Layer3` (one subnet per node) or `Localnet` (physical)   |
| ...network.layer2.role                     |         | `Primary` (replaces the pod network) or `Secondary` (attached on demand)                       |
| ...network.layer2.subnets                  |         | Pod subnets (one IPv4 and/or one IPv6 CIDR)                                                    |
| ...network.layer2.ipam.lifecycle           |         | `Persistent` keeps the IP addresses of virtual machines across restarts and live migrations    |
| ...network.layer2.ipam.mode                |         | `Enabled` (default) or `Disabled` (secondary networks only, no IP assigned by OVN-Kubernetes)  |
| ...network.layer2.mtu                      |         | Maximum transmission unit (default `1400`)                                                     |
| ...network.layer2.joinSubnets              |         | Internal join subnets (primary networks only, override when `100.65.0.0/16` is already in use) |
| ...network.layer3.subnets                  |         | List of `{cidr, hostSubnet}` items, `hostSubnet` is the per-node prefix length (mandatory)     |
| ...network.localnet.physicalNetworkName    |         | Name of the OVS bridge mapping (`ovn.bridge-mappings[].localnet` of the NNCP), required        |
| ...network.localnet.vlan                   |         | VLAN tagging: `{mode: Access, access: {id: <1-4094>}}`                                         |
| ...network.localnet.subnets                |         | Subnet of the physical network used to assign pod IP addresses                                 |
| ...network.localnet.excludeSubnets         |         | Ranges of the physical network that OVN-Kubernetes must never assign                           |
| ...network.localnet.mtu                    |         | Maximum transmission unit, must match the physical interface (default `1500`)                  |

### networks values dictionary

| Key                              | Default      | Description                                                                              |
| -------------------------------- | ------------ | ---------------------------------------------------------------------------------------- |
| networks.enabled                 | `false`      | Enable the creation of the `UserDefinedNetwork` resources                                |
| networks.list                    | `[]`         | List of `UserDefinedNetwork` resources (sync-wave `15`)                                  |
| networks.list[].name             |              | Name of the namespaced network                                                           |
| networks.list[].namespace        | project name | Namespace of the network (must carry the primary label for a `Primary` role)             |
| networks.list[].labels           | `{}`         | Additional labels set on the resource                                                    |
| networks.list[].network          |              | Network definition (`spec`, rendered as is): `topology` plus `layer2` or `layer3` config |

### project values dictionary

| Key                              | Default                       | Description                                                                                 |
| -------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------- |
| project.enabled                  | `false`                       | Enable the `project` sub-chart (namespace hosting the namespaced networks by default)       |
| project.project.name             | `default-cudn`                | Name of the project namespace                                                               |
| project.project.additionalLabels |                               | String of labels, set it to `k8s.ovn.org/primary-user-defined-network: ""` for a primary UDN |

## History

| Release  | Date       | Description                                             |
| -------- | ---------- | ------------------------------------------------------- |
| 21.3.321 | 2026-11-08 | Initial chart creation                                  |
| 21.3.361 | 2026-11-10 | Release 21.3.361 for all charts |

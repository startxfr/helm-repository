# ![cluster-metallb](https://helm-repository.readthedocs.io/en/latest/img/cluster-metallb.svg "Cluster Chart : MetalLB") Cluster Chart : MetalLB
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--metallb-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+metallb+startx)

Configure the MetalLB operator and the load balancer address pools, layer 2 and BGP advertisements of a bare metal cluster.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

MetalLB gives an external IP address to the services of type `LoadBalancer` on the clusters that have no cloud load balancer
(bare metal, vSphere). This chart installs the Red Hat `metallb-operator` operator and manages:

- the **MetalLB** instance (`MetalLB` CR): the controller deployment allocating the addresses and the speaker daemonset announcing them
- the **address pools** (`IPAddressPool`): the IP ranges MetalLB is allowed to assign
- the **layer 2 advertisements** (`L2Advertisement`): the addresses are announced with ARP and NDP on the network of the nodes
- the **BGP configuration** (`BGPPeer`, `BGPAdvertisement`, `BFDProfile`, `Community`): the addresses are announced to routers
- the **secrets** referenced by these resources (password of a BGP session), from values or through an `ExternalSecret`

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

### Prerequisites

- An OpenShift cluster installed on bare metal, VMware vSphere, IBM Z or IBM Power. MetalLB is not supported on the cloud provider
  platforms (AWS, Azure, Google Cloud), which provide their own load balancers
- Free IP addresses for the pools: in the subnet of the nodes for the layer 2 mode, or any range routed by your routers for the BGP mode.
  Never list an address already in use (gateway, nodes, API and ingress virtual IP, DHCP range)
- Access to the `redhat-operators` catalog of the software catalog
- `cluster-admin` privileges
- MetalLB and IP failover are incompatible: remove the IP failover configuration of the cluster before installing the operator

The operator only supports the `AllNamespaces` install mode and is installed in the `metallb-system` namespace, created by the
`project` sub-chart with the `openshift.io/cluster-monitoring` label (required to collect the BGP and BFD metrics). MetalLB runs in the
namespace of its operator and only reads its configuration there: every resource of this chart is created in this namespace, and the
instance must be named `metallb`.

### Layer 2 or BGP

| Mode    | How the address is announced                                      | Network requirement                                     | Behavior to know                                                                                               |
| ------- | ----------------------------------------------------------------- | ------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| Layer 2 | One speaker answers the ARP (IPv4) and NDP (IPv6) requests        | Pool in the subnet of the nodes, no equipment to set up | One node receives all the traffic of an address; after a node failure the clients must refresh their ARP cache |
| BGP     | Every speaker announces a route to the address to the BGP routers | A BGP session between the nodes and the routers         | The routers balance the traffic between the nodes; the loss of a session resets the connections                |

A pool is not reachable until an advertisement announces it: always declare an `L2Advertisement` or a `BGPAdvertisement`
together with an `IPAddressPool`. An advertisement with an empty `spec` announces every pool.

### Nodes with several networks

By default an address is announced from every network interface of the speaker nodes. When the nodes are attached to several
networks or VLAN:

- restrict the announcement with `spec.interfaces` (layer 2) and `spec.nodeSelectors` of the advertisement
- when the pool belongs to a network that is not the one of the default route of the nodes (VLAN or secondary interface), the nodes
  must forward the traffic received on this interface: set `gatewayConfig.ipForwarding` to `Global` in the cluster network operator
  configuration (`network.operator.openshift.io/cluster`), or enable the forwarding for this interface only with a `MachineConfig`.
  This setting is not managed by this chart
- the interfaces and VLAN themselves can be declared with the [cluster-nmstate](https://helm-repository.readthedocs.io/en/latest/charts/cluster-nmstate) chart

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
helm show chart startx/cluster-metallb
```

### 4. Install this chart

#### Default values

The default values keep every feature disabled and render nothing: the address pools are specific to each cluster and must be
provided in a values file.

- No MetalLB instance, no pool and no advertisement are created
- The operator subscription and namespace are managed separately via the `operator` and `project` sub-charts (both disabled by default)

```bash
# base configuration running default configuration
helm install cluster-metallb startx/cluster-metallb
```

#### Full deployment with operator and project

Helm cannot create a custom resource before its API exists: install the namespace and the operator first, approve its
InstallPlan (the subscription uses `installPlanApproval: Manual`), then enable the MetalLB instance, a pool and its advertisement.

```bash
# 1. namespace and operator
helm install cluster-metallb startx/cluster-metallb \
  --set project.enabled=true \
  --set operator.enabled=true
oc -n metallb-system get installplan
oc -n metallb-system patch installplan <name> --type merge -p '{"spec":{"approved":true}}'

# 2. MetalLB instance, layer 2 pool and advertisement, once the operator is running
cat > my-metallb.yaml <<EOF
metallb:
  enabled: true
ipAddressPools:
  enabled: true
  list:
    - name: default
      spec:
        addresses:
          - 192.0.2.240-192.0.2.250
l2Advertisements:
  enabled: true
  list:
    - name: default
      spec:
        ipAddressPools:
          - default
EOF
helm upgrade cluster-metallb startx/cluster-metallb -f my-metallb.yaml \
  --set project.enabled=true \
  --set operator.enabled=true
```

Replace `192.0.2.240-192.0.2.250` (documentation range) with free addresses of the network of your nodes. A service of type
`LoadBalancer` then gets an address of the pool; it selects a pool with the `metallb.io/address-pool` annotation and a given
address with the `metallb.io/loadBalancerIPs` annotation.

#### BGP deployment

The addresses are announced to a router with BGP and BFD; the password of the session is read from an external store
(see [External secrets](#external-secrets)):

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
metallb:
  enabled: true
ipAddressPools:
  enabled: true
  list:
    - name: default
      spec:
        addresses:
          - 198.51.100.0/27
bfdProfiles:
  enabled: true
  list:
    - name: default
      spec:
        transmitInterval: 300
        receiveInterval: 300
bgpPeers:
  enabled: true
  list:
    - name: router-1
      spec:
        myASN: 64512
        peerASN: 64500
        peerAddress: 192.0.2.1
        bfdProfile: default
        passwordSecret:
          name: bgp-router-1
bgpAdvertisements:
  enabled: true
  list:
    - name: default
      spec:
        ipAddressPools:
          - default
        peers:
          - router-1
secrets:
  enabled: true
  list:
    - name: bgp-router-1
      type: kubernetes.io/basic-auth
      externalSecret:
        enabled: true
        remoteRefs:
          password:
            key: ocp/metallb/bgp-router-1
            property: password
```

#### Other available values

- **startx** : MetalLB instance with the controller on the infra nodes and the operator on the infra nodes; a `startx` pool and its layer 2 advertisement are declared with a documentation range and left disabled (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-metallb/values-startx.yaml))
- **startx_noinfra** : same deployment without infra nodes placement (see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-metallb/values-startx_noinfra.yaml))

```bash
helm install cluster-metallb startx/cluster-metallb -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-metallb/values-startx.yaml
```

## ArgoCD deployment

### Deploy via ArgoCD Application

Deploy `cluster-metallb` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-metallb/examples/argocd/
oc apply -k .
```

| Application                | Wave   | Enabled flags                                | Destination      |
| -------------------------- | ------ | -------------------------------------------- | ---------------- |
| `cluster-metallb-project`  | `"1"`  | `project.enabled: true`, all others `false`  | `metallb-system` |
| `cluster-metallb-operator` | `"5"`  | `operator.enabled: true`, all others `false` | `metallb-system` |
| `cluster-metallb-app`      | `"10"` | `metallb.enabled: true`, all others `false`  | `metallb-system` |

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.
The `cluster-metallb-app` Application only starts MetalLB: the pools and their advertisements are specific to each cluster, add
`ipAddressPools` and `l2Advertisements` (or the BGP blocks) with your own addresses to its values and switch them to `enabled: true`.
The Subscription uses `installPlanApproval: Manual`: the `cluster-metallb-app` Application stays out of sync until the InstallPlan of
the operator is approved (`SkipDryRunOnMissingResource=true` lets the sync start before the MetalLB APIs exist).

## External secrets

The secrets of the `secrets` block (password of a BGP session) can come from an external store (Vault, AWS Secrets Manager...)
through the [External Secrets Operator](https://external-secrets.io) instead of the chart values. With
`externalSecret.enabled: true`, the chart renders an `ExternalSecret` producing the Secret of the same name and type in the
MetalLB namespace, so the `passwordSecret` of the BGP peer is unchanged. Without `externalSecret`, the chart renders the Secret
from `data`. Never commit a real password in a values file.

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
secrets:
  enabled: true
  list:
    - name: bgp-router-1
      type: kubernetes.io/basic-auth
      externalSecret:
        enabled: true
        remoteRefs:
          password:
            key: ocp/metallb/bgp-router-1
            property: password
```

An `externalSecret` block accepts `secretStoreRef` and `refreshInterval` (defaults: `externalSecretDefaults`),
`remoteRefs` (map of secret key to ESO `remoteRef`) and the raw ESO fields `data`, `dataFrom` and `template`.
Rendering fails when no store is set or when no key source is provided.

## Values dictionary

### context values dictionary

| Key                 | Default           | Description                                           |
| ------------------- | ----------------- | ----------------------------------------------------- |
| context.scope       | `myscope`         | Name of the global scope for this application         |
| context.cluster     | `default`         | Name of the cluster running this application          |
| context.environment | `myenv`           | Name of the environment (dev, factory, preprod, prod) |
| context.component   | `mycomponent`     | Component name of this application                    |
| context.app         | `default-metallb` | Application name                                      |
| context.version     | `4.22.0`          | Version name of this application                      |

### externalSecretDefaults values dictionary

| Key                                        | Default                  | Description                                                                        |
| ------------------------------------------ | ------------------------ | ---------------------------------------------------------------------------------- |
| externalSecretDefaults.apiVersion          | `external-secrets.io/v1` | API version of the ExternalSecret CRD                                              |
| externalSecretDefaults.refreshInterval     | `1h`                     | How often the Secret is refreshed from the external store                          |
| externalSecretDefaults.secretStoreRef.name | `""`                     | Name of the (Cluster)SecretStore, required as soon as a secret uses externalSecret |
| externalSecretDefaults.secretStoreRef.kind | `ClusterSecretStore`     | Kind of the store (`ClusterSecretStore` or `SecretStore`)                          |

### metallb values dictionary

| Key                                       | Default    | Description                                                                                              |
| ----------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------- |
| metallb.enabled                           | `false`    | Enable the creation of the `MetalLB` CR (sync-wave `15`)                                                 |
| metallb.hooked                            | `false`    | Activate the resource as a helm hook                                                                     |
| metallb.name                              | `metallb`  | Name of the instance (the operator only reconciles `metallb`)                                            |
| metallb.spec                              | `{}`       | Specification of the instance, rendered as is                                                            |
| metallb.spec.logLevel                     | `info`     | Verbosity of the controller and of the speakers (`all`, `debug`, `info`, `warn`, `error`, `none`)        |
| metallb.spec.nodeSelector                 | every node | Node selector of the speaker daemonset (only these nodes announce the addresses)                         |
| metallb.spec.speakerTolerations           |            | Tolerations of the speaker daemonset                                                                     |
| metallb.spec.controllerNodeSelector       |            | Node selector of the controller deployment                                                               |
| metallb.spec.controllerTolerations        |            | Tolerations of the controller deployment                                                                 |
| metallb.spec.loadBalancerClass            |            | Only handle the services requesting this load balancer class                                             |
| metallb.spec.speakerGratuitousARPInterval | disabled   | Interval of the periodic gratuitous ARP and unsolicited NDP announcements                                |
| metallb.spec.controllerConfig             |            | `priorityClassName`, `runtimeClassName`, `affinity`, `resources` and `annotations` of the controller pod |
| metallb.spec.speakerConfig                |            | `priorityClassName`, `runtimeClassName`, `affinity`, `resources` and `annotations` of the speaker pods   |

### ipAddressPools values dictionary

| Key                          | Default | Description                                                                                  |
| ---------------------------- | ------- | -------------------------------------------------------------------------------------------- |
| ipAddressPools.enabled       | `false` | Enable the creation of the `IPAddressPool` resources (sync-wave `30`)                        |
| ipAddressPools.hooked        | `false` | Activate the resources as helm hooks                                                         |
| ipAddressPools.list          | `[]`    | List of pools                                                                                |
| ipAddressPools.list[].name   |         | Name of the pool (required)                                                                  |
| ipAddressPools.list[].labels | `{}`    | Additional labels (matched by the `ipAddressPoolSelectors` of the advertisements)            |
| ipAddressPools.list[].spec   |         | Specification of the pool, rendered as is (required)                                         |
| ...spec.addresses            |         | IP ranges, as CIDR or `start-end` (required)                                                 |
| ...spec.autoAssign           | `true`  | Assign the addresses automatically; `false` reserves the pool for the services requesting it |
| ...spec.avoidBuggyIPs        | `false` | Never assign the addresses ending with `.0` or `.255`                                        |
| ...spec.serviceAllocation    |         | Reserve the pool: `priority`, `namespaces`, `namespaceSelectors`, `serviceSelectors`         |

### l2Advertisements values dictionary

| Key                            | Default            | Description                                                             |
| ------------------------------ | ------------------ | ----------------------------------------------------------------------- |
| l2Advertisements.enabled       | `false`            | Enable the creation of the `L2Advertisement` resources (sync-wave `40`) |
| l2Advertisements.hooked        | `false`            | Activate the resources as helm hooks                                    |
| l2Advertisements.list          | `[]`               | List of layer 2 advertisements                                          |
| l2Advertisements.list[].name   |                    | Name of the advertisement (required)                                    |
| l2Advertisements.list[].labels | `{}`               | Additional labels                                                       |
| l2Advertisements.list[].spec   | `{}`               | Specification, rendered as is (empty: every pool, node and interface)   |
| ...spec.ipAddressPools         | every pool         | Names of the announced pools                                            |
| ...spec.ipAddressPoolSelectors |                    | Label selectors of the announced pools                                  |
| ...spec.interfaces             | every interface    | Host interfaces the addresses are announced from                        |
| ...spec.nodeSelectors          | every speaker node | Nodes allowed to announce the addresses                                 |

### bgpPeers values dictionary

| Key                                          | Default            | Description                                                                               |
| -------------------------------------------- | ------------------ | ----------------------------------------------------------------------------------------- |
| bgpPeers.enabled                             | `false`            | Enable the creation of the `BGPPeer` resources (API `metallb.io/v1beta2`, sync-wave `35`) |
| bgpPeers.hooked                              | `false`            | Activate the resources as helm hooks                                                      |
| bgpPeers.list                                | `[]`               | List of BGP routers                                                                       |
| bgpPeers.list[].name                         |                    | Name of the peer (required)                                                               |
| bgpPeers.list[].labels                       | `{}`               | Additional labels                                                                         |
| bgpPeers.list[].spec                         |                    | Specification of the peer, rendered as is (required)                                      |
| ...spec.myASN                                |                    | Autonomous system number of the cluster side (required)                                   |
| ...spec.peerASN                              |                    | Autonomous system number of the router (or `dynamicASN`: `internal`, `external`)          |
| ...spec.peerAddress                          |                    | IP address of the router (or `interface` for an unnumbered session)                       |
| ...spec.peerPort                             | `179`              | TCP port of the router                                                                    |
| ...spec.passwordSecret                       |                    | Secret (`kubernetes.io/basic-auth`, key `password`) holding the session password          |
| ...spec.bfdProfile                           |                    | Name of the `BFDProfile` of the session                                                   |
| ...spec.holdTime, keepaliveTime, connectTime |                    | Timers of the session                                                                     |
| ...spec.ebgpMultiHop                         | `false`            | The router is several hops away                                                           |
| ...spec.nodeSelectors                        | every speaker node | Nodes establishing the session                                                            |
| ...spec.vrf                                  |                    | Host VRF used to establish the session                                                    |

### bgpAdvertisements values dictionary

| Key                             | Default            | Description                                                                       |
| ------------------------------- | ------------------ | --------------------------------------------------------------------------------- |
| bgpAdvertisements.enabled       | `false`            | Enable the creation of the `BGPAdvertisement` resources (sync-wave `40`)          |
| bgpAdvertisements.hooked        | `false`            | Activate the resources as helm hooks                                              |
| bgpAdvertisements.list          | `[]`               | List of BGP advertisements                                                        |
| bgpAdvertisements.list[].name   |                    | Name of the advertisement (required)                                              |
| bgpAdvertisements.list[].labels | `{}`               | Additional labels                                                                 |
| bgpAdvertisements.list[].spec   | `{}`               | Specification, rendered as is (empty: every pool to every peer)                   |
| ...spec.ipAddressPools          | every pool         | Names of the announced pools                                                      |
| ...spec.peers                   | every peer         | Names of the `BGPPeer` receiving the routes                                       |
| ...spec.aggregationLength       | `32`               | Prefix length of the IPv4 routes (`aggregationLengthV6`, default `128`, for IPv6) |
| ...spec.communities             |                    | BGP communities of the routes, as values or `Community` aliases                   |
| ...spec.localPref               |                    | BGP local preference of the routes                                                |
| ...spec.nodeSelectors           | every speaker node | Nodes announced as next hop                                                       |

### bfdProfiles and communities values dictionary

| Key                 | Default | Description                                                                                                                                                        |
| ------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| bfdProfiles.enabled | `false` | Enable the creation of the `BFDProfile` resources (sync-wave `30`)                                                                                                 |
| bfdProfiles.hooked  | `false` | Activate the resources as helm hooks                                                                                                                               |
| bfdProfiles.list    | `[]`    | List of profiles: `name`, `labels` and `spec` (`transmitInterval`, `receiveInterval`, `detectMultiplier`, `echoMode`, `echoInterval`, `passiveMode`, `minimumTtl`) |
| communities.enabled | `false` | Enable the creation of the `Community` resources (sync-wave `30`)                                                                                                  |
| communities.hooked  | `false` | Activate the resources as helm hooks                                                                                                                               |
| communities.list    | `[]`    | List of resources: `name`, `labels` and `spec.communities` (list of `{name, value}` aliases)                                                                       |

### secrets values dictionary

| Key                           | Default            | Description                                                                          |
| ----------------------------- | ------------------ | ------------------------------------------------------------------------------------ |
| secrets.enabled               | `false`            | Enable the creation of the secrets (sync-wave `1`)                                   |
| secrets.list                  | `[]`               | List of secrets created in the MetalLB namespace                                     |
| secrets.list[].name           |                    | Name of the secret (required)                                                        |
| secrets.list[].type           | `Opaque`           | Type of the secret (`kubernetes.io/basic-auth` for a BGP password)                   |
| secrets.list[].labels         | `{}`               | Additional labels                                                                    |
| secrets.list[].data           |                    | Key/value pairs rendered as `stringData` (required without `externalSecret`)         |
| secrets.list[].externalSecret | `{enabled: false}` | Source the secret from an external store (see [External secrets](#external-secrets)) |

### project values dictionary

| Key                                   | Default                                      | Description                                                                                                    |
| ------------------------------------- | -------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| project.enabled                       | `false`                                      | Enable the project sub-chart (MetalLB namespace)                                                               |
| project.project.name                  | `metallb-system`                             | Namespace of the operator and of every MetalLB resource                                                        |
| project.project.display_name          | `Operator MetalLB`                           | Display name of the namespace                                                                                  |
| project.project.description           | `MetalLB load balancer configured by STARTX` | Description of the namespace                                                                                   |
| project.project.additionalAnnotations |                                              | String of annotations, set it to `openshift.io/node-selector: ""` when the cluster has a default node selector |

### operator values dictionary

| Key                                                | Default            | Description                                                                          |
| -------------------------------------------------- | ------------------ | ------------------------------------------------------------------------------------ |
| operator.enabled                                   | `false`            | Enable the operator sub-chart (subscription and operator group)                      |
| operator.subscription.name                         | `metallb-operator` | Name of the Subscription and of the package                                          |
| operator.subscription.namespace                    | `metallb-system`   | Namespace of the operator                                                            |
| operator.subscription.version                      | `4.22.0`           | Version of the operator (used with `csv` for startingCSV)                            |
| operator.subscription.operator.channel             | `stable`           | Channel of the subscription                                                          |
| operator.subscription.operator.installPlanApproval | `Manual`           | Approval mode of the InstallPlans                                                    |
| operator.subscription.operator.source.name         | `redhat-operators` | Catalog source of the operator                                                       |
| operator.subscription.operator.config.infra        | `false`            | Run the operator on infra nodes                                                      |
| operator.operatorGroup.enabled                     | `true`             | Create the OperatorGroup of the namespace                                            |
| operator.operatorGroup.target                      | `all-ns`           | OperatorGroup without target namespace (only install mode supported by the operator) |

## History

| Release  | Date       | Description            |
| -------- | ---------- | ---------------------- |
| 21.3.361 | 2026-11-17 | Initial chart creation |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |

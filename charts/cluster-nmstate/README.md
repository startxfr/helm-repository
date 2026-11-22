# ![cluster-nmstate](https://helm-repository.readthedocs.io/en/latest/img/cluster-nmstate.svg "Cluster Chart : NMState") Cluster Chart : NMState
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--nmstate-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+nmstate+startx)

Configure the NMState network operator for declarative node-level network interface configuration.

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
helm show chart startx/cluster-nmstate
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics:

- Deploy the **NMState CR** (`nmstate/nmstate`) to activate the operator daemonset on all nodes
- The operator subscription and namespace are managed separately via the `operator` and `project` sub-charts (both disabled by default)

```bash
# base configuration running default configuration
helm install cluster-nmstate startx/cluster-nmstate
```

#### Full deployment with operator and project

Enable the operator subscription and project namespace alongside the NMState CR:

```bash
helm install cluster-nmstate startx/cluster-nmstate \
  --set project.enabled=true \
  --set operator.enabled=true
```

#### Other available values

- **startx** : NMState operator with full STARTX context (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nmstate/values-startx.yaml))

```bash
helm install cluster-nmstate startx/cluster-nmstate -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nmstate/values-startx.yaml
```

## Values files

Example values files shipped with the chart, to use with `helm install -f <file>` :

- **startx** : STARTX cluster configuration, see values.yaml for the parameters (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nmstate/values-startx.yaml))
- `examples/argocd/` : 5 example manifest(s) (see the ArgoCD or usage sections)

```bash
helm install cluster-nmstate startx/cluster-nmstate -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nmstate/values-startx.yaml
```

## Deploy with ArgoCD

### Deploy via ArgoCD Application

Deploy `cluster-nmstate` using three dedicated ArgoCD Applications - one per concern - all sharing the same AppProject:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-nmstate/examples/argocd/
oc apply -k .
```

The automated sync policy ensures ArgoCD reconciles each concern independently whenever the chart or values drift from the desired state.

## Values dictionary

### context values dictionary

| Key                 | Default           | Description                                                  |
| ------------------- | ----------------- | ------------------------------------------------------------ |
| context.scope       | `myscope`         | Name of the global scope for this application                |
| context.cluster     | `default`         | Name of the cluster running this application                 |
| context.environment | `myenv`           | Name of the environment (dev, factory, preprod, prod)        |
| context.component   | `mycomponent`     | Component name of this application                           |
| context.app         | `default-nmstate` | Application name                                             |
| context.version     | `4.21.0`          | Version name of this application                             |

### nmstate values dictionary

| Key             | Default   | Description                                                                    |
| --------------- | --------- | ------------------------------------------------------------------------------ |
| nmstate.enabled | `true`    | Enable the creation of the NMState CR to activate the operator                 |
| nmstate.hooked  | `false`   | Deploy as a Helm/ArgoCD post-sync hook                                         |
| nmstate.name    | `nmstate` | Name of the NMState instance (must be `nmstate` for the operator to reconcile) |

### nncp values dictionary

| Key               | Default                  | Description                                               |
| ----------------- | ------------------------ | --------------------------------------------------------- |
| nncp.enabled      | `false`                  | Enable the deployment of a NodeNetworkConfigurationPolicy |
| nncp.hooked       | `false`                  | Deploy as a Helm/ArgoCD post-sync hook                    |
| nncp.name         | `default-network-policy` | Name of the NodeNetworkConfigurationPolicy                |
| nncp.nodeSelector | `{}`                     | Node selector to target specific nodes (empty = all)      |
| nncp.desiredState | `interfaces: []`         | Desired network state in NMState YAML format              |

### nads values dictionary

| Key                     | Default   | Description                                                                        |
| ----------------------- | --------- | ---------------------------------------------------------------------------------- |
| nads.enabled            | `false`   | Enable the creation of the NetworkAttachmentDefinition list                        |
| nads.hooked             | `false`   | Deploy the resources as a Helm/ArgoCD post-sync hook                               |
| nads.list               | `[]`      | List of NetworkAttachmentDefinition to create                                      |
| nads.list[].name        |           | Name of the NetworkAttachmentDefinition                                            |
| nads.list[].namespace   | `default` | Namespace of the NetworkAttachmentDefinition (`default` = usable from every namespace) |
| nads.list[].annotations | `{}`      | Additional annotations (ex: `k8s.v1.cni.cncf.io/resourceName` for SR-IOV networks) |
| nads.list[].config      |           | CNI configuration (YAML/JSON text or map), stored as the JSON string expected by Multus |

A network attachment usually completes a NodeNetworkConfigurationPolicy: the policy creates the bridge
or the VLAN interface on the nodes, the network attachment exposes it to the pods and virtual machines
(the attachments are synced after the policies, ArgoCD wave 35). The `config` field accepts any CNI
type (bridge, macvlan, ipvlan, sriov, ovn-k8s-cni-overlay...); its `name` defaults to the resource name.

```yaml
nncp:
  enabled: true
  name: br1-policy
  desiredState: |
    interfaces:
      - name: br1
        type: linux-bridge
        state: up
        bridge:
          options:
            stp:
              enabled: false
          port:
            - name: bond1
nads:
  enabled: true
  list:
    - name: br1-network
      config: |
        cniVersion: "0.3.1"
        type: bridge
        bridge: br1
        macspoofchk: true
        ipam: {}
```

## History

| Release | Date       | Description                                             |
| ------- | ---------- | ------------------------------------------------------- |
| 21.3.3  | 2026-06-16 | Initial chart creation for NMState operator on OCP 4.21 |
| 21.3.4  | 2026-06-17 | Improve cluster-nmstate options                         |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-08 | Add the NetworkAttachmentDefinition list (nads) |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |

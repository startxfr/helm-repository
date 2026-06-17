# ![cluster-nmstate](https://helm-repository.readthedocs.io/en/latest/img/cluster-nmstate.svg "Cluster Chart : NMState") Cluster Chart : NMState
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--nmstate-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+nmstate+startx)

Configure the NMState network operator for declarative node-level network interface configuration.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use theses resources.

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

```bash
helm install cluster-nmstate startx/cluster-nmstate
```

## Default values

Complete deployment of a project with the following characteristics:

- Deploy the **NMState CR** (`nmstate/nmstate`) to activate the operator daemonset on all nodes
- The operator subscription and namespace are managed separately via the `operator` and `project` sub-charts (both disabled by default)

```bash
# base configuration running default configuration
helm install cluster-nmstate startx/cluster-nmstate
```

## Others values availables

- **startx** : NMState operator with full STARTX context (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nmstate/values-startx.yaml))

```bash
helm install cluster-nmstate startx/cluster-nmstate -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nmstate/values-startx.yaml
```

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

## History

| Release | Date       | Description                                             |
| ------- | ---------- | ------------------------------------------------------- |
| 21.3.3  | 2026-06-16 | Initial chart creation for NMState operator on OCP 4.21 |
| 21.3.3 | 2026-06-17 | Initialise nmstate chart
| 21.3.3 | 2026-06-17 | New chart nmstate
| 21.3.3 | 2026-06-17 | Release nmstate chart

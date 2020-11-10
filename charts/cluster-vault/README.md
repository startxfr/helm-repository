# STARTX helm : cluster-vault

This helm chart is used to create a deployment of a vault, helm based, deployment of Hashicorp Vault solution.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration
state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-vault
```

### 4. Install this chart

```bash
helm install startx/cluster-vault
```

## Values files

### Default values file (values.yaml)

Deployment of a vault environment with the following characteristics :

- 1 **project:** named **startx-vault** with the following properties
  - **rbac** set to :
    - **edit** for service account **startx-vault**
    - **admin** for service account **startx-vault-agent-injector**
  - **limitRange** disabled
  - **quotas** disabled
  - **networkPolicy** disabled
- 1 **helm:** named **vault** configured with
  - container image **vault:1.4.0** for server
  - container image **hashicorp/vault-k8s:0.3.0** for injector
  - container image **vault:1.4.0** for agent
- 1 **route:** named **startx-vault**

```bash
# base configuration running default configuration
helm install startx/cluster-vault
```

### Startx values file (values-startx.yaml)

Deployment of a vault environment with the following characteristics :

- 1 **project:** named **startx-vault** with the following properties
  - **rbac** set to :
    - **view** for group **dev**
    - **admin** for group **devops**
    - **admin** for group **ops**
    - **edit** for service account **startx-vault**
    - **admin** for service account **startx-vault-agent-injector**
  - **limitRange** enabled
  - **quotas** enabled
  - **networkPolicy** enabled
- 1 **helm:** named **vault** configured with
  - container image **vault:1.4.0** for server
  - container image **hashicorp/vault-k8s:0.3.0** for injector
  - container image **vault:1.4.0** for agent
- 1 **route:** named **startx-vault**

```bash
# base configuration running startx configuration
helm install startx/cluster-vault -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-vault/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.17  | 2020-11-04 | Create chart cluster-vault from cluster-3scale (removed)
| 0.3.18  | 2020-11-04 | Use hashicorp vault helm dependency version 0.7.0
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.29  | 2020-11-07 | Improve NOTES output and move to 0.3.25 dependencies
| 0.3.47  | 2020-11-08 | Update dependency to 0.3.45 release
| 0.3.50  | 2020-11-08 | publish stable update for the full repository
| 0.3.53  | 2020-11-08 | publish stable update for the full repository
| 0.3.59  | 2020-11-08 | publish stable update for the full repository
| 0.3.61  | 2020-11-09 | Improve repository documentation and new chart for kubevirt management
| 0.3.73  | 2020-11-10 | publish stable update for the full repository
| 0.3.77  | 2020-11-10 | publish stable update for the full repository
| 0.3.83  | 2020-11-10 | publish stable update for the full repository
| 0.3.93  | 2020-11-10 | Move to 0.3.93 dependencies for all cluster-xxx charts in the startx repository

# STARTX helm : cluster-vault

This helm chart is used to create a deployment of a vault, helm based, deployment of Hashicorp Vault solution.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration
state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### Get information about this chart

```bash
helm show chart startx/cluster-vault
```

### Install this chart

```bash
helm install startx/cluster-vault
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **startx-vault** with the following properties
  - 1 **LimitRange:** defined for this projet
  - 1 **Quotas:** defined for this projet
  - 3 **RBAC:** allowing **mygroup_example** to **edit** resources
- 1 **operator:** named **vault-operator** configured with
  - The **threescale-2.9** channel
  - The **0.6.0** version
  - Deployed under the **openshift-operators** project
  - The **manager** deployed
- 1 **Secret:** named **startx-vault-rhn** that hold rhn credentials used fo image pulling

```bash
# base configuration running default configuration
helm install startx/cluster-vault
```

## Others values availables

- **startx** : Startx vault cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-vault/values-startx.yaml))

```bash
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
| 0.3.35  | 2020-11-07 | Debug rbac role property

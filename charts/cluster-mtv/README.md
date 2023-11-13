# Cluster MTV

This helm chart is used to deploy Migration Toolkit for Virtualisation operator to help you drive migration of your VM workloads into a Kubevirt enabled kubernetes cluster.
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
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-mtv
```

### 4. Install this chart

```bash
helm install cluster-mtv startx/cluster-mtv
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-mtv startx/cluster-mtv
```

## Others values availables

- **startx** : MTV operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mtv/values-startx.yaml))

```bash
helm install cluster-mtv startx/cluster-mtv -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-mtv/values-startx.yaml
```

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 12.36.1 | 2023-09-29 | Initialize the MTV cluster-service chart
| 12.36.2 | 2023-09-29 | Implement version 2.5.0 of the MTV operator with ForkliftController support
| 12.36.3 | 2023-09-30 | Enable the OperatorGroup for operator deployment
| 12.36.4 | 2023-09-30 | Debug naming for the forklift resource
| 12.36.9 | 2023-10-01 | publish stable update for the full repository
| 12.36.36 | 2023-10-11 | publish stable update for the full repository
| 12.36.49 | 2023-11-13 | publish stable update for the full repository

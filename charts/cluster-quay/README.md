# STARTX helm : cluster-quay

This helm chart is used to create an operator based deployment of Quay Enterprise registry.
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
helm show chart startx/cluster-quay
```

### Install this chart

```bash
helm install startx/cluster-quay
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-quay
```

## Others values availables

- **startx** : Startx 3scale cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-quay/values-startx.yaml))

```bash
helm install startx/cluster-quay -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-quay/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.17  | 2020-11-04 | Create chart cluster-quay from cluster-3scale
| 0.3.18  | 2020-11-06 | Add quay template to configure QuayEcosystem deployment
| 0.3.20  | 2020-11-06 | Add v prefix to the operator version
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.29  | 2020-11-07 | Improve NOTES output and move to 0.3.25 dependencies
| 0.3.33  | 2020-11-07 | publish stable update for the full repository
| 0.3.35  | 2020-11-07 | Debug rbac role property
| 0.3.35  | 2020-11-07 | Debug

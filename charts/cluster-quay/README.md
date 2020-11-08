# STARTX helm : cluster-quay

This helm chart is used to create an operator based deployment of Quay Enterprise registry.
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
helm show chart startx/cluster-quay
```

### 4. Install this chart

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
| 0.3.17  | 2020-11-04 | Create chart cluster-quay from cluster-3scale (removed)
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.29  | 2020-11-07 | Improve NOTES output and move to 0.3.25 dependencies
| 0.3.35  | 2020-11-07 | Debug rbac role property
| 0.3.37  | 2020-11-07 | Improve helm hook ordering cordinated with dependencies
| 0.3.38  | 2020-11-08 | Improve cluster-quay options

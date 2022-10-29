# Cluster CertManager

This helm chart is used to deploy Cert-Manager handled by an operator to configure Certificate management at the cluster level.
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
helm show chart startx/cluster-certmanager
```

### 4. Install this chart

```bash
helm install cluster-certmanager startx/cluster-certmanager
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-certmanager startx/cluster-certmanager
```

## Others values availables

- **startx** : CertManager operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-certmanager/values-startx.yaml))

```bash
helm install cluster-certmanager startx/cluster-certmanager -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-certmanager/values-startx.yaml
```

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 11.7.18 | 2022-10-28 | Create chart cluster-certmanager from cluster-ptp
| 11.7.18 | 2022-10-28 | Create chart cluster-certmanager from cluster-ptp
| 11.7.31 | 2022-10-29 | publish stable update for the full repository
| 11.7.33 | 2022-10-29 | Update all startx packages to release 11.7.33

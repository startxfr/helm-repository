# Cluster Local storage

This helm chart is used to configure local storage at the cluster level.
This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedlocalstorage.io#cluster-helm-charts) that doesn't necessarily deployment pod but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedlocalstorage.io) for
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
helm show chart startx/cluster-localstorage
```

### 4. Install this chart

```bash
helm install startx/cluster-localstorage
```

## Default values

Complete deployment of a project with the following characteristics :

xxxx to do xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-localstorage
```

## Others values availables

- **startx** : Startx local storage cluster wide service configuration using localstorage operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-localstorage/values-startx.yaml))

```bash
helm install startx/cluster-localstorage -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-localstorage/values-startx.yaml
```

## History

| Release | Date       | Description                                        |
| ------- | ---------- | -------------------------------------------------- |
| 9.8.76  | 2021-12-19 | Create chart cluster-localstorage from cluster-ocs |
| 9.8.81 | 2021-12-20 | Update the storage context

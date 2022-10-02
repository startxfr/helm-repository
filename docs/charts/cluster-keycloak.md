# Cluster keycloak

This helm chart is used to deploy Keycloak instances managed by a dedicated operator.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

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
helm show chart startx/cluster-keycloak
```

### 4. Install this chart

```bash
helm install startx/cluster-keycloak
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-keycloak
```

## Others values availables

- **startx** : Keycloak operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-keycloak/values-startx.yaml))

```bash
helm install startx/cluster-keycloak -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-keycloak/values-startx.yaml
```

## History

| Release | Date       | Description                                    |
| ------- | ---------- | ---------------------------------------------- |
| 0.3.179 | 2021-02-10 | Create chart cluster-keycloak from cluster-ptp |
| 0.3.179 | 2021-02-10 | Improve cluster-keycloak options               |
| 0.3.181 | 2021-02-11 | publish stable update for the full repository  |

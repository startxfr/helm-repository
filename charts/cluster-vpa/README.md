# STARTX helm : cluster-vpa

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
helm show chart startx/cluster-vpa
```

### 4. Install this chart

```bash
helm install startx/cluster-vpa
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-vpa
```

## Others values availables

- **startx** : Keycloak operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-vpa/values-startx.yaml))

```bash
helm install startx/cluster-vpa -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-vpa/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.179 | 2021-02-10 | Create chart cluster-vpa from cluster-ptp
| 0.3.179 | 2021-02-10 | Improve cluster-vpa options
| 0.3.179  | 2021-02-11 | Create chart cluster-vpa from cluster-keycloak

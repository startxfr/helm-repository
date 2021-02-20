# STARTX helm : cluster-ptp

This helm chart is used to deploy Precision Time Protocol handled by an operator to configure node NTP configuration.
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
helm show chart startx/cluster-ptp
```

### 4. Install this chart

```bash
helm install startx/cluster-ptp
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-ptp
```

## Others values availables

- **startx** : PTP operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ptp/values-startx.yaml))

```bash
helm install startx/cluster-ptp -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ptp/values-startx.yaml
```

## History

| Release | Date       | Description                                |
| ------- | ---------- | ------------------------------------------ |
| 0.3.179 | 2021-02-09 | Create chart cluster-ptp from cluster-quay |
| 0.3.187 | 2021-02-13 | Align cluster chart release to 0.3.187     |
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts

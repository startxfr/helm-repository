# Cluster nexus

This helm chart is used to deploy Nexus instances managed by a dedicated operator.
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
helm show chart startx/cluster-nexus
```

### 4. Install this chart

```bash
helm install startx/cluster-nexus
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-nexus
```

## Others values availables

- **startx** : Nexus operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nexus/values-startx.yaml))

```bash
helm install startx/cluster-nexus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-nexus/values-startx.yaml
```

## History

| Release | Date       | Description                                                                  |
| ------- | ---------- | ---------------------------------------------------------------------------- |
| 0.3.179 | 2021-02-10 | Create chart cluster-nexus from cluster-ptp                                  |
| 0.3.187 | 2021-02-13 | Align cluster chart release to 0.3.187                                       |
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189                                 |
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts                  |
| 0.3.201 | 2021-02-20 | Update icon and image for charts                                             |
| 0.3.203 | 2021-02-21 | Upgrade chart release informations                                           |
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205                                    |
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                              |
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215                                           |
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming                                      |
| 0.3.305 | 2021-06-04 | publish stable update for the full repository                                |
| 0.3.343 | 2021-06-06 | publish stable update for the full repository                                |
| 0.3.381 | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377 |
| 0.3.390 | 2021-06-12 | Prepare 0.4.0 release
| 0.3.423 | 2021-06-17 | Prepare the v0.4 release. Stable aligned version of all charts

# Cluster gitlab

This helm chart is used to deploy Gitlab instances managed by a dedicated operator.
This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deployment pod but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io)  for
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
helm show chart startx/cluster-gitlab
```

### 4. Install this chart

```bash
helm install startx/cluster-gitlab
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-gitlab
```

## Others values availables

- **startx** : Gitlab operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-gitlab/values-startx.yaml))

```bash
helm install startx/cluster-gitlab -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-gitlab/values-startx.yaml
```

## History

| Release | Date       | Description                                                                                    |
| ------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 9.8.81 | 2021-12-20 | Create the gitlab chart
| 9.8.82 | 2022-02-23 | move to gitlab deployment from helm chart version 5.8.1
| 9.8.91 | 2022-03-06 | publish stable update for the full repository
| 9.8.92 | 2022-03-07 | Improve cluster-gitlab options
| 9.8.93 | 2022-03-07 | Enable conditionnal loading of charts dependencies
| 9.8.109 | 2022-04-26 | Update startx chart dependencies to version 9.8.107
| 9.8.99 | 2022-04-27 | Update llcalstorage, logging and elastic for OCP 4.8 and bellow 4.9.11

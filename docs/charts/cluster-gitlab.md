# Cluster gitlab

This helm chart is used to deploy Gitlab instances managed by a dedicated operator.
This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deployment pod but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

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
helm show chart startx/cluster-gitlab
```

### 4. Install this chart

```bash
helm install cluster-gitlab startx/cluster-gitlab
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-gitlab startx/cluster-gitlab
```

## Others values availables

- **startx** : Gitlab operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-gitlab/values-startx.yaml))

```bash
helm install cluster-gitlab startx/cluster-gitlab -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-gitlab/values-startx.yaml
```

## History

| Release | Date       | Description                                             |
| ------- | ---------- | ------------------------------------------------------- |
| 9.8.81  | 2021-12-20 | Create the gitlab chart                                 |
| 9.8.82  | 2022-02-23 | move to gitlab deployment from helm chart version 5.8.1 |
| 9.8.91  | 2022-03-06 | publish stable update for the full repository           |
| 9.8.92  | 2022-03-07 | Improve cluster-gitlab options                          |
| 9.8.93  | 2022-03-07 | Enable conditionnal loading of charts dependencies      |
| 9.8.109 | 2022-04-26 | Update startx chart dependencies to version 9.8.107     |
| 9.8.110 | 2022-04-27 | Stable release for all charts                           |
| 9.8.111 | 2022-04-27 | publish stable update for the full repository
| 9.8.114 | 2022-04-27 | publish stable update for the full repository
| 9.8.215 | 2022-05-06 | Upgrade startx chart dependencies to version 9.8.211
| 9.8.230 | 2022-05-06 | Stable full repository
| 9.8.231 | 2022-05-06 | Debug basic chart dependencies
| 9.8.233 | 2022-05-06 | publish stable update for the full repository
| 9.8.239 | 2022-05-17 | Remove default csv from all charts. global release 9.8.239
| 9.8.253 | 2022-05-29 | Align all charts dependencies to release 9.8.251
| 9.8.277 | 2022-05-31 | publish stable update for the full repository
| 9.15.1 | 2022-06-01 | Align all chart for Openshift 4.9.15
| 9.15.2 | 2022-06-01 | Align all charts to release 9.15.1
| 9.15.3 | 2022-06-01 | Align all charts to release 9.15.3
| 10.12.1 | 2022-06-01 | Align all charts to release 10.12.1
| 10.12.3 | 2022-06-01 | publish stable update for the full repository
| 10.12.4 | 2022-06-01 | Align all charts to release 10.12.4
| 10.12.5 | 2022-06-01 | publish stable update for the full repository
| 10.12.22 | 2022-06-04 | Align all chart to release version 10.12.22
| 10.12.23 | 2022-06-04 | Basi chart dependencies upgraded to version 10.12.5
| 10.12.29 | 2022-06-17 | Align all charts to version 10.12.29
| 10.12.29 | 2022-06-17 | publish stable update for the full repository
| 10.12.30 | 2022-06-17 | Improved logo and global documentation
| 10.12.33 | 2022-06-17 | publish stable update for the full repository
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31
| 10.12.39 | 2022-06-18 | Align all chart to revision 10.12.39
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41
| 10.12.46 | 2022-06-18 | publish stable update for the full repository
| 10.12.49 | 2022-06-18 | publish stable update for the full repository
| 10.12.53 | 2022-06-18 | publish stable update for the full repository
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts
| 10.12.72 | 2022-07-02 | Common release
| 10.12.77 | 2022-07-02 | Stable for clients
| 10.12.81 | 2022-07-02 | publish stable update for the full repository
| 10.12.97 | 2022-07-03 | publish stable update for the full repository
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart
| 11.5.3 | 2022-09-17 | Align all STARTX charts to release 11.5.3
| 11.7.1 | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release
| 11.7.3 | 2022-10-02 | publish stable update for the full repository
| 11.7.9 | 2022-10-02 | publish stable update for the full repository

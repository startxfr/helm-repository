# Cluster ArgoCD

This helm chart is used to configure code ready argocd via it's operator and deploy a VM into Openshift.
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
helm show chart startx/cluster-argocd
```

### 4. Install this chart

```bash
helm install startx/cluster-argocd
```

## Default values

xxxx  to do xxxxxxxx

## History

| Release | Date       | Description                                                                                                |
| ------- | ---------- | ---------------------------------------------------------------------------------------------------------- |
| 0.3.59  | 2020-11-09 | Create chart cluster-argocd from cluster-argocd                                                            |
| 0.3.61  | 2020-11-09 | Add deployment of Hyperconverged cluster via HCO operator and multiple VM via the VirtualMachine resources |
| 0.3.93  | 2020-11-10 | Move to 0.3.93 dependencies for all cluster-xxx charts in the startx repository                            |
| 0.3.105 | 2020-11-11 | Update cluster-xxx charts dependencies to 0.3.103 release                                                  |
| 0.3.117 | 2020-11-12 | Move to 0.3.115 basic chart dependencies                                                                   |
| 0.3.135 | 2020-11-23 | Improve documentation for all examples charts                                                              |
| 0.3.141 | 2020-11-24 | publish stable update for the full repository                                                              |
| 0.3.151 | 2021-01-23 | Upgrade to OCP version 4.6.0                                                                               |
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                                                        |
| 0.3.153 | 2021-01-23 | publish stable update for the full repository                                                              |
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies                                                                             |
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments                                |
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies                                                                               |
| 0.3.187 | 2021-02-13 | Align cluster chart release to 0.3.187                                                                     |
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189                                                               |
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts                                                |
| 0.3.201 | 2021-02-20 | Update icon and image for charts                                                                           |
| 0.3.203 | 2021-02-21 | Upgrade chart release informations                                                                         |
| 0.3.203 | 2021-04-09 | Create chart cluster-argocd from cluster-argocd                                                            |
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205                                                                  |
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                                                            |
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215                                                                         |
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming                                                                    |
| 0.3.305 | 2021-06-04 | publish stable update for the full repository                                                              |
| 0.3.343 | 2021-06-06 | publish stable update for the full repository                                                              |
| 0.3.381 | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377                               |
| 0.3.390 | 2021-06-12 | Prepare 0.4.0 release
| 0.3.423 | 2021-06-17 | Prepare the v0.4 release. Stable aligned version of all charts
| 0.3.431 | 2021-07-05 | Move to dependencies 1.18.0
| 0.3.480 | 2021-08-03 | publish stable update for the full repository
| 0.3.998 | 2021-08-04 | publish stable update for the full repository
| 0.3.999 | 2021-08-04 | Release stable version 0.3.999 align with ocp 4.7.13
| 7.22.1 | 2021-08-04 | Move to release 7.22.1 to align versionning with ocp release cycle
| 7.22.2 | 2021-08-04 | Move helm dependencies to a 7.x.x release model
| 7.22.3 | 2021-08-05 | publish stable update for the full repository
| 7.22.5 | 2021-08-05 | publish stable update for the full repository

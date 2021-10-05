# Cluster ACM

This helm chart must have a description

## Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

## Get information about this chart

```bash
helm show chart startx/cluster-acm
```

## Install this chart

```bash
helm install startx/cluster-acm
```

## History

| Release | Date       | Description                                                                  |
| ------- | ---------- | ---------------------------------------------------------------------------- |
| 0.0.1   | 2021-01-23 | Create chart cluster-acm from _sample_                                       |
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                          |
| 0.3.153 | 2021-01-23 | publish stable update for the full repository                                |
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies                                               |
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments  |
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies                                                 |
| 0.3.177 | 2021-01-26 | Remove example from cluster-acm                                              |
| 0.3.187 | 2021-02-13 | Align cluster chart release to 0.3.187                                       |
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189                                 |
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts                  |
| 0.3.201 | 2021-02-20 | Update icon and image for charts                                             |
| 0.3.203 | 2021-02-21 | Upgrade chart release informations                                           |
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205                                    |
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                              |
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215                                           |
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming                                      |
| 0.3.226 | 2021-06-02 | Update RHACM operator to version 2.2.3                                       |
| 0.3.305 | 2021-06-04 | publish stable update for the full repository                                |
| 0.3.343 | 2021-06-06 | publish stable update for the full repository                                |
| 0.3.381 | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377 |
| 0.3.382 | 2021-06-10 | Debug the availabilityConfig value                                           |
| 0.3.390 | 2021-06-12 | Prepare 0.4.0 release
| 0.3.423 | 2021-06-17 | Prepare the v0.4 release. Stable aligned version of all charts
| 0.3.424 | 2021-06-19 | Update acm package
| 0.3.425 | 2021-06-20 | Debug package
| 0.3.431 | 2021-07-05 | Move to dependencies 1.18.0
| 0.3.480 | 2021-08-03 | publish stable update for the full repository
| 0.3.998 | 2021-08-04 | publish stable update for the full repository
| 0.3.999 | 2021-08-04 | Release stable version 0.3.999 align with ocp 4.7.13
| 7.22.1 | 2021-08-04 | Move to release 7.22.1 to align versionning with ocp release cycle
| 7.22.2 | 2021-08-04 | Move helm dependencies to a 7.x.x release model
| 7.22.3 | 2021-08-05 | publish stable update for the full repository
| 7.22.5 | 2021-08-05 | publish stable update for the full repository
| 7.22.6 | 2021-08-05 | Stable version for chart dependencies
| 7.22.7 | 2021-08-05 | Stable for OCP version 4.7.22
| 7.22.12 | 2021-09-23 | publish stable update for the full repository
| 7.22.21 | 2021-10-05 | ServiceAccount and ImagePullSecrets managed by project chart

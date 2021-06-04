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

| Release | Date       | Description                                                                 |
| ------- | ---------- | --------------------------------------------------------------------------- |
| 0.0.1   | 2021-01-23 | Create chart cluster-acm from _sample_                                      |
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                         |
| 0.3.153 | 2021-01-23 | publish stable update for the full repository                               |
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies                                              |
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments |
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies                                                |
| 0.3.177 | 2021-01-26 | Remove example from cluster-acm                                             |
| 0.3.187 | 2021-02-13 | Align cluster chart release to 0.3.187                                      |
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189                                |
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts                 |
| 0.3.201 | 2021-02-20 | Update icon and image for charts                                            |
| 0.3.203 | 2021-02-21 | Upgrade chart release informations                                          |
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205                                   |
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                             |
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215                                          |
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming                                     |
| 0.3.226 | 2021-06-02 | Update RHACM operator to version 2.2.3                                      |
| 0.3.303 | 2021-06-02 | Update documentation and align all charts to release 0.3.303                |
| 0.3.304 | 2021-06-03 | update startx values configuration                                          |
| 0.3.311 | 2021-06-03 | Align cluster chart to version 0.3.311                                      |
| 0.3.312 | 2021-06-03 | Stable charts                                                               |
| 0.3.305 | 2021-06-04 | publish stable update for the full repository
| 0.3.315 | 2021-06-04 | Stable documentation for all charts
| 0.3.317 | 2021-06-04 | Improve documentation

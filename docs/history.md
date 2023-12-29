# Release history

## version 15.0.x (champagnac)

_The objectif of this release is to stabilize the full repository content and offer a stable release of the helm charts for the Openshift Container platform version 4.15.x version._

## version 14.0.x (chamberet)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.14 release](https://docs.openshift.com/container-platform/4.14)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.14.x cluster

## version 13.0.x (chanac)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.13 release](https://docs.openshift.com/container-platform/4.13)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.13.x cluster

## version 12.0.x (chastang)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.12 release](https://docs.openshift.com/container-platform/4.12)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.12.x cluster

## version 11.0.x (chazal)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.11 release](https://docs.openshift.com/container-platform/4.11)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.11.x cluster
- Move to as stable interface with sxcm nad ansible-managed deployments

| Release                                                                       | Date       | Description                                                 |
| ----------------------------------------------------------------------------- | ---------- | ----------------------------------------------------------- |
| [11.7.3](https://github.com/startxfr/helm-repository/releases/tag/11.7.3)     | 2022-10-01 | Upgrade charts to be aligned with Openshift version 4.11.7  |
| [11.5.5](https://github.com/startxfr/helm-repository/releases/tag/11.5.5)     | 2022-09-16 | Upgrade charts to be aligned with Openshift version 4.11.5  |


## version 10.0.x (chauvignac)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.10 release](https://docs.openshift.com/container-platform/4.10)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.10.x cluster
- Introduce the chaos chart suite with various components

| Release                                                                       | Date       | Description                                                 |
| ----------------------------------------------------------------------------- | ---------- | ----------------------------------------------------------- |
| [10.12.34](https://github.com/startxfr/helm-repository/releases/tag/10.12.34) | 2022-06-17 | Stable release of all charts                                |
| [10.12.31](https://github.com/startxfr/helm-repository/releases/tag/10.12.31) | 2022-06-16 | Stable release for all basic charts                         |
| [10.12.28](https://github.com/startxfr/helm-repository/releases/tag/10.12.28) | 2022-06-15 | Stable release for all chaos charts                         |
| [10.12.5](https://github.com/startxfr/helm-repository/releases/tag/10.12.5)   | 2022-03-30 | Upgrade charts to be aligned with Openshift version 4.10.12 |

## version 9.x.x (claux)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.9 release](https://docs.openshift.com/container-platform/4.9)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.9.x cluster
- Stabilize versionning of chart aligned with the openshift minor-patch lifecycle
- Stabilize and check helm-repository catalog lifecycle management

| Release                                                                   | Date       | Description                                               |
| ------------------------------------------------------------------------- | ---------- | --------------------------------------------------------- |
| [9.8.67](https://github.com/startxfr/helm-repository/releases/tag/9.8.67) | 2021-12-18 | Align all charts to version 9.8.67                        |
| [9.8.47](https://github.com/startxfr/helm-repository/releases/tag/9.8.47) | 2021-11-21 | Upgrade all charts annotation for artifacthub             |
| [9.8.9](https://github.com/startxfr/helm-repository/releases/tag/9.8.9)   | 2021-11-20 | Upgrade charts to be aligned with Openshift version 4.9.8 |

## version 8.x.x (charbonnel)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.8 release](https://docs.openshift.com/container-platform/4.8)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.8.x cluster
- Revamp versionning of chart to stick the openshift minor-patch lifecycle
- Add support for [artifacthub](https://artifacthub.io/packages/search?repo=startx) exposure
- Stable helm-repository catalog

| Release                                                                     | Date       | Description                                                                       |
| --------------------------------------------------------------------------- | ---------- | --------------------------------------------------------------------------------- |
| [8.20.9](https://github.com/startxfr/helm-repository/releases/tag/8.20.9)   | 2021-11-12 | Align all charts to version 8.20.9                                                |
| [8.20.7](https://github.com/startxfr/helm-repository/releases/tag/8.20.7)   | 2021-11-11 | Upgrade all charts annotation for artifacthub                                     |
| [8.20.3](https://github.com/startxfr/helm-repository/releases/tag/8.20.3)   | 2021-11-11 | Upgrade charts to be aligned with Openshift version 4.8.20                        |
| [8.13.25](https://github.com/startxfr/helm-repository/releases/tag/8.13.25) | 2021-11-10 | Solve helm issue in the kubeVersion for kube clusters                             |
| [8.13.13](https://github.com/startxfr/helm-repository/releases/tag/8.13.13) | 2021-10-30 | Improve artifacthub and OCP catalog with helm schema                              |
| [8.13.10](https://github.com/startxfr/helm-repository/releases/tag/8.13.10) | 2021-10-22 | Add support for [artifacthub](https://artifacthub.io/packages/search?repo=startx) |
| [8.13.7](https://github.com/startxfr/helm-repository/releases/tag/8.13.7)   | 2021-10-21 | Improve code execution, syntax and introduce the ACS helm-chart                   |
| [8.13.1](https://github.com/startxfr/helm-repository/releases/tag/8.13.1)   | 2021-10-06 | Move to release 8.1.13 aligned with openshift 4.8.13 release                      |
| [8.1.1](https://github.com/startxfr/helm-repository/releases/tag/8.1.1)     | 2021-08-04 | Move to release 8.1.1 aligned with openshift 4.8.1 release                        |

## version 7.22.x (chaumeil)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.7 release](https://docs.openshift.com/container-platform/4.7)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.7.x cluster
- Stable helm-repository catalog

| Release                                                                   | Date       | Description                                                         |
| ------------------------------------------------------------------------- | ---------- | ------------------------------------------------------------------- |
| [7.22.1](https://github.com/startxfr/helm-repository/releases/tag/7.22.1) | 2021-08-04 | Move to release 7.22.1 to align versionning with ocp release 4.7.22 |

## version 0.3.x (chassagne)

This version covert both [Openshift](https://docs.openshift.com) **[4.5](https://docs.openshift.com/container-platform/4.5)**, **[4.6](https://docs.openshift.com/container-platform/4.6)** and **[4.7](https://docs.openshift.com/container-platform/4.7)** release.

The objectif of this version is :

- Offer a stable support for cluster service running under an Openshift 4.5.x, 4.6.x or 4.7.x cluster
- Add more content to the helm repository catalog
- Finish to add demo in the example-catalog
- Move documentation to readthedocs infrastructure

| Release                                                                     | Date       | Description                                                                                        |
| --------------------------------------------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------- |
| [0.3.999](https://github.com/startxfr/helm-repository/releases/tag/0.3.999) | 2021-08-04 | Release stable version 0.3.999 align with ocp 4.7.13                                               |
| [0.3.998](https://github.com/startxfr/helm-repository/releases/tag/0.3.998) | 2021-08-04 | Prepare the v7.22.x release. Stable aligned version of all charts                                  |
| [0.3.381](https://github.com/startxfr/helm-repository/releases/tag/0.3.381) | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377                       |
| [0.3.343](https://github.com/startxfr/helm-repository/releases/tag/0.3.327) | 2021-06-04 | Stable documentation for all charts and Chart version alignment                                    |
| [0.3.305](https://github.com/startxfr/helm-repository/releases/tag/0.3.305) | 2021-06-03 | Stable demo and cluster resource configurations                                                    |
| [0.3.203](https://github.com/startxfr/helm-repository/releases/tag/0.3.203) | 2021-02-21 | Upgrade chart release informations                                                                 |
| [0.3.151](https://github.com/startxfr/helm-repository/releases/tag/0.3.151) | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                                                |
| [0.3.93](https://github.com/startxfr/helm-repository/releases/tag/0.3.93)   | 2020-11-10 | Stable basic and cluster-xxx charts in the startx repository                                       |
| [0.3.23](https://github.com/startxfr/helm-repository/releases/tag/0.3.23)   | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with relevant information |
| [0.3.0](https://github.com/startxfr/helm-repository/releases/tag/0.3.0)     | 2020-10-31 | Stable 0.3 release with basic example and repository structure                                     |

## version 0.2.x (chastang)

This version is designed to use with the [Openshift](https://docs.openshift.com) **[4.5 release](https://docs.openshift.com/container-platform/4.5)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.5.x cluster
- Dissociate cluster, example and basic chart
- Convert all sxv4 cluster-resources to sxcm cluster resources
- Start documenting chart usage

| Release                                                                   | Date       | Description                                       |
| ------------------------------------------------------------------------- | ---------- | ------------------------------------------------- |
| [0.2.51](https://github.com/startxfr/helm-repository/releases/tag/0.2.51) | 2020-10-31 | Common release for all chart                      |
| [0.2.0](https://github.com/startxfr/helm-repository/releases/tag/0.2.0)   | 2020-10-24 | Stable first version of the initial example chart |

## version 0.1.x (chauzu)

This version was constructed using the [Openshift](https://docs.openshift.com) **[4.4 release](https://docs.openshift.com/container-platform/4.4)**.

The objectif of this version is :

- Stable support for cluster service running under an Openshift 4.4.x cluster
- Organize the directory structure
- Define gitflow
- Construc core component used to manage this repository
- Publish it to the world (or interested world ;)

| Release                                                                   | Date     | Description                                            |
| ------------------------------------------------------------------------- | -------- | ------------------------------------------------------ |
| [0.1.13](https://github.com/startxfr/helm-repository/releases/tag/0.1.13) | 20-10-17 | Pblish stable update for the full repository           |
| 0.1.0                                                                     | 20-09-26 | Stable basic structure preparing the public repository |

## version 0.0.x (champeaux)

This version was constructed using the [Openshift](https://docs.openshift.com) **[4.3 release](https://docs.openshift.com/container-platform/4.3)**.

The objectif of this release is to create the repository structure.

| Release                                                                 | Date     | Description                                |
| ----------------------------------------------------------------------- | -------- | ------------------------------------------ |
| [0.0.7](https://github.com/startxfr/helm-repository/releases/tag/0.0.5) | 20-09-27 | Second demo chart for shared resource test |
| [0.0.1](https://github.com/startxfr/helm-repository/releases/tag/0.0.1) | 20-09-26 | Initial commit                             |

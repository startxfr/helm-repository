# Release history

## version 17.0.x (champagnole)

_The objectif of this release is to stabilize the full repository content and offer a stable release of the helm charts for the Openshift Container platform version 4.17.x version._

## version 16.0.x (champignac)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.16 release](https://docs.openshift.com/container-platform/4.16)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.16.x cluster

### Install for this release

To obtain charts stabilized for OCP 4.16.x version, you can add the ([v16 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/16/index.yaml)) dedicated for v16.x releases.

```bash
helm repo add startx-16 https://helm-repository.readthedocs.io/en/latest/repos/16
helm search repo startx
```

### History

| Release                                                                     | Date       | Description          |
| --------------------------------------------------------------------------- | ---------- | -------------------- |
| [16.19.1](https://github.com/startxfr/helm-repository/releases/tag/16.19.1) | 2024-11-10 | Init the v16 release |

## version 15.0.x (champagnac)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.15 release](https://docs.openshift.com/container-platform/4.15)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.15.x cluster

### Install for this release

To obtain charts stabilized for OCP 4.15.x version, you can add the ([v15 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/15/index.yaml)) dedicated for v15.x releases.

```bash
helm repo add startx-15 https://helm-repository.readthedocs.io/en/latest/repos/15
helm search repo startx
```

### History

| Release                                                                       | Date       | Description                        |
| ----------------------------------------------------------------------------- | ---------- | ---------------------------------- |
| [15.27.17](https://github.com/startxfr/helm-repository/releases/tag/15.27.17) | 2024-11-10 | All charts stable for v4.15.x      |
| [15.27.8](https://github.com/startxfr/helm-repository/releases/tag/15.27.8)   | 2024-11-08 | All basic chart stable for v4.15.x |
| [15.27.1](https://github.com/startxfr/helm-repository/releases/tag/15.27.1)   | 2024-11-06 | Init the v15 release               |

## version 14.0.x (chamberet)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.14 release](https://docs.openshift.com/container-platform/4.14)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.14.x cluster

### Install for this release

To obtain charts stabilized for OCP 4.14.x version, you can add the ([v14 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/14/index.yaml)) dedicated for v14.x releases.

```bash
helm repo add startx-14 https://helm-repository.readthedocs.io/en/latest/repos/14
helm search repo startx
```

### History

| Release                                                                     | Date       | Description                                                                             |
| --------------------------------------------------------------------------- | ---------- | --------------------------------------------------------------------------------------- |
| [14.6.75](https://github.com/startxfr/helm-repository/releases/tag/14.6.75) | 2023-12-29 | Move to S3 helm repository and upgrade all startx chart dependencies to version 14.6.71 |
| [14.6.65](https://github.com/startxfr/helm-repository/releases/tag/14.6.65) | 2023-12-27 | Start testing repository backend with S3                                                |
| [14.6.55](https://github.com/startxfr/helm-repository/releases/tag/14.6.55) | 2023-12-22 | align all dependencies chart to 14.6.45                                                 |
| [14.6.45](https://github.com/startxfr/helm-repository/releases/tag/14.6.45) | 2023-12-22 | publish stable update for the full repository                                           |
| [14.6.35](https://github.com/startxfr/helm-repository/releases/tag/14.6.35) | 2023-12-20 | publish stable update for the full repository                                           |
| [14.6.9](https://github.com/startxfr/helm-repository/releases/tag/14.6.9)   | 2023-12-09 | Stable version aligned to Openshift version 4.14.6                                      |

## version 13.0.x (chanac)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.13 release](https://docs.openshift.com/container-platform/4.13)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.13.x cluster

### Install for this release

To obtain charts stabilized for OCP 4.13.x version, you can add the ([v13 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/13/index.yaml)) dedicated for v13.x releases.

```bash
helm repo add startx-13 https://helm-repository.readthedocs.io/en/latest/repos/13
helm search repo startx
```

### History

| Release                                                                     | Date       | Description                                         |
| --------------------------------------------------------------------------- | ---------- | --------------------------------------------------- |
| [13.26.3](https://github.com/startxfr/helm-repository/releases/tag/13.26.3) | 2023-12-09 | Stable version aligned to Openshift version 4.13.26 |

## version 12.0.x (chastang)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.12 release](https://docs.openshift.com/container-platform/4.12)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.12.x cluster

### Install for this release

To obtain charts stabilized for OCP 4.12.x version, you can add the ([v12 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/12/index.yaml)) dedicated for v12.x releases.

```bash
helm repo add startx-12 https://helm-repository.readthedocs.io/en/latest/repos/12
helm search repo startx
```

### History

| Release                                                                       | Date       | Description                                         |
| ----------------------------------------------------------------------------- | ---------- | --------------------------------------------------- |
| [12.45.0](https://github.com/startxfr/helm-repository/releases/tag/12.45.0)   | 2023-12-08 | Stable version aligned to Openshift version 4.12.45 |
| [12.36.69](https://github.com/startxfr/helm-repository/releases/tag/12.36.69) | 2023-11-14 | move dependencies to version 12.36.65               |
| [12.36.9](https://github.com/startxfr/helm-repository/releases/tag/12.36.9)   | 2023-10-01 | publish stable update for the full repository       |
| [12.30.1](https://github.com/startxfr/helm-repository/releases/tag/12.30.1)   | 2023-09-29 | release 12.30.1 aligned and tested with OCP 4.12.30 |
| [12.0.5](https://github.com/startxfr/helm-repository/releases/tag/12.0.5)     | 2023-08-18 | publish stable update for the full repository       |

## version 11.0.x (chazal)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.11 release](https://docs.openshift.com/container-platform/4.11)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.11.x cluster
- Move to as stable interface with sxcm nad ansible-managed deployments

### Install for this release

To obtain charts stabilized for OCP 4.11.x version, you can add the ([v11 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/11/index.yaml)) dedicated for v11.x releases.

```bash
helm repo add startx-11 https://helm-repository.readthedocs.io/en/latest/repos/11
helm search repo startx
```

### History

| Release                                                                         | Date       | Description                                                    |
| ------------------------------------------------------------------------------- | ---------- | -------------------------------------------------------------- |
| [11.40.0](https://github.com/startxfr/helm-repository/releases/tag/11.40.0)     | 2023-08-18 | Align all helm chart to release 11.40.0 stable for OCP 4.11.40 |
| [11.30.0](https://github.com/startxfr/helm-repository/releases/tag/11.30.0)     | 2023-08-18 | Align all helm chart to release 11.30.0 stable for OCP 4.11.30 |
| [11.28.230](https://github.com/startxfr/helm-repository/releases/tag/11.28.230) | 2023-08-18 | Align all helm chart to release 11.28.230 stable release       |
| [11.28.129](https://github.com/startxfr/helm-repository/releases/tag/11.28.129) | 2023-06-13 | publish stable update for the full repository                  |
| [11.28.99](https://github.com/startxfr/helm-repository/releases/tag/11.28.99)   | 2023-04-21 | publish stable update for the full repository                  |
| [11.28.69](https://github.com/startxfr/helm-repository/releases/tag/11.28.69)   | 2023-03-07 | publish stable update for the full repository                  |
| [11.28.29](https://github.com/startxfr/helm-repository/releases/tag/11.28.29)   | 2023-02-21 | publish stable update for the full repository                  |
| [11.28.19](https://github.com/startxfr/helm-repository/releases/tag/11.28.19)   | 2023-02-19 | publish stable update for the full repository                  |
| [11.7.97](https://github.com/startxfr/helm-repository/releases/tag/11.7.97)     | 2023-02-19 | publish stable update for the full repository                  |
| [11.7.69](https://github.com/startxfr/helm-repository/releases/tag/11.7.69)     | 2022-11-30 | Finished dependencies stabilization                            |
| [11.7.17](https://github.com/startxfr/helm-repository/releases/tag/11.7.17)     | 2022-10-02 | publish stable update for the full repository                  |
| [11.7.3](https://github.com/startxfr/helm-repository/releases/tag/11.7.3)       | 2022-10-01 | Upgrade charts to be aligned with Openshift version 4.11.7     |
| [11.5.5](https://github.com/startxfr/helm-repository/releases/tag/11.5.5)       | 2022-09-16 | Upgrade charts to be aligned with Openshift version 4.11.5     |

## version 10.0.x (chauvignac)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.10 release](https://docs.openshift.com/container-platform/4.10)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.10.x cluster
- Introduce the chaos chart suite with various components

### Install for this release

To obtain charts stabilized for OCP 4.10.x version, you can add the ([v10 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/10/index.yaml)) dedicated for v10.x releases.

```bash
helm repo add startx-10 https://helm-repository.readthedocs.io/en/latest/repos/10
helm search repo startx
```

### History

| Release                                                                         | Date       | Description                                                 |
| ------------------------------------------------------------------------------- | ---------- | ----------------------------------------------------------- |
| [10.12.141](https://github.com/startxfr/helm-repository/releases/tag/10.12.141) | 2022-09-21 | Upgrade all chart                                           |
| [10.12.105](https://github.com/startxfr/helm-repository/releases/tag/10.12.105) | 2022-09-18 | Upgrade all chart                                           |
| [10.12.34](https://github.com/startxfr/helm-repository/releases/tag/10.12.34)   | 2022-06-17 | Stable release of all charts                                |
| [10.12.31](https://github.com/startxfr/helm-repository/releases/tag/10.12.31)   | 2022-06-16 | Stable release for all basic charts                         |
| [10.12.28](https://github.com/startxfr/helm-repository/releases/tag/10.12.28)   | 2022-06-15 | Stable release for all chaos charts                         |
| [10.12.5](https://github.com/startxfr/helm-repository/releases/tag/10.12.5)     | 2022-03-30 | Upgrade charts to be aligned with Openshift version 4.10.12 |  |

## version 9.x.x (chaux)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.9 release](https://docs.openshift.com/container-platform/4.9)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.9.x cluster
- Stabilize versionning of chart aligned with the openshift minor-patch lifecycle
- Stabilize and check helm-repository catalog lifecycle management

### Install for this release

To obtain charts stabilized for OCP 4.9.x version, you can add the ([v9 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/9/index.yaml)) dedicated for v9.x releases.

```bash
helm repo add startx-9 https://helm-repository.readthedocs.io/en/latest/repos/9
helm search repo startx
```

### History

| Release                                                                     | Date       | Description                                               |
| --------------------------------------------------------------------------- | ---------- | --------------------------------------------------------- |
| [9.15.3](https://github.com/startxfr/helm-repository/releases/tag/9.15.3)   | 2022-06-01 | Stabilize all charts for Openshift 4.9.15                 |
| [9.8.278](https://github.com/startxfr/helm-repository/releases/tag/9.8.278) | 2022-05-31 | Improve project options                                   |
| [9.8.67](https://github.com/startxfr/helm-repository/releases/tag/9.8.67)   | 2021-12-18 | Align all charts to version 9.8.67                        |
| [9.8.47](https://github.com/startxfr/helm-repository/releases/tag/9.8.47)   | 2021-11-21 | Upgrade all charts annotation for artifacthub             |
| [9.8.9](https://github.com/startxfr/helm-repository/releases/tag/9.8.9)     | 2021-11-20 | Upgrade charts to be aligned with Openshift version 4.9.8 |

## version 8.x.x (charbonnel)

This version is designed and stabilized for the [Openshift](https://docs.openshift.com) **[4.8 release](https://docs.openshift.com/container-platform/4.8)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.8.x cluster
- Revamp versionning of chart to stick the openshift minor-patch lifecycle
- Add support for [artifacthub](https://artifacthub.io/packages/search?repo=startx) exposure
- Stable helm-repository catalog

### Install for this release

To obtain charts stabilized for OCP 4.8.x version, you can add the ([v8 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/8/index.yaml)) dedicated for v8.x releases.

```bash
helm repo add startx-8 https://helm-repository.readthedocs.io/en/latest/repos/8
helm search repo startx
```

### History

| Release                                                                     | Date       | Description                                                                       |
| --------------------------------------------------------------------------- | ---------- | --------------------------------------------------------------------------------- |
| [8.20.71](https://github.com/startxfr/helm-repository/releases/tag/8.20.71) | 2021-11-20 | Align all charts to Openshift version 4.8.21                                      |
| [8.20.70](https://github.com/startxfr/helm-repository/releases/tag/8.20.70) | 2021-11-20 | publish stable update for the full repository                                     |
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

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.7.x cluster
- Stable helm-repository catalog

### Install for this release

To obtain charts stabilized for OCP 4.7.x version, you can add the ([v7 helm repository](https://helm-repository.readthedocs.io/en/latest/repos/7/index.yaml)) dedicated for v7.x releases.

```bash
helm repo add startx-7 https://helm-repository.readthedocs.io/en/latest/repos/7
helm search repo startx
```

### History

| Release                                                                     | Date       | Description                                                         |
| --------------------------------------------------------------------------- | ---------- | ------------------------------------------------------------------- |
| [7.22.27](https://github.com/startxfr/helm-repository/releases/tag/7.22.27) | 2021-10-06 | publish stable update for the full repository                       |
| [7.22.12](https://github.com/startxfr/helm-repository/releases/tag/7.22.12) | 2021-09-23 | publish stable update for the full repository                       |
| [7.22.1](https://github.com/startxfr/helm-repository/releases/tag/7.22.1)   | 2021-08-04 | Move to release 7.22.1 to align versionning with ocp release 4.7.22 |

## version 0.3.x (chassagne)

This version covert both [Openshift](https://docs.openshift.com) **[4.5](https://docs.openshift.com/container-platform/4.5)**, **[4.6](https://docs.openshift.com/container-platform/4.6)** and **[4.7](https://docs.openshift.com/container-platform/4.7)** release.

### Objectives of this release

- Offer a stable support for cluster service running under an Openshift 4.5.x, 4.6.x or 4.7.x cluster
- Add more content to the helm repository catalog
- Finish to add demo in the example-catalog
- Move documentation to readthedocs infrastructure

### Install for this release

To obtain charts stabilized for OCP 4.6.x version and previous, you can add the ([v6x helm repository](https://helm-repository.readthedocs.io/en/latest/repos/6x/index.yaml)) dedicated for v6.x and previous releases.

```bash
helm repo add startx-6x https://helm-repository.readthedocs.io/en/latest/repos/6x
helm search repo startx
```

### History

| Release                                                                     | Date       | Description                                                                                        |
| --------------------------------------------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------- |
| [0.3.999](https://github.com/startxfr/helm-repository/releases/tag/0.3.999) | 2021-08-04 | Release stable version 0.3.999 align with ocp 4.7.13                                               |
| [0.3.998](https://github.com/startxfr/helm-repository/releases/tag/0.3.998) | 2021-08-04 | Prepare the v7.22.x release. Stable aligned version of all charts                                  |
| [0.3.480](https://github.com/startxfr/helm-repository/releases/tag/0.3.480) | 2021-08-03 | publish stable update for the full repository                                                      |
| [0.3.381](https://github.com/startxfr/helm-repository/releases/tag/0.3.381) | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377                       |
| [0.3.343](https://github.com/startxfr/helm-repository/releases/tag/0.3.327) | 2021-06-04 | Stable documentation for all charts and Chart version alignment                                    |
| [0.3.305](https://github.com/startxfr/helm-repository/releases/tag/0.3.305) | 2021-06-03 | Stable demo and cluster resource configurations                                                    |
| [0.3.203](https://github.com/startxfr/helm-repository/releases/tag/0.3.203) | 2021-02-21 | Upgrade chart release informations                                                                 |
| [0.3.151](https://github.com/startxfr/helm-repository/releases/tag/0.3.151) | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                                                |
| [0.3.93](https://github.com/startxfr/helm-repository/releases/tag/0.3.93)   | 2020-11-10 | Stable basic and cluster-xxx charts in the startx repository                                       |
| [0.3.45](https://github.com/startxfr/helm-repository/releases/tag/0.3.45)   | 2020-11-08 | Align all basic helm chart to 0.3.45                                                               |
| [0.3.23](https://github.com/startxfr/helm-repository/releases/tag/0.3.23)   | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with relevant information |
| [0.3.0](https://github.com/startxfr/helm-repository/releases/tag/0.3.0)     | 2020-10-31 | Stable 0.3 release with basic example and repository structure                                     |

## version 0.2.x (chastang)

This version is designed to use with the [Openshift](https://docs.openshift.com) **[4.5 release](https://docs.openshift.com/container-platform/4.5)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.5.x cluster
- Dissociate cluster, example and basic chart
- Convert all sxv4 cluster-resources to sxcm cluster resources
- Start documenting chart usage

### Install for this release

To obtain charts stabilized for OCP 4.6.x version and previous, you can add the ([v6x helm repository](https://helm-repository.readthedocs.io/en/latest/repos/6x/index.yaml)) dedicated for v6.x and previous releases.

```bash
helm repo add startx-6x https://helm-repository.readthedocs.io/en/latest/repos/6x
helm search repo startx
```

### History

| Release                                                                   | Date       | Description                                       |
| ------------------------------------------------------------------------- | ---------- | ------------------------------------------------- |
| [0.2.51](https://github.com/startxfr/helm-repository/releases/tag/0.2.51) | 2020-10-31 | Common release for all chart                      |
| [0.2.0](https://github.com/startxfr/helm-repository/releases/tag/0.2.0)   | 2020-10-24 | Stable first version of the initial example chart |

## version 0.1.x (chauzu)

This version was constructed using the [Openshift](https://docs.openshift.com) **[4.4 release](https://docs.openshift.com/container-platform/4.4)**.

### Objectives of this release

- Stable support for cluster service running under an Openshift 4.4.x cluster
- Organize the directory structure
- Define gitflow
- Construc core component used to manage this repository
- Publish it to the world (or interested world ;)

### Install for this release

To obtain charts stabilized for OCP 4.6.x version and previous, you can add the ([v6x helm repository](https://helm-repository.readthedocs.io/en/latest/repos/6x/index.yaml)) dedicated for v6.x and previous releases.

```bash
helm repo add startx-6x https://helm-repository.readthedocs.io/en/latest/repos/6x
helm search repo startx
```

### History

| Release                                                                   | Date     | Description                                            |
| ------------------------------------------------------------------------- | -------- | ------------------------------------------------------ |
| [0.1.13](https://github.com/startxfr/helm-repository/releases/tag/0.1.13) | 20-10-17 | Pblish stable update for the full repository           |
| 0.1.0                                                                     | 20-09-26 | Stable basic structure preparing the public repository |

## version 0.0.x (champeaux)

This version was constructed using the [Openshift](https://docs.openshift.com) **[4.3 release](https://docs.openshift.com/container-platform/4.3)**.

The objectif of this release is to create the repository structure.

### Install for this release

To obtain charts stabilized for OCP 4.6.x version and previous, you can add the ([v6x helm repository](https://helm-repository.readthedocs.io/en/latest/repos/6x/index.yaml)) dedicated for v6.x and previous releases.

```bash
helm repo add startx-6x https://helm-repository.readthedocs.io/en/latest/repos/6x
helm search repo startx
```

### History

| Release                                                                 | Date     | Description                                |
| ----------------------------------------------------------------------- | -------- | ------------------------------------------ |
| [0.0.7](https://github.com/startxfr/helm-repository/releases/tag/0.0.5) | 20-09-27 | Second demo chart for shared resource test |
| [0.0.1](https://github.com/startxfr/helm-repository/releases/tag/0.0.1) | 20-09-26 | Initial commit                             |

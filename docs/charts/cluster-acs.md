# Cluster ACS

This helm chart must have a description

## Install the repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
```

## Get information about this chart

```bash
helm show chart startx/cluster-acs
```

## Install this chart

```bash
helm install cluster-acs startx/cluster-acs
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **open-security-management** with the following properties
  - 1 **LimitRange:** defined for this projet
  - 1 **Quotas:** defined for this projet
  - 3 **RBAC:** allowing **mygroup_example** to **edit** resources
- 1 **operator:** named **rhacs-operator** configured with
  - The **rhacs-3.72** channel
  - The **3.72.0** version
  - Deployed under the **openshift-operators** project
- 1 **acs:** enabled
  - **central** enabled
  - **scanner** enabled

```bash
# base configuration running default configuration
helm install cluster-acs startx/cluster-acs
```

## Others values availables

- **startx** : Startx acs cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acs/values-startx.yaml))

```bash
helm install cluster-acs startx/cluster-acs -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-acs/values-startx.yaml
```

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 8.13.1   | 2021-10-06 | Stable release for OCP 4.8.13 version                                                          |
| 8.13.3   | 2021-10-08 | Improve code execution, syntax and introduce the ACS helm-chart                                |
| 8.13.5   | 2021-10-21 | publish stable update for the full repository                                                  |
| 8.13.7   | 2021-10-21 | publish stable update for the full repository                                                  |
| 8.13.8   | 2021-10-21 | Adding first draft of json schema                                                              |
| 8.13.9   | 2021-10-22 | Adding the schema in chart                                                                     |
| 8.13.9   | 2021-10-22 | Adding the schema in chart                                                                     |
| 8.13.25  | 2021-11-10 | Solve helm issue in the kubeVersion for kube clusters and upgrade chart dep to version 8.13.23 |
| 8.13.27  | 2021-11-10 | publish stable update for the full repository                                                  |
| 8.20.3   | 2021-11-11 | Align all charts to Openshift version 4.8.20                                                   |
| 8.20.3   | 2021-11-11 | stable release for all chart for openshift version 4.8.20                                      |
| 8.20.5   | 2021-11-12 | Upgrade all appVersion and align chart release                                                 |
| 8.20.7   | 2021-11-12 | Upgrade all schema for context subtree                                                         |
| 8.20.9   | 2021-11-12 | Align all startx chart to version 8.20.9                                                       |
| 0.20.11  | 2021-11-12 | Move chart dependencies to version 8.20.5                                                      |
| 0.20.33  | 2021-11-14 | publish stable update for the full repository                                                  |
| 0.20.39  | 2021-11-14 | Aling all dependencies to version 0.20.34                                                      |
| 0.20.41  | 2021-11-14 | Aling all dependencies to version 0.20.34                                                      |
| 8.20.46  | 2021-11-19 | Transitionnal chart                                                                            |
| 8.20.60  | 2021-11-19 | publish stable update for the full repository                                                  |
| 8.20.66  | 2021-11-20 | Updating limits for context vars in values schema                                              |
| 8.20.70  | 2021-11-20 | publish stable update for the full repository                                                  |
| 8.20.71  | 2021-11-20 | Align all charts to Openshift version 4.8.21                                                   |
| 9.8.1    | 2021-11-20 | Upgrade to Openshift version 4.9.8                                                             |
| 9.8.4    | 2021-11-20 | Stable release of chart for Openshift 4.9.8 version                                            |
| 9.8.7    | 2021-11-20 | Debug dependencies problem                                                                     |
| 9.8.9    | 2021-11-20 | Update startx chart dependencies version to 9.8.8 and schema update                            |
| 9.8.15   | 2021-11-20 | Update startx chart dependencies version to 9.8.11                                             |
| 9.8.19   | 2021-11-20 | Update startx chart dependencies version to 9.8.15 and improve values schema                   |
| 9.8.28   | 2021-11-20 | Update the startx chart dependencies to version 9.8.23                                         |
| 9.8.39   | 2021-11-21 | Debug version check with more permissive mode                                                  |
| 9.8.43   | 2021-11-21 | Update the startx chart dependencies to version 9.8.39                                         |
| 9.8.45   | 2021-11-21 | Update the values schema limits for context properties                                         |
| 9.8.47   | 2021-11-21 | Improve version management for chart                                                           |
| 9.8.51   | 2021-11-22 | Update startx chart dependencies to version 9.8.48                                             |
| 9.8.52   | 2021-12-06 | Update to version 3.67.0                                                                       |
| 9.8.53   | 2021-12-06 | Update to version 3.67.0                                                                       |
| 9.8.67   | 2021-12-18 | Align all charts to release 9.8.67                                                             |
| 9.8.71   | 2021-12-18 | Update helm-chart dependencies to version 9.8.59                                               |
| 9.8.75   | 2021-12-19 | Align with all other startx chart version to number 9.8.75                                     |
| 9.8.76   | 2021-12-19 | Change helm.sh/chart name                                                                      |
| 9.8.81   | 2021-12-20 | Update the storage context                                                                     |
| 9.8.91   | 2022-03-06 | publish stable update for the full repository                                                  |
| 9.8.93   | 2022-03-07 | Enable conditionnal loading of charts dependencies                                             |
| 9.8.109  | 2022-04-26 | Update startx chart dependencies to version 9.8.107                                            |
| 9.8.109  | 2022-04-26 | Update startx chart dependencies to version 9.8.107                                            |
| 9.8.110  | 2022-04-27 | Stable release for all charts                                                                  |
| 9.8.111  | 2022-04-27 | publish stable update for the full repository                                                  |
| 9.8.114  | 2022-04-27 | publish stable update for the full repository                                                  |
| 9.8.215  | 2022-05-06 | Upgrade startx chart dependencies to version 9.8.211                                           |
| 9.8.230  | 2022-05-06 | Stable full repository                                                                         |
| 9.8.231  | 2022-05-06 | Debug basic chart dependencies                                                                 |
| 9.8.233  | 2022-05-06 | publish stable update for the full repository                                                  |
| 9.8.239  | 2022-05-17 | Remove default csv from all charts. global release 9.8.239                                     |
| 9.8.253  | 2022-05-29 | Align all charts dependencies to release 9.8.251                                               |
| 9.8.277  | 2022-05-31 | publish stable update for the full repository                                                  |
| 9.15.1   | 2022-06-01 | Align all chart for Openshift 4.9.15                                                           |
| 9.15.2   | 2022-06-01 | Align all charts to release 9.15.1                                                             |
| 9.15.3   | 2022-06-01 | Align all charts to release 9.15.3                                                             |
| 10.12.1  | 2022-06-01 | Align all charts to release 10.12.1                                                            |
| 10.12.1  | 2022-06-01 | Align all charts to release 10.12.1                                                            |
| 10.12.3  | 2022-06-01 | Align all charts to release 10.12.3                                                            |
| 10.12.3  | 2022-06-01 | publish stable update for the full repository                                                  |
| 10.12.4  | 2022-06-01 | Align all charts to release 10.12.4                                                            |
| 10.12.5  | 2022-06-01 | publish stable update for the full repository                                                  |
| 10.12.22 | 2022-06-04 | Align all chart to release version 10.12.22                                                    |
| 10.12.23 | 2022-06-04 | Basi chart dependencies upgraded to version 10.12.5                                            |
| 10.12.29 | 2022-06-17 | Align all charts to version 10.12.29                                                           |
| 10.12.29 | 2022-06-17 | publish stable update for the full repository                                                  |
| 10.12.30 | 2022-06-17 | Improved logo and global documentation                                                         |
| 10.12.33 | 2022-06-17 | publish stable update for the full repository                                                  |
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31                                                      |
| 10.12.39 | 2022-06-18 | Align all chart to revision 10.12.39                                                           |
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41                                                           |
| 10.12.46 | 2022-06-18 | publish stable update for the full repository                                                  |
| 10.12.49 | 2022-06-18 | publish stable update for the full repository                                                  |
| 10.12.53 | 2022-06-18 | publish stable update for the full repository                                                  |
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts                                                             |
| 10.12.72 | 2022-07-02 | Common release                                                                                 |
| 10.12.77 | 2022-07-02 | Stable for clients                                                                             |
| 10.12.81 | 2022-07-02 | publish stable update for the full repository                                                  |
| 10.12.97 | 2022-07-03 | publish stable update for the full repository                                                  |
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart                                                       |
| 11.5.3   | 2022-09-17 | Align all STARTX charts to release 11.5.3                                                      |
| 11.7.1   | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release                               |
| 11.7.3   | 2022-10-02 | publish stable update for the full repository                                                  |
| 11.7.9   | 2022-10-02 | publish stable update for the full repository                                                  |
| 11.7.10 | 2022-10-02 | Stable release for all packages
| 11.7.11 | 2022-10-02 | publish stable update for the full repository
| 11.7.15 | 2022-10-02 | publish stable update for the full repository
| 11.7.17 | 2022-10-02 | publish stable update for the full repository
| 11.7.31 | 2022-10-29 | publish stable update for the full repository
| 11.7.33 | 2022-10-29 | Update all startx packages to release 11.7.33
| 11.7.41 | 2022-11-02 | publish stable update for the full repository
| 11.7.61 | 2022-11-30 | publish stable update for the full repository
| 11.7.62 | 2022-11-30 | Debug console links and notifications
| 11.7.63 | 2022-11-30 | publish stable update for the full repository
| 11.7.67 | 2022-11-30 | Debug depedencies on sub charts
| 11.7.69 | 2022-11-30 | Finished dependencies stabilization
| 11.7.73 | 2022-12-04 | Align all packages to release 11.7.73
| 11.7.75 | 2022-12-04 | publish stable update for the full repository
| 11.7.77 | 2022-12-05 | publish stable update for the full repository
| 11.7.87 | 2023-02-15 | publish stable update for the full repository
| 11.7.88 | 2023-02-15 | publish stable update for the full repository
| 11.7.91 | 2023-02-16 | publish stable update for the full repository
| 11.7.93 | 2023-02-16 | align dependencies to version 11.7.89
| 11.7.97 | 2023-02-19 | publish stable update for the full repository
| 11.28.11 | 2023-02-19 | publish stable update for the full repository
| 11.28.15 | 2023-02-19 | publish stable update for the full repository
| 11.28.16 | 2023-02-19 | publish stable update for the full repository
| 11.28.19 | 2023-02-19 | publish stable update for the full repository
| 11.28.21 | 2023-02-19 | Upgrade all dependencies packages to release 11.28.15
| 11.28.23 | 2023-02-21 | publish stable update for the full repository
| 11.28.27 | 2023-02-21 | All chart aligned to release 11.28.27
| 11.28.29 | 2023-02-21 | publish stable update for the full repository
| 11.28.35 | 2023-02-21 | publish stable update for the full repository
| 11.28.49 | 2023-02-21 | publish stable update for the full repository
| 11.28.59 | 2023-02-21 | publish stable update for the full repository
| 11.28.60 | 2023-02-21 | publish stable update for the full repository
| 11.28.67 | 2023-02-23 | publish stable update for the full repository
| 11.28.69 | 2023-03-07 | publish stable update for the full repository
| 11.28.89 | 2023-04-01 | publish stable update for the full repository
| 11.28.93 | 2023-04-20 | publish stable update for the full repository
| 11.28.95 | 2023-04-21 | publish stable update for the full repository
| 11.28.99 | 2023-04-21 | publish stable update for the full repository
| 11.28.103 | 2023-05-04 | publish stable update for the full repository
| 11.28.127 | 2023-06-12 | publish stable update for the full repository
| 11.28.128 | 2023-06-12 | publish stable update for the full repository
| 11.28.129 | 2023-06-13 | publish stable update for the full repository
| 11.28.201 | 2023-07-06 | publish stable update for the full repository
| 11.28.207 | 2023-07-06 | publish stable update for the full repository
| 11.28.230 | 2023-08-18 | Align all helm chart to release 11.28.230 stable release
| 11.30.0 | 2023-08-18 | Align all helm chart to release 11.30.0 stable for OCP 4.11.30
| 11.40.0 | 2023-08-18 | Align all helm chart to release 11.40.0 stable for OCP 4.11.40
| 11.47.0 | 2023-08-18 | Align all helm chart to release 11.47.0 stable for OCP 4.11.47
| 11.47.1 | 2023-08-18 | Update appVersion in Chart.yml
| 11.47.1 | 2023-08-18 | Update appVersion in Chart.yml
| 12.0.0 | 2023-08-18 | Align all helm chart to release 12.0.0 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.1 | 2023-08-18 | Align all helm chart to release 12.0.1 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.5 | 2023-08-18 | publish stable update for the full repository
| 12.0.7 | 2023-08-18 | Upgrade to 3.74.5 ACS operator release
| 12.0.11 | 2023-08-18 | publish stable update for the full repository
| 12.30.1 | 2023-09-29 | release 12.30.1 aligned and tested with OCP 4.12.30
| 12.36.1 | 2023-09-29 | release 12.36.0 aligned with OCP 4.12.36 (unstable)
| 12.36.9 | 2023-10-01 | publish stable update for the full repository
| 12.36.36 | 2023-10-11 | publish stable update for the full repository
| 12.36.49-noschema | 2023-11-13 | Publish stable update for the full repository with the no-schema packages
| 12.36.51-noschema | 2023-11-13 | publish stable update for the full repository
| 12.36.58 | 2023-11-13 | Align all startx dependencies packages to version 12.36.49 stable for OCP 4.12.36
| 12.36.59-noschema | 2023-11-13 | publish stable update for the full no-schema version
| 12.36.61 | 2023-11-13 | publish stable update for the full repository

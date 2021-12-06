# Cluster ACS

This helm chart must have a description

## Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

## Get information about this chart

```bash
helm show chart startx/cluster-acs
```

## Install this chart

```bash
helm install startx/cluster-acs
```

## History

| Release | Date       | Description                                                                  |
| ------- | ---------- | ---------------------------------------------------------------------------- |
| 8.13.1 | 2021-10-06 | Stable release for OCP 4.8.13 version
| 8.13.3 | 2021-10-08 | Improve code execution, syntax and introduce the ACS helm-chart
| 8.13.5 | 2021-10-21 | publish stable update for the full repository
| 8.13.7 | 2021-10-21 | publish stable update for the full repository
| 8.13.8 | 2021-10-21 | Adding first draft of json schema
| 8.13.9 | 2021-10-22 | Adding the schema in chart
| 8.13.9 | 2021-10-22 | Adding the schema in chart
| 8.13.25 | 2021-11-10 | Solve helm issue in the kubeVersion for kube clusters and upgrade chart dep to version 8.13.23
| 8.13.27 | 2021-11-10 | publish stable update for the full repository
| 8.20.3 | 2021-11-11 | Align all charts to Openshift version 4.8.20
| 8.20.3 | 2021-11-11 | stable release for all chart for openshift version 4.8.20
| 8.20.5 | 2021-11-12 | Upgrade all appVersion and align chart release
| 8.20.7 | 2021-11-12 | Upgrade all schema for context subtree
| 8.20.9 | 2021-11-12 | Align all startx chart to version 8.20.9
| 0.20.11 | 2021-11-12 | Move chart dependencies to version 8.20.5
| 0.20.33 | 2021-11-14 | publish stable update for the full repository
| 0.20.39 | 2021-11-14 | Aling all dependencies to version 0.20.34
| 0.20.41 | 2021-11-14 | Aling all dependencies to version 0.20.34
| 8.20.46 | 2021-11-19 | Transitionnal chart
| 8.20.60 | 2021-11-19 | publish stable update for the full repository
| 8.20.66 | 2021-11-20 | Updating limits for context vars in values schema
| 8.20.70 | 2021-11-20 | publish stable update for the full repository
| 8.20.71 | 2021-11-20 | Align all charts to Openshift version 4.8.21
| 9.8.1 | 2021-11-20 | Upgrade to Openshift version 4.9.8
| 9.8.4 | 2021-11-20 | Stable release of chart for Openshift 4.9.8 version
| 9.8.7 | 2021-11-20 | Debug dependencies problem
| 9.8.9 | 2021-11-20 | Update startx chart dependencies version to 9.8.8 and schema update
| 9.8.15 | 2021-11-20 | Update startx chart dependencies version to 9.8.11
| 9.8.19 | 2021-11-20 | Update startx chart dependencies version to 9.8.15 and improve values schema
| 9.8.28 | 2021-11-20 | Update the startx chart dependencies to version 9.8.23
| 9.8.39 | 2021-11-21 | Debug version check with more permissive mode
| 9.8.43 | 2021-11-21 | Update the startx chart dependencies to version 9.8.39
| 9.8.45 | 2021-11-21 | Update the values schema limits for context properties
| 9.8.47 | 2021-11-21 | Improve version management for chart
| 9.8.51 | 2021-11-22 | Update startx chart dependencies to version 9.8.48
| 9.8.52 | 2021-12-06 | Update to version 3.67.0
| 9.8.53 | 2021-12-06 | Update to version 3.67.0

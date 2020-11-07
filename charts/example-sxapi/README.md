# STARTX helm : example-sxapi

This helm chart is used to create a deployment of a small an simple micro-service based on [sxapi helm chart](https://startxfr.github.io/helm-repository/charts/sxapi)

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### Get information about this chart

```bash
helm show chart startx/example-sxapi
```

### Install this chart

```bash
helm install startx/example-sxapi
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **service** named **example-sxapi** load balancing to pod deployed
- 1 **deployment** named **example-sxapi** deploying **1 pod** from version **0.3.53** sxapi image running the **prod:start** command with debug enabled
- 2 **configMap** holding sxapi configuration and pod environmnet variable context

```bash
# base configuration running default configuration
helm install startx/example-sxapi
```

## Others values availables

- **dev** : Dev sxapi environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-dev.yaml))

```bash
helm install startx/example-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-dev.yaml
```

- **v0.0.1** : v0.0.1 production environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-v0.0.1.yaml))

```bash
helm install startx/example-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-v0.0.1.yaml
```

- **v0.0.2** : v0.0.2 production environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-v0.0.2.yaml))

```bash
helm install startx/example-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-v0.0.2.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.11  | 2020-10-25 | Initial commit for this helm chart with default value example
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.2.999 | 2020-10-31 | publish stable update for the full repository
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.3   | 2020-11-01 | Update sxapi chart dependency to 0.3.1 and moving application data to value file
| 0.3.5   | 2020-11-01 | Update dependency to 0.3.3 release
| 0.3.17  | 2020-11-01 | Synchronize releases for all chart in the startx repository
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.29  | 2020-11-07 | Improve NOTES output and move to 0.3.25 dependencies

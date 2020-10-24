# STARTX helm : demo-sxapi

This helm chart is used to create a deployment of a small an simple micro-service based on 
sxapi engine running under nodejs engine.

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
helm show chart startx/demo-sxapi
```

### Install this chart

```bash
helm install startx/demo-sxapi
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **service** named **demo-sxapi** load balancing to pod deployed
- 1 **deployment** named **demo-sxapi** deploying **1 pod** from version **0.3.53** sxapi image running the **prod:start** command with debug enabled
- 2 **configMap** holding sxapi configuration and pod environmnet variable context

```bash
# base configuration running default configuration
helm install startx/demo-sxapi
```

## Others values availables

- **dev** : Dev sxapi environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-sxapi/values-dev.yaml))

```bash
helm install startx/demo-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-sxapi/values-dev.yaml
```

- **v0.0.1** : v0.0.1 production environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-sxapi/values-v0.0.1.yaml))

```bash
helm install startx/demo-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-sxapi/values-v0.0.1.yaml
```

- **v0.0.2** : v0.0.2 production environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-sxapi/values-v0.0.2.yaml))

```bash
helm install startx/demo-sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-sxapi/values-v0.0.2.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.0.1   | 2020-10-01 | Initial commit
| 0.1.0   | 2020-10-07 | Release 0.1 stable release for all charts
| 0.1.24  | 2020-10-23 | Improve documentation
| 0.2.0   | 2020-10-24 | Improve cluster-rbac options
| 0.2.1  | 2020-10-24 | publish stable update for the full repository
| 0.2.2  | 2020-10-24 | Repository update with all chart release

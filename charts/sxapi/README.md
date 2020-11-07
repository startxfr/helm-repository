# STARTX helm : sxapi

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
helm show chart startx/sxapi
```

### Install this chart

```bash
helm install startx/sxapi
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **service** named **sxapi** load balancing to pod deployed
- 1 **deployment** named **sxapi** deploying **1 pod** from version **0.3.53** sxapi image running the **prod:start** command with debug enabled
- 2 **configMap** holding sxapi configuration and pod environmnet variable context

```bash
# base configuration running default configuration
helm install startx/sxapi
```

## Others values availables

- **dev** : Dev sxapi environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-dev.yaml))

```bash
helm install startx/sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-dev.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.51  | 2020-10-31 | Initial commit for this chart with default and dev value examples
| 0.2.99  | 2020-10-31 | Prepare release 0.3.0
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.1   | 2020-11-01 | Move to go templates for notes generation and move app content to value property sxapi.data
| 0.3.3   | 2020-11-01 | Test new scope for note template helper
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.25  | 2020-11-07 | NOTES content is more accurate and detailed
| 0.3.27  | 2020-11-07 | Stable notes
| 0.3.29  | 2020-11-07 | Release aligned to basic 0.3.29 version

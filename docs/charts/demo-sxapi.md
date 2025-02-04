# Demo sxapi

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

- **v0.0.1** : v0.0.1 production environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-v0.0.1.yaml))

```bash
helm install startx/sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-v0.0.1.yaml
```

- **v0.0.2** : v0.0.2 production environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-v0.0.2.yaml))

```bash
helm install startx/sxapi -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/sxapi/values-v0.0.2.yaml
```

## History

| Release | Date       | Description                                                   |
| ------- | ---------- | ------------------------------------------------------------- |
| 0.0.1   | 2020-09-14 | Initial commit for this repository                            |
| 0.2.9   | 2020-10-24 | Update all demo-xxx charts                                    |
| 0.2.11  | 2020-10-25 | publish stable update for the full repository                 |
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22                                  |
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts |
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release                 |

# STARTX helm : cluster-istio

This helm chart is used to configure Metering at the cluster level.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration
state orchestrated by gitops tools like ArgoCD.

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
helm show chart startx/cluster-istio
```

### Install this chart

```bash
helm install startx/cluster-istio
```

## Default values

Complete deployment of a project with the following characteristics :

xxxx to do xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-istio
```

## Others values availables

- **startx** : Startx 3scale cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-startx.yaml))

```bash
helm install startx/cluster-istio -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.19  | 2020-11-06 | Create chart cluster-istio from cluster-ocs
| 0.3.20  | 2020-11-06 | Add project, operator subscription, meteringConfig and reports support and example in values.yaml
| 0.3.19  | 2020-11-06 | Add project, operator subscription, meteringConfig and reports support and example in values.yaml
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.21  | 2020-11-06 | Create chart cluster-istio from cluster-metering

# STARTX helm : cluster-console

This helm chart is used to configure openshift console at the cluster level.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration
state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-console
```

### 4. Install this chart

```bash
helm install startx/cluster-console
```

## Default values

Complete deployment of a project with the following characteristics :

xxxx to do xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-console
```

## Others values availables

- **startx** : Startx 3scale cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-console/values-startx.yaml))

```bash
helm install startx/cluster-console -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-console/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.21  | 2020-11-07 | Create chart cluster-console from cluster-auth with logo customisation as well as notification, link and logLink
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.34  | 2020-11-08 | Improve cluster-console options
| 0.3.35  | 2020-11-08 | Improve cluster-console options
| 0.3.36  | 2020-11-08 | Improve cluster-console options
| 0.3.37  | 2020-11-08 | Improve cluster-console options

# STARTX helm : cluster-3scale

This helm chart is used to create a deployment of a 3scale, operator based, deployment of 3Scale API management tools.
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
helm show chart startx/cluster-3scale
```

### Install this chart

```bash
helm install startx/cluster-3scale
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **startx-3scale** with the following properties
  - 1 **LimitRange:** defined for this projet
  - 1 **Quotas:** defined for this projet
  - 3 **RBAC:** allowing **mygroup_example** to **edit** resources
- 1 **operator:** named **3scale-operator** configured with
  - The **threescale-2.9** channel
  - The **0.6.0** version
  - Deployed under the **openshift-operators** project
  - The **manager** deployed
- 1 **Secret:** named **startx-3scale-rhn** that hold rhn credentials used fo image pulling

```bash
# base configuration running default configuration
helm install startx/cluster-3scale
```

## Others values availables

- **startx** : Startx 3scale cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-3scale/values-startx.yaml))

```bash
helm install startx/cluster-3scale -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-3scale/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.0.1   | 2020-10-01 | Initial commit
| 0.1.0   | 2020-10-07 | Release 0.1 stable release for all charts
| 0.1.21  | 2020-10-22 | add user support and update startx example value example
| 0.1.22  | 2020-10-23 | Improve documentation
| 0.2.0   | 2020-10-24 | Stable startx helm base config
| 0.2.1  | 2020-10-24 | publish stable update for the full repository
| 0.2.2  | 2020-10-24 | Repository update with all chart release
| 0.2.5  | 2020-10-24 | Unstable repository global update
| 0.2.7  | 2020-10-24 | Unstable repository release

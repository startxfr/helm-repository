# STARTX helm : cluster-quay

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
helm show chart startx/cluster-quay
```

### Install this chart

```bash
helm install startx/cluster-quay
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
helm install startx/cluster-quay
```

## Others values availables

- **startx** : Startx 3scale cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-quay/values-startx.yaml))

```bash
helm install startx/cluster-quay -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-quay/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.0   | 2020-10-24 | Initial commit for this helm chart with default value example
| 0.2.13  | 2020-10-26 | Add startx/project as dependency for cluster-quay chart (removed)
| 0.2.15  | 2020-10-26 | Improve cluster-quay options for project
| 0.2.17  | 2020-10-26 | Improve cluster-quay options for global config release
| 0.2.35  | 2020-10-26 | Move operator management to the helm chart startx/project dependency
| 0.2.36  | 2020-10-31 | Move operator management to the helm chart startx/operator dependency (removed)
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.5   | 2020-11-01 | Update dependency to 0.3.3 release and improve Note display
| 0.3.17  | 2020-11-01 | Synchronize releases for all chart in the startx repository
| 0.3.17  | 2020-11-04 | Create chart cluster-quay from cluster-3scale

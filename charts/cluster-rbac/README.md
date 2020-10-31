# STARTX helm : cluster-rbac

This helm chart is used to create a RBAC cluster configuration with group and user required as a default config fo the targeted cluster.
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
helm show chart startx/cluster-rbac
```

### Install this chart

```bash
helm install startx/cluster-rbac
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **group** named **mygroup_example** with the **basic-user** cluster role
- 1 **clusterRole** named **mygroup_example-basic-user** who gave the **basic-user** cluster role to all members of the **mygroup_example** group

```bash
# base configuration running default configuration
helm install startx/cluster-rbac
```

## Others values availables

- **startx** : Startx RBAC default context with dev, devops, ops and admin groups (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rbac/values-startx.yaml))

```bash
helm install startx/cluster-rbac -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rbac/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.1.14  | 2020-10-23 | Initial commit for this helm chart with default value example (removed)
| 0.2.11  | 2020-10-25 | publish stable update for the full repository
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.2.999 | 2020-10-31 | publish stable update for the full repository
| 0.3.0   | 2020-10-31 | Stable 0.3 release

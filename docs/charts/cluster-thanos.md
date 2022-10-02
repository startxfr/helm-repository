# Cluster Thanos

This helm chart must have a description

## Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

## Get information about this chart

```bash
helm show chart startx/cluster-thanos
```

## Install this chart

```bash
helm install startx/cluster-thanos
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project:** named **open-cluster-management-observability** with the following properties
  - 1 **LimitRange:** defined for this projet
  - 1 **Quotas:** defined for this projet
  - 3 **RBAC:** allowing **mygroup_example** to **edit** resources
- 1 **operator:** named **advanced-cluster-management** configured with
  - The **release-2.4** channel
  - The **2.4.0** version
  - Deployed under the **open-cluster-management-observability** project
  - The **manager** deployed
- 1 **mch:** named **default-mch** configured with
  - **hive** enabled
  - **ingress** enabled

```bash
# base configuration running default configuration
helm install startx/cluster-thanos
```

## Others values availables

- **startx** : Startx Thanos cluster wide service configuration using startx group (dev, devops and ops) (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-thanos/values-startx.yaml))

```bash
helm install startx/cluster-thanos -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-thanos/values-startx.yaml
```

## History

| Release | Date       | Description                                          |
| ------- | ---------- | ---------------------------------------------------- |
| 9.8.110 | 2022-04-27 | Create chart cluster-thanos from cluster-thanos      |
| 9.8.215 | 2022-05-06 | Upgrade startx chart dependencies to version 9.8.211 |
| 9.8.230 | 2022-05-06 | Stable full repository                               |
| 9.8.231 | 2022-05-06 | Debug basic chart dependencies                       |
| 9.8.233 | 2022-05-06 | publish stable update for the full repository        |

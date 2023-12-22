# Cluster redis

This helm chart is used to deploy Redis instances managed by a dedicated operator.
This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-redis
```

### 4. Install this chart

```bash
helm install cluster-redis startx/cluster-redis
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-redis startx/cluster-redis
```

## Others values availables

- **startx** : Redis operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-redis/values-startx.yaml))

```bash
helm install cluster-redis startx/cluster-redis -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-redis/values-startx.yaml
```

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 14.6.43  | 2023-12-22 | Create cluster-redis skeleton from cluster-couchbase                                           |
| 14.6.45 | 2023-12-22 | publish stable update for the full repository
| 14.6.46 | 2023-12-22 | publish stable update for the full repository
| 14.6.55 | 2023-12-22 | align all dependencies chart to 14.6.45
| 14.6.59 | 2023-12-22 | move back dependencies to version 14.6.35
| 14.6.61 | 2023-12-22 | Implement deployment of multiples redisCluster CRD
| 14.6.63 | 2023-12-22 | Align all startx helm-chart to version 14.6.63

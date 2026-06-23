# ![cluster-keepalived](https://helm-repository.readthedocs.io/en/latest/img/cluster-keepalived.svg "Cluster Chart : Keepalived") Cluster Chart : Keepalived
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--keepalived-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+keepalived+startx)

This helm chart is used to configure Keepalived at the cluster level.

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
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-keepalived
```

### 4. Install this chart

```bash
helm install cluster-keepalived startx/cluster-keepalived
```

## Default values

Complete deployment of a Keepalived configuration with the following characteristics :

- 1 **operator** named **keepalived-operator** deployed under **keepalived-operator** namespace
- 1 **KeepalivedGroup** instance managing VRRP on worker/infra nodes
- 1 **clusterNetwork** patch enabling external IP assignment

```bash
# base configuration running default configuration
helm install cluster-keepalived startx/cluster-keepalived
```

## Others values availables

- **startx** : Startx keepalived cluster wide service configuration using keepalived operator (see [values-example.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-keepalived/values-example.yaml))

```bash
helm install cluster-keepalived startx/cluster-keepalived -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-keepalived/values-example.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-keepalived/examples/argocd/
oc apply -k .
```

### Applications



## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 21.3.3   | 2026-06-23 | Initial release of cluster-keepalived chart |
| 21.3.4 | 2026-06-23 | Improve cluster-keepalived options |
| 21.3.4 | 2026-06-23 | Improve cluster-keepalived options |
| 21.3.4 | 2026-06-23 | Improve cluster-keepalived options |
| 21.3.167 | 2026-06-23 | publish stable update for the full repository |
| 21.3.181 | 2026-06-23 | publish stable update for the full repository |
| 21.3.182 | 2026-06-23 | publish stable update for the full repository |

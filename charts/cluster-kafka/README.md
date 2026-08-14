# ![cluster-kafka](https://helm-repository.readthedocs.io/en/latest/img/cluster-kafka.svg "Cluster Chart : Kafka") Cluster Chart : Kafka
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--kafka-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+kafka+startx)

This helm chart is used to deploy Kafka handled by an operator to configure cluster and topic management at the cluster level.

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
helm show chart startx/cluster-kafka
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **operator:** named **amq-streams-console** configured with
  - The **stable** channel for community release
  - The **v3.2.0** version
  - Deployed under the **openshift-operators** project

```bash
# Create the project
helm install cluster-kafka-project startx/cluster-kafka --set project.enabled=true,operator.enabled=false,kafka.enabled=false
# Deploy the kafka operator
helm install cluster-kafka-operator startx/cluster-kafka --set project.enabled=false,operator.enabled=true,kafka.enabled=false && sleep 10
# Configure default kafka resources
helm install cluster-kafka-instance startx/cluster-kafka --set project.enabled=false,operator.enabled=false,kafka.enabled=true
```

#### Other available values

- **startx** : Kafka operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kafka/values-startx.yaml))

```bash
helm install cluster-kafka startx/cluster-kafka -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kafka/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-kafka/examples/argocd/
oc apply -k .
```

### Applications



## History

| Release | Date       | Description                                       |
| ------- | ---------- | ------------------------------------------------- |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.15 | 2026-03-02 | Prepare upgrading dependency to 19.23.11 |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.7 | 2026-03-02 | Update dependencies to version 20.14.0 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.1 | 2026-03-02 | Prepare release 21.3.x with 21.x dependencies |
| 21.3.3 | 2026-03-02 | Upgrade dependencies to v21.3.0 |
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.12 | 2026-06-18 | Improve cluster-kafka options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |
| 21.3.167 | 2026-06-23 | publish stable update for the full repository |
| 21.3.181 | 2026-06-23 | publish stable update for the full repository |
| 21.3.182 | 2026-06-23 | publish stable update for the full repository |
| 21.3.199 | 2026-06-24 | publish stable update for the full repository |
| 21.3.201 | 2026-06-24 | publish stable update for the full repository |
| 21.3.202 | 2026-06-24 | publish stable update for the full repository |
| 21.3.205 | 2026-06-24 | publish stable update for the full repository |
| 21.3.229 | 2026-08-08 | publish stable update for the full repository |
| 21.3.273 | 2026-08-09 | publish stable update for the full repository |
| 21.3.277 | 2026-08-09 | Align all charts to v21.3.277 |
| 21.3.278 | 2026-08-14 | add centigpu |

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
  - The **alpha** channel for community release
  - The **v3.1.0** version
  - Deployed under the **openshift-operators** project

```bash
# Create the project
helm install cluster-kafka-project startx/cluster-kafka --set project.enabled=true,operator.enabled=false,kafka.enabled=false
# Deploy the kafka operator
helm install cluster-kafka-operator startx/cluster-kafka --set project.enabled=false,operator.enabled=true,kafka.enabled=false && sleep 10
# Configure default kafka ressources
helm install cluster-kafka-instance startx/cluster-kafka --set project.enabled=false,operator.enabled=false,kafka.enabled=true
```

#### Others values availables

- **startx** : Kafka operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kafka/values-startx.yaml))

```bash
helm install cluster-kafka startx/cluster-kafka -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-kafka/values-startx.yaml
```

## History

| Release | Date       | Description                                       |
| ------- | ---------- | ------------------------------------------------- |
| 18.11.31 | 2025-05-03 | Create chart cluster-kafka from cluster-certmanager
| 18.11.33 | 2025-05-03 | Support for the kafka console operator
| 18.11.39 | 2025-05-05 | Update icon with startx new theme
| 18.11.51 | 2025-05-06 | publish stable update for the full repository
| 18.11.52 | 2025-05-07 | publish stable update for the full repository
| 18.11.60 | 2025-05-14 | Align all chart to a stable release for OCP 4.18
| 18.11.71 | 2025-11-27 | Align all charts to the same releas
| 18.23.0 | 2026-02-28 | Start 4.19 branch
| 19.23.1 | 2026-02-28 | unstable build of the 19.23.x release
| 19.23.0 | 2026-02-28 | publish stable update for the full repository
| 19.23.5 | 2026-03-01 | Unstable full 19.23.x release
| 19.23.8 | 2026-03-01 | publish stable update for the full repository
| 19.23.15 | 2026-03-02 | Prepare upgrading dependency to 19.23.11
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11
| 20.14.0 | 2026-03-02 | Create initial version for 20.x branch linked to OCP 4.20.x release. Tested on OCP 4.20.14

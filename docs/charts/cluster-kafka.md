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
  - The **v2.9.0** version
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

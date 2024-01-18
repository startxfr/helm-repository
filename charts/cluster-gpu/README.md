# Cluster Chart : NVidia GPU

This helm chart is used to deploy NVidia GPU Driver handled by an operator to configure GPU Drivers at the cluster level.
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
helm show chart startx/cluster-gpu
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **startx-gpu** without constraints
- 1 **operator:** named **nvidia-gpu-operator** configured with
  - The **stable** channel for community release
  - The **v1.7.2** version
  - Deployed under the **openshift-operators** project

```bash
# Create the project
helm install cluster-gpu-project startx/cluster-gpu --set project.enabled=true,operator.enabled=false,gpu.enabled=false
# Deploy the OADP operator
helm install cluster-gpu-operator startx/cluster-gpu --set project.enabled=false,operator.enabled=true,gpu.enabled=false && sleep 10
# Configure default OADP ressources
helm install cluster-gpu-instance startx/cluster-gpu --set project.enabled=false,operator.enabled=false,gpu.enabled=true
```

#### Others values availables

- **startx** : GPU operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-gpu/values-startx.yaml))

```bash
helm install cluster-gpu startx/cluster-gpu -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-gpu/values-startx.yaml
```

## History

| Release | Date       | Description                                       |
| ------- | ---------- | ------------------------------------------------- |
| 14.6.111 | 2024-01-17 | Create chart cluster-gpu from cluster-certmanager |
| 14.6.111 | 2024-01-18 | New version of the NVidia Operator packaged into the cluster-gu chart
| 14.6.111-noschema | 2024-01-18 | Release of the noschema version
| 14.6.131-noschema | 2024-01-18 | upgrade dependencies to basic charts for noschema branch

# Cluster CertManager

This helm chart is used to deploy Cert-Manager handled by an operator to configure Certificate management at the cluster level.
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
helm show chart startx/cluster-certmanager
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **startx-certmanager** without constraints
- 1 **operator:** named **cert-manager-operator** configured with
  - The **stable** channel for community release
  - The **v1.7.2** version
  - Deployed under the **openshift-operators** project

```bash
# Create the project
helm install cluster-certmanager-project startx/cluster-certmanager --set project.enabled=true,operator.enabled=false,certmanager.enabled=false
# Deploy the OADP operator
helm install cluster-certmanager-operator startx/cluster-certmanager --set project.enabled=false,operator.enabled=true,certmanager.enabled=false && sleep 10
# Configure default OADP ressources
helm install cluster-certmanager-instance startx/cluster-certmanager --set project.enabled=false,operator.enabled=false,certmanager.enabled=true
```

#### Others values availables

- **startx** : CertManager operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-certmanager/values-startx.yaml))

```bash
helm install cluster-certmanager startx/cluster-certmanager -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-certmanager/values-startx.yaml
```

## History

| Release | Date       | Description                                       |
| ------- | ---------- | ------------------------------------------------- |
| 11.7.18 | 2022-10-28 | Create chart cluster-certmanager from cluster-ptp |
| 11.7.18 | 2022-10-28 | Create chart cluster-certmanager from cluster-ptp |
| 11.7.31 | 2022-10-29 | publish stable update for the full repository     |
| 11.7.33 | 2022-10-29 | Update all startx packages to release 11.7.33     |
| 11.7.41 | 2022-11-02 | publish stable update for the full repository
| 11.7.61 | 2022-11-30 | publish stable update for the full repository
| 11.7.62 | 2022-11-30 | Debug console links and notifications
| 11.7.63 | 2022-11-30 | publish stable update for the full repository
| 11.7.67 | 2022-11-30 | Debug depedencies on sub charts
| 11.7.69 | 2022-11-30 | Finished dependencies stabilization
| 11.7.73 | 2022-12-04 | Align all packages to release 11.7.73
| 11.7.75 | 2022-12-04 | publish stable update for the full repository

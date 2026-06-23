# ![cluster-oadp](https://helm-repository.readthedocs.io/en/latest/img/cluster-oadp.svg "Cluster Chart : OADP") Cluster Chart : OADP
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--oadp-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+oadp+startx)

This helm chart is used to deploy Openshift Application Data Protection handled by an operator to configure application and cluster backup strategies.

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
helm show chart startx/cluster-oadp
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **openshift-adp** without constraints
- 1 **operator:** named **redhat-oadp-operator** configured with
  - The **stable-1.1** channel
  - The **v1.1.1** version
  - Deployed under the **openshift-adp** project
- 1 **DataProtectionApplication:** named **default** configured with default values for AWS backend
- 1 **schedule:** named **daily-app** configured with default values for demo backup

```bash
# Create the project
helm install cluster-oadp-project startx/cluster-oadp --set project.enabled=true,operator.enabled=false,oadp.enabled=false
# Deploy the OADP operator
helm install cluster-oadp-operator startx/cluster-oadp --set project.enabled=false,operator.enabled=true,oadp.enabled=false && sleep 10
# Configure default OADP resources
helm install cluster-oadp-instance startx/cluster-oadp --set project.enabled=false,operator.enabled=false,oadp.enabled=true
```

#### Others values availables

- **startx** : OADP operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-oadp/values-startx.yaml))

```bash
helm install cluster-oadp startx/cluster-oadp -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-oadp/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/cluster-oadp/examples/argocd/
oc apply -k .
```

### Applications



## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
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
| 21.3.12 | 2026-06-19 | Improve cluster-oadp options |
| 21.3.13 | 2026-06-19 | Improve cluster-oadp options |
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

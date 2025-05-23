# ![cluster-devworkspaces](https://helm-repository.readthedocs.io/en/latest/img/cluster-devworkspaces.svg "Cluster Chart : DevWorkspaces") Cluster Chart : DevWorkspaces
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--devworkspaces-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+devworkspaces+startx)

This helm chart is used to deploy Dev Workspaces operator to help you develop your applications into kubernetes cluster.

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
helm show chart startx/cluster-devworkspaces
```

### 4. Install this chart

```bash
helm install cluster-devworkspaces startx/cluster-devworkspaces
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **operator:** named **devworkspace-operator** configured with
  - The **fast** channel for community release
  - The **v0.33.0** version
  - Deployed under the **openshift-operators** project

```bash
# Create the project
helm install cluster-devworkspaces-project startx/cluster-devworkspaces --set project.enabled=true,operator.enabled=false,devworkspaces.enabled=false
# Deploy the devworkspace operator
helm install cluster-devworkspaces-operator startx/cluster-devworkspaces --set project.enabled=false,operator.enabled=true,devworkspaces.enabled=false && sleep 10
# Configure default devworkspace ressources
helm install cluster-devworkspaces-instance startx/cluster-devworkspaces --set project.enabled=false,operator.enabled=false,devworkspaces.enabled=true
```

## Others values availables

- **startx** : DevWorkspaces operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-devworkspaces/values-startx.yaml))

```bash
helm install cluster-devworkspaces startx/cluster-devworkspaces -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-devworkspaces/values-startx.yaml
```

## History

| Release  | Date       | Description                              |
| -------- | ---------- | ---------------------------------------- |
| 14.6.369 | 2025-06-30 | Initialize the cluster-devworkspaces structure inherited from cluster-mtr (clonned from cluster-workspace)  |
| 14.6.368 | 2024-06-30 | Create the cluster-devworkspaces structure inherited from cluster-mtr (clonned from cluster-workspace)
| 14.6.381 | 2024-06-30 | Align all startx charts to release 14.6.381
| 15.27.3 | 2024-11-06 | create init release for version 15.x
| 15.27.5 | 2024-11-06 | publish stable update for the full repository
| 15.27.7 | 2024-11-06 | Align all startx charts dependencies to release 15.27.3
| 15.27.9 | 2024-11-09 | Upgrade the DevWorkspace operator version to v0.31.1
| 15.27.17 | 2024-11-10 | Release aligned for OCP 4.15.27
| 15.27.21 | 2024-11-10 | Release aligned for OCP 4.15.37
| 16.19.3 | 2024-11-10 | Init release 16.19.1 aligned for OCP 4.16.19
| 16.19.7 | 2024-11-10 | Update all dependencies to version 16.19.4
| 16.19.11 | 2024-11-10 | Update all dependencies to version 16.19.4
| 16.19.15 | 2024-11-10 | publish stable update for the full repository
| 16.19.29 | 2024-11-11 | Align all chart to the 16.19.29 release
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release
| 16.19.31 | 2024-12-10 | Align all charts to 19.19.31
| 16.19.43 | 2025-02-27 | publish stable update for the full repository
| 17.14.1 | 2025-02-28 | Initial release for v17.x version
| 17.14.3 | 2025-02-28 | Temporary release used to prepare dependencies changes
| 17.14.5 | 2025-02-28 | Align all startx helm dependencies to release 17.14.1
| 17.14.11 | 2025-03-05 | Adjust doc to material layout
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version
| 18.11.3 | 2025-04-30 | Prepare dependencies move to version 18.x
| 18.11.5 | 2025-04-30 | move dependencies to version 18.11.1
| 18.11.7 | 2025-04-30 | All dependencies linked to 18.x release
| 18.11.9 | 2025-05-01 | Update operator devworkspace to version 0.33.0
| 18.11.19 | 2025-05-02 | Intermediate alignement of all helm charts
| 18.11.21 | 2025-05-02 | Update all basic chart dependencies to version 18.11.15
| 18.11.22 | 2025-05-02 | Add noinfra values in all charts
| 18.11.24 | 2025-05-02 | Align all to stable version
| 18.11.31 | 2025-05-03 | update all dependencies to version 18.11.19
| 18.11.39 | 2025-05-05 | Update icon with startx new theme
| 18.11.51 | 2025-05-06 | publish stable update for the full repository
| 18.11.52 | 2025-05-07 | publish stable update for the full repository
| 18.11.60 | 2025-05-14 | Align all chart to a stable release for OCP 4.18

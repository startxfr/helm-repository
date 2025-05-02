# ![cluster-gpu](https://helm-repository.readthedocs.io/en/latest/img/cluster-gpu.svg "Cluster Chart : GPU") Cluster Chart : NVidia GPU
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--gpu-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+gpu+startx)

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
| 14.6.131 | 2024-01-18 | publish stable update for the full repository
| 14.6.133 | 2024-01-18 | Update the documentation with artifacthub badge
| 14.6.135 | 2024-01-18 | debug artifacthub recommandations
| 14.6.137 | 2024-01-18 | publish stable update for the full repository
| 14.6.141 | 2024-02-03 | upgrade of the full startx repository
| 14.6.143 | 2024-02-03 | Align to 14.6.143 chart release
| 14.6.145 | 2024-02-03 | Update all startx dependencies chart to 14.6.141 chart release
| 14.6.149 | 2024-02-03 | Update all startx dependencies chart to 14.6.141 chart release
| 14.6.150 | 2024-02-03 | Stable 14.6.150 release
| 14.6.161 | 2024-02-08 | publish stable update for the full repository
| 14.6.171 | 2024-02-08 | publish stable update for the full repository
| 14.6.189 | 2024-02-08 | publish stable update for the full repository
| 14.6.195 | 2024-02-08 | publish stable update for the full repository
| 14.6.197 | 2024-02-08 | publish stable update for the full repository
| 14.6.201 | 2024-02-08 | publish stable update for the full repository
| 14.6.208 | 2024-03-06 | Align all dependencies to 14.6.208 release
| 14.6.215 | 2024-03-08 | Align all charts to release 14.6.215
| 14.6.231 | 2024-03-19 | Align all charts to release 14.6.231
| 14.6.251 | 2024-03-27 | Align all charts to release 14.6.251
| 14.6.269 | 2024-03-31 | Align all charts to release 14.6.269
| 14.6.281 | 2024-05-20 | Align all charts to release 14.6.281
| 14.6.293 | 2024-05-29 | Align all charts to release 14.6.293
| 14.6.301 | 2024-05-30 | Helm package are now signed
| 14.6.321 | 2024-06-25 | publish stable update for the full repository
| 14.6.323 | 2024-06-25 | Align all chart to latest release
| 14.6.325 | 2024-06-25 | Adding chart logo in README header
| 14.6.325 | 2024-06-25 | publish stable update for the full repository
| 14.6.331 | 2024-06-25 | update all dependencies to version 14.6.323
| 14.6.335 | 2024-06-26 | publish stable update for the full repository
| 14.6.343 | 2024-06-26 | publish stable update for the full repository
| 14.6.345 | 2024-06-26 | publish stable update for the full repository
| 14.6.351 | 2024-06-26 | Update all dependencies
| 14.6.353 | 2024-06-26 | Fixed missed dependencies in previous release
| 14.6.367 | 2024-06-29 | Align all startx charts to release 14.6.367
| 14.6.381 | 2024-06-30 | Align all startx charts to release 14.6.381
| 15.27.3 | 2024-11-06 | create init release for version 15.x
| 15.27.5 | 2024-11-06 | publish stable update for the full repository
| 15.27.7 | 2024-11-06 | Align all startx charts dependencies to release 15.27.3
| 15.27.9 | 2024-11-09 | Upgrade the NVidia GPU operator version to v24.9.0
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
| 18.11.9 | 2025-05-01 | Update the nvidia operator to version 25.3.0

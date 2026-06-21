# ![cluster-machine](https://helm-repository.readthedocs.io/en/latest/img/cluster-machine.svg "Cluster Chart : Machine") Cluster Chart : Machine
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--machine-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+machine+startx)

This helm chart is used to configure the Machine api of your cluster.

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
helm show chart startx/cluster-machine
```

### 4. Install this chart

```bash
helm install cluster-machine startx/cluster-machine
```

## Default values

Deployment of machine classes :

<!-- - 1 **machineSet** named **example-gp3-csi** with the following characteristics
  - **provisioner** set to **kubernetes.io/aws-ebs**
  - provisioner **encryption** specific parameters set to **true**
  - machine class **reclaim policy** set to **Delete**
  - machine class **volume expansion enabled**
  - machine class **volume binding mode** set to **WaitForFirstConsumer** -->

```bash
# base configuration running default configuration
helm install cluster-machine startx/cluster-machine
```

## Others values availables

<!-- - **startx** : Startx machine classes running under AWS infrastructure (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-machine/values-startx.yaml)) creating the following machine classes
  - **startx-aws-generic-retain** (AWS EBS gp3-csi level with encryption and expansion enabled with retain policy)
  - **startx-aws-generic-delete** (AWS EBS gp3-csi level with encryption and expansion enabled with delete policy)
  - **startx-aws-fast-retain** (AWS EBS io1 level without encryption and expansion enabled with retain policy)
  - **startx-aws-fast-delete** (AWS EBS io1 level without encryption and expansion enabled with delete policy)
  - **startx-aws-slow-retain** (AWS EBS sc1 level with encryption and expansion enabled with retain policy)
  - **startx-aws-slow-delete** (AWS EBS sc1 level with encryption and expansion enabled with delete policy)

```bash
helm install cluster-machine startx/cluster-machine -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-machine/values-startx.yaml
```

- **startx-ocs** : Startx machine classes for OCS infrastructure (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-machine/values-startx-ocs.yaml)) creating the following machine classes
  - **startx-odf-generic-retain** (OCS provisionned via openshift-machine.rbd.csi.ceph.com in cluster openshift-machine with retain policy and expansion enabled)
  - **startx-odf-generic-delete** (OCS provisionned via openshift-machine.rbd.csi.ceph.com in cluster openshift-machine with delete policy and expansion enabled)
  - **startx-odf-fs-retain** (OCS provisionned via openshift-machine.cephfs.csi.ceph.com in cluster openshift-machine with retain policy)
  - **startx-odf-fs-delete** (OCS provisionned via openshift-machine.cephfs.csi.ceph.com in cluster openshift-machine with delete policy)

```bash
helm install cluster-machine startx/cluster-machine -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-machine/values-startx-ocs.yaml
``` -->

## Deploy with ArgoCD

### AppProject

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: cluster-machine
  namespace: openshift-gitops
spec:
  description: Configure Machine API resources (MachineConfig, MachineSet, autoscaling)
  sourceRepos:
    - http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
  destinations:
    - namespace: openshift-gitops
      server: https://kubernetes.default.svc
    - namespace: openshift-machine-api
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
```

### Applications

```yaml
---
# Configures MachineConfigPool and MachineConfig resources
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-machine-config
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-machine
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-machine
    targetRevision: 21.3.105
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        machineConfigPool:
          enabled: true
        machineConfig:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true

---
# Configures MachineHealthCheck, MachineAutoscaler and MachineSet resources
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-machine-healthcheck
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-machine
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-machine
    targetRevision: 21.3.105
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        cluster:
          id: demo219-g866v
          region: eu-west-2
        machineHealthCheck:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Configures MachineHealthCheck, MachineAutoscaler and MachineSet resources
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-machine-autoscaler
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-machine
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-machine
    targetRevision: 21.3.105
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        cluster:
          id: demo219-g866v
          region: eu-west-2
          autoscaler:
            enabled: true
            spec: |
              podPriorityThreshold: -10
              resourceLimits:
                maxNodesTotal: 9
                cores:
                  min: 6
                  max: 12
                memory:
                  min: 12
                  max: 48
              scaleDown:
                enabled: true
                delayAfterAdd: 5m
                delayAfterDelete: 3m
                delayAfterFailure: 40s
                unneededTime: 60s
        machineAutoscaler:
          enabled: true
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
---
# Configures MachineHealthCheck, MachineAutoscaler and MachineSet resources
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-machine-machineset
  namespace: openshift-gitops
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: cluster-machine
  source:
    repoURL: http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable
    chart: cluster-machine
    targetRevision: 21.3.105
    helm:
      valueFiles:
        - values-startx_noinfra.yaml
      values: |
        cluster:
          id: demo219-g866v
          region: eu-west-2
        machineSet:
          enabled: true
          list:
          - name: app-a
            az: a
            type: app
            ami: ami-0e079f8742280b034
            instanceType: "t3a.large"
            volumeSize: 75
            volumeType: "gp3"
            replicas: 1
            securityGroupName: "demo219-g866v-node"
            subnet_name: "demo219-g866v-subnet-private-eu-west-2a"
          - name: app-b
            az: b
            type: app
            ami: ami-0e079f8742280b034
            instanceType: "t3a.large"
            volumeSize: 75
            volumeType: "gp3"
            replicas: 1
            securityGroupName: "demo219-g866v-node"
            subnet_name: "demo219-g866v-subnet-private-eu-west-2b"
          - name: app-c
            az: c
            type: app
            ami: ami-0e079f8742280b034
            instanceType: "t3a.large"
            volumeSize: 75
            volumeType: "gp3"
            replicas: 1
            securityGroupName: "demo219-g866v-node"
            subnet_name: "demo219-g866v-subnet-private-eu-west-2c"
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.21 | 2025-04-24 | Add snobm profile |
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
| 21.3.12 | 2026-06-18 | Add ArgoCD examples for cluster-machine |
| 21.3.13 | 2026-06-19 | Add securityGroupName override to machineSet template |
| 21.3.12 | 2026-06-18 | Improve cluster-machine options |
| 21.3.13 | 2026-06-19 | Improve cluster-machine options |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |

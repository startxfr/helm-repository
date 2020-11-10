# STARTX helm : cluster-kubevirt

This helm chart is used to configure code ready kubevirt via it's operator and deploy a VM into Openshift.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration
state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-kubevirt
```

### 4. Install this chart

```bash
helm install startx/cluster-kubevirt
```

## Default values

xxxx  to do xxxxxxxx

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.3.59  | 2020-11-09 | Create chart cluster-kubevirt from cluster-kubevirt
| 0.3.61  | 2020-11-09 | Add deployment of Hyperconverged cluster via HCO operator and multiple VM via the VirtualMachine resources
| 0.3.61  | 2020-11-09 | Improve repository documentation and new chart for kubevirt management
| 0.3.73  | 2020-11-10 | publish stable update for the full repository
| 0.3.75  | 2020-11-10 | publish stable update for the full repository
| 0.3.77  | 2020-11-10 | publish stable update for the full repository
| 0.3.83  | 2020-11-10 | publish stable update for the full repository

# Cluster Ansible

This helm chart is used to create an operator based deployment of Ansible Automation.
This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deployment pod but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io)  for
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
helm show chart startx/cluster-ansible
```

### 4. Install this chart

```bash
helm install startx/cluster-ansible
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install startx/cluster-ansible
```

## Others values availables

- **startx** : Ansible operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ansible/values-startx.yaml))

```bash
helm install startx/cluster-ansible -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-ansible/values-startx.yaml
```

## History

| Release | Date       | Description                                                                                            |
| ------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 9.8.19  | 2021-11-20 | Create chart cluster-ansible from cluster-quay
| 9.8.21 | 2021-11-20 | Initial version of the cluster chart for ansible
| 9.8.28 | 2021-11-20 | Update the startx chart dependencies to version 9.8.23
| 9.8.39 | 2021-11-21 | Debug version check with more permissive mode
| 9.8.43 | 2021-11-21 | Update the startx chart dependencies to version 9.8.39
| 9.8.45 | 2021-11-21 | Update the values schema limits for context properties
| 9.8.47 | 2021-11-21 | Improve version management for chart
| 9.8.51 | 2021-11-22 | Update startx chart dependencies to version 9.8.48
| 9.8.52 | 2021-11-22 | Update to ansible-automation-platform operator version and move to a cluster scope operator
| 9.8.53 | 2021-12-09 | Update to ansible-automation-platform operator version v2.1.0-0.1638388448
| 9.8.67 | 2021-12-18 | Align all charts to release 9.8.67

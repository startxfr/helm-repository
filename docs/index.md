# This repository

This [helm repository](https://startxfr.github.io/helm-repository/packages/index.yaml) hold various helm-chart configuring Openshift cluster components

## Usage

### 1. Requirements

#### 1.1. install cli dependencies

```bash
yum install yq -y
```

#### 1.2. install helm

```bash
yum install helm -y
```

#### 1.3. Beiing connected to an openshift cluster

```bash
oc login -t <my-token> <my-openshift-api>
```

If you don't have access to an openshift cluster, consider using codeready-container to
run locally a simulated cluster.

### 2. Install repository

#### 2.1. Install this repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

#### 2.2. List all chart in this repository

```bash
helm search repo startx
```

### 3. Install chart

#### 3.1. Show chart detail

```bash
helm show chart startx/cluster-config
```

#### 3.2. Install chart into cluster

```bash
helm install startx/cluster-config
```

## Chart list

- [cluster-config](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-config) ```helm show chart startx/cluster-config```
- [cluster-rbac](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-rbac) ```helm show chart startx/cluster-rbac```

## Release

Release naming and convention is described in the [release documentation](./releases.md).

### History

You can get a detailed list of this helm-chart releases in the [history documentation](./history.md).
The current release is for theses helm-charts is 0.0.5. More information are available in [version 0.0 releases history](./history.md#version-00x-chanteix).

# This repository

This helm repository hold various helm-chart configuring Openshift cluster components

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
helm repo add startx https://startxfr.github.io/helm-charts-ocp-infra/packages/
```

#### 2.2. List all chart in this repository

```bash
helm search startx
```

### 3. Install chart

```bash
helm install startx/cluster-config
```

## Release

Release naming and convention is described in the [release documentation](./releases.md).

### History

You can get a detailed list of this helm-chart releases in the [history documentation](./history.md).
The current release is for theses helm-charts is 0.0.5. More information are available in [version 0.0 releases history](./history.md#version-00x-chanteix).

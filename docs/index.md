# Welcome to STARTX helm repository

## Helm repository content

This repository host various helm chart targeting the Openshift Container Platform environment. Charts could be
divided into 3 main category

### Cluster Helm charts

Helm chart prefixed with `cluster-` are Cluster chart. Cluster charts configure cluster configuration or enable cluster service.

| Chart                                                | Source                                                                                     | Description  
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------ | -------------------------------------
| **[cluster-config](charts/cluster-config.md)**       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-config)    | global configuration of an openshift cluster
| **[cluster-rbac](charts/cluster-rbac.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-rbac)      | configure various RBAC aspects
| **[cluster-auth](charts/cluster-auth.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-auth)      | configure Auth at the cluster level
| **[cluster-console](charts/cluster-console.md)**     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-console)   | configure the openshift console at the cluster level
| **[cluster-storage](charts/cluster-storage.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-storage)       | enable StoragesClass at the cluster level
| **[cluster-logging](charts/cluster-logging.md)**       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-logging)    | deploy a EFK (puit de log) at the cluster level
| **[cluster-pipeline](charts/cluster-pipeline.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-pipeline)  | enable tekton pipeline at the cluster level
| **[cluster-metering](charts/cluster-metering.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-metering)  | enable Metering at the cluster level
| **[cluster-istio](charts/cluster-istio.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-istio)     | enable ServiceMesh at the cluster level
| **[cluster-knative](charts/cluster-knative.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-knative)  | enable Serverless (knative) at the cluster level
| **[cluster-ocs](charts/cluster-ocs.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-ocs)       | enable Openshift Container Storage at the cluster level
| **[cluster-kubevirt](charts/cluster-kubevirt.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-kubevirt)  | enable kubevirt at the cluster level
| **[cluster-vault](charts/cluster-vault.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-vault)     | enable hashicorp vault service at the cluster level
| **[cluster-quay](charts/cluster-quay.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-quay)      | enable Quay.io private repository at the cluster level
| **[cluster-3scale](charts/cluster-3scale.md)**       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-3scale)    | deploy a 3Scale infrastructure at the cluster level
| **[cluster-workspace](charts/cluster-workspace.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-workspace) | enable codeready workspace at the cluster level

#### Use Cluster charts

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
helm install startx/cluster-config
helm install startx/cluster-rbac
helm install startx/cluster-auth
helm install startx/cluster-console
helm install startx/cluster-storage
helm install startx/cluster-logging
helm install startx/cluster-pipeline
helm install startx/cluster-metering
helm install startx/cluster-istio
helm install startx/cluster-knative
helm install startx/cluster-ocs
helm install startx/cluster-kubevirt
helm install startx/cluster-vault
helm install startx/cluster-quay
helm install startx/cluster-3scale
helm install startx/cluster-workspace
```

### Basic Helm charts

Helm chart without prefix are basic chart. Basic charts configure basic element and are mainly used as a dependency of more complex chart.

| Chart                              | Source                                                                            | Description  
| ---------------------------------- | --------------------------------------------------------------------------------- | -------------------------------------
| **[project](charts/project.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/project)  | create a project with limits, quotas, networkpolicy and rbac set
| **[operator](charts/operator.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/operator) | create an operator with subscription (openshift) or CRD (k8s)
| **[sxapi](charts/sxapi.md)**       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/sxapi)    | deploy a small micro-service endpoint

#### Use Basic charts

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
helm install startx/project
helm install startx/operator
helm install startx/sxapi
```

### Example Helm charts

Helm chart prefixed with `example-` are Example chart. Example are used in demo and various workshop to show how to use helm as part of a gitops toolchain.

| Chart                                                  | Source                                                                                      | Description  
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------- | -------------------------------------
| **[example-deployment](charts/example-deployment.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-deployment) | An example on how to deploy simple applications using helm and a deployment
| **[example-pod](charts/example-pod.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-pod)        | An example on how to deploy simple applications using helm and a pod
| **[example-sxapi](charts/example-sxapi.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-sxapi)      | An example on how to deploy simple micro-applications using helm and an sxapi toolkit

#### Use Examples charts

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
helm install startx/example-deployment
helm install startx/example-pod
helm install startx/example-sxapi
```

## Install a local copy of this repository

### 1. Requirements

#### 1.1. install cli dependencies

```bash
yum install yq helm -y
```

#### 1.2. Connect to an openshift cluster

```bash
oc login -t <my-token> <my-openshift-api>
```

If you don't have access to an openshift cluster, consider using codeready-container to
run locally a simulated cluster.

### 2. Install repository copy

#### 2.1. Clonning this repository

```bash
git clone https://startxfr.github.io/helm-repository.git
cd helm-repository
```

#### 2.2. List all charts

```bash
ls charts
```

### 3. Install a local chart

```bash
# oc apply -k charts/<chart>
helm install charts/cluster-config
helm install charts/cluster-rbac
helm install charts/cluster-auth
helm install charts/cluster-console
helm install charts/cluster-storage
helm install charts/cluster-logging
helm install charts/cluster-pipeline
helm install charts/cluster-metering
helm install charts/cluster-istio
helm install charts/cluster-knative
helm install charts/cluster-ocs
helm install charts/cluster-kubevirt
helm install charts/cluster-vault
helm install charts/cluster-quay
helm install charts/cluster-3scale
helm install charts/cluster-workspace
helm install charts/project
helm install charts/operator
helm install charts/sxapi
helm install charts/example-deployment
helm install charts/example-pod
helm install charts/example-sxapi
```

## Install building environment

In order to contribute to this repository, you must get the full developement environment by following the [install build environment guide](install-build)

## History and releases

Read history [traceback](history) for more information on change and released version. Complementary information could be found in the [release convention](releases)
Notice that every chart in this repository follow it's own release lifecycle. You can refer to it by reading every chart documentation page.

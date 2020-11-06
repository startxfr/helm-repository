# Welcome to STARTX helm repository

## Helm list

List of helm chart availables in this repository, and sample to deploy it under your current openshift cluster (must be logged with appropriate rights).

- [cluster-config](charts/cluster-config.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-config))*** for global configuration of an openshift cluster
- [cluster-rbac](charts/cluster-rbac.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-rbac))*** to configure various RBAC aspects
- [cluster-3scale](charts/cluster-3scale.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-3scale))*** to deploy a 3Scale infrastructure at a cluster level
- [cluster-pipeline](charts/cluster-pipeline.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-pipeline))*** to enable tekton pipeline at a cluster level
- [cluster-workspace](charts/cluster-workspace.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-workspace))*** to enable codeready workspace at a cluster level
- [cluster-vault](charts/cluster-vault.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-vault))*** to enable hashicorp vault service at a cluster level
- [cluster-quay](charts/cluster-quay.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-quay))*** to enable Quay.io private repository at a cluster level
- [cluster-ocs](charts/cluster-ocs.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-ocs))*** to enable Openshift Container Storage at a cluster level
- [cluster-metering](charts/cluster-metering.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-metering))*** to enable Metering at a cluster level
- [project](charts/project.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/project))*** to create a project with limits, quotas, networkpolicy and rbac set
- [operator](charts/operator.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/operator))*** to create an operator with subscription (openshift) or CRD (k8s)
- [sxapi](charts/sxapi.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/sxapi))*** to deploy a small micro-service endpoint
- [example-deployment](charts/example-deployment.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/example-deployment))*** is a example on how to deploy simple applications using helm and a deployment
- [example-pod](charts/example-pod.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/example-pod))*** is a example on how to deploy simple applications using helm and a pod
- [example-sxapi](charts/example-sxapi.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/example-sxapi))*** is a example on how to deploy simple micro-applications using helm and an sxapi toolkit

## Examples

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
helm install startx/cluster-config
helm install startx/cluster-rbac
helm install startx/cluster-3scale
helm install startx/cluster-pipeline
helm install startx/cluster-workspace
helm install startx/project
helm install startx/sxapi
helm install startx/example-deployment
helm install startx/example-pod
helm install startx/example-sxapi
```

## Install this repository toolkit

### 1. Requirements

#### 1.1. install cli dependencies

```bash
yum install yq -y
yum install helm -y
```

#### 1.2. Connect to an openshift cluster

```bash
oc login -t <my-token> <my-openshift-api>
```

If you don't have access to an openshift cluster, consider using codeready-container to
run locally a simulated cluster.

### 2. Install repository

#### 2.1. Install this repository

```bash
git clone https://startxfr.github.io/helm-repository.git
cd helm-repository
```

#### 2.2. List all helm packages

```bash
ls charts
```

### 3. Install a helm

```bash
# oc apply -k charts/<chart>
helm install charts/cluster-config
helm install charts/cluster-rbac
helm install charts/cluster-3scale
helm install charts/cluster-pipeline
helm install charts/cluster-workspace
helm install charts/project
helm install charts/sxapi
helm install charts/example-deployment
helm install charts/example-pod
helm install charts/example-sxapi
```

## Install building environment

In order to get the full developement environment, you must follow the [install build environment guide](install-build)

## History and releases

Read history [traceback](history) for more information on change and released version. Complementary information could be found in the [release convention](releases)

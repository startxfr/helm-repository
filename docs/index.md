# Welcome to STARTX helm repository

## Helm list

List of helm chart availables in this repository, and sample to deploy it under your current openshift cluster (must be logged with appropriate rights).

- [cluster-config](charts/cluster-config.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-config))***
- [cluster-rbac](charts/cluster-rbac.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-rbac))***
- [cluster-3scale](charts/cluster-3scale.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-3scale))***
- [demo-project](charts/demo-project.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/demo-project))***
- [demo-sxapi](charts/demo-sxapi.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/demo-sxapi))***
- [example-deployment](charts/example-deployment.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/example-deployment))***
- [example-pod](charts/example-pod.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/example-pod))***
- [example-sxapi](charts/example-sxapi.md) ***([source](https://github.com/startxfr/helm-repository/tree/master/charts/example-sxapi))***

## Examples

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
helm install startx/cluster-config
helm install startx/cluster-rbac
helm install startx/cluster-3scale
helm install startx/demo-project
helm install startx/demo-sxapi
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
helm install charts/demo-project
helm install charts/demo-sxapi
helm install charts/example-deployment
helm install charts/example-pod
helm install charts/example-sxapi
```

## Install building environment

In order to get the full developement environment, you must follow the [install build environment guide](install-build)

## History and releases

Latest release of this repository is v0.0.1 released at 2020-10-13 10:00:00. Read history [traceback](history) for more information
on change and released version. Complementary information could be found in the [release convention](releases)

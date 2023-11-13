# STARTX helm repository

[![release](https://img.shields.io/badge/release-v12.36.64-blue.svg)](https://github.com/startxfr/helm-repository/releases/tag/12.36.64) [![last commit](https://img.shields.io/github/last-commit/startxfr/helm-repository.svg)](https://github.com/startxfr/helm-repository) [![Doc](https://readthedocs.org/projects/helm-repository/badge)](https://helm-repository.readthedocs.io)

helm charts for various infrastructure configuration and services running under an Openshift Container Platform (or OKD).

## Helm repository content

This repository host various helm chart targeting the Openshift Container Platform environment. Charts could be
divided into 4 main category ([basic charts](index.md#basic-helm-charts), [cluster charts](index.md#cluster-helm-charts), [chaos charts](index.md#chaos-helm-charts) and [examples charts](index.md#examples-helm-charts))

### Cluster Helm charts

Helm chart prefixed with `cluster-` are Cluster chart. Cluster charts configure cluster configuration or enable cluster service.

| Chart                                                      | Source                                                                                        | Description                                                       |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| **[cluster-config](charts/cluster-config.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-config)       | global configuration of an openshift cluster                      |
| **[cluster-rbac](charts/cluster-rbac.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-rbac)         | configure various RBAC aspects                                    |
| **[cluster-auth](charts/cluster-auth.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-auth)         | configure Auth at the cluster level                               |
| **[cluster-console](charts/cluster-console.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-console)      | configure the openshift console at the cluster level              |
| **[cluster-storage](charts/cluster-storage.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-storage)      | enable StoragesClass at the cluster level                         |
| **[cluster-localstorage](charts/cluster-localstorage.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-localstorage) | enable local storage at the cluster level                         |
| **[cluster-logging](charts/cluster-logging.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-logging)      | deploy a EFK (puit de log) at the cluster level                   |
| **[cluster-pipeline](charts/cluster-pipeline.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-pipeline)     | enable tekton pipeline at the cluster level                       |
| **[cluster-metering](charts/cluster-metering.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-metering)     | enable Metering at the cluster level                              |
| **[cluster-istio](charts/cluster-istio.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-istio)        | enable ServiceMesh at the cluster level                           |
| **[cluster-knative](charts/cluster-knative.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-knative)      | enable Serverless (knative) at the cluster level                  |
| **[cluster-ocs](charts/cluster-ocs.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-ocs)          | enable Openshift Container Storage at the cluster level           |
| **[cluster-kubevirt](charts/cluster-kubevirt.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-kubevirt)     | enable kubevirt at the cluster level                              |
| **[cluster-vault](charts/cluster-vault.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-vault)        | enable hashicorp vault service at the cluster level               |
| **[cluster-vault-config](charts/cluster-vault-config.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-vault-config) | enable hashicorp vault configuration service at the cluster level |
| **[cluster-quay](charts/cluster-quay.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-quay)         | enable Quay.io private repository at the cluster level            |
| **[cluster-ansible](charts/cluster-ansible.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-ansible)      | enable Ansible automation at the cluster level                    |
| **[cluster-3scale](charts/cluster-3scale.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-3scale)       | deploy a 3Scale infrastructure at the cluster level               |
| **[cluster-workspace](charts/cluster-workspace.md)**       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-workspace)    | enable codeready workspace at the cluster level                   |
| **[cluster-vpa](charts/cluster-vpa.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-vpa)          | enable VerticalPodAutoscaler at the cluster level                 |
| **[cluster-sso](charts/cluster-sso.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-sso)          | enable Redhat-SSO at the cluster level                            |
| **[cluster-ptp](charts/cluster-ptp.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-ptp)          | enable Precision Time Protocol at the cluster level               |
| **[cluster-nexus](charts/cluster-nexus.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-nexus)        | enable Nexus at the cluster level                                 |
| **[cluster-keycloak](charts/cluster-keycloak.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-keycloak)     | enable Keycloak at the cluster level                              |
| **[cluster-jenkins](charts/cluster-jenkins.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-jenkins)      | enable Jenkins at the cluster level                               |
| **[cluster-gitlab](charts/cluster-gitlab.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-gitlab)       | enable Gitlab at the cluster level                                |
| **[cluster-compliance](charts/cluster-compliance.md)**     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-compliance)   | enable Compliance at the cluster level                            |
| **[cluster-machine](charts/cluster-machine.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-machine)      | enable Machine management at the cluster level                    |
| **[cluster-router](charts/cluster-router.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-router)       | enable Router management at the cluster level                     |
| **[cluster-certmanager](charts/cluster-certmanager.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-certmanager)  | enable CertManager at the cluster level                           |
| **[cluster-oadp](charts/cluster-oadp.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-oadp)         | enable Application Data Protection (Backup) at the cluster level  |
| **[cluster-router](charts/cluster-router.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-router)         | configure router(s) at the cluster level  |
| **[cluster-couchbase](charts/cluster-couchbase.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-couchbase)         | configure couchbase at the cluster level  |
| **[cluster-crunchy](charts/cluster-crunchy.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-crunchy)         | configure crunchyDatabase at the cluster level  |

#### Use Cluster charts

```bash
# Add the STARTX helm repository
helm repo add startx https://startxfr.github.io/helm-repository/packages/
# Add individual charts
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
helm install startx/cluster-vpa
helm install startx/cluster-sso
helm install startx/cluster-ptp
helm install startx/cluster-nexus
helm install startx/cluster-keycloak
helm install startx/cluster-jenkins
helm install startx/cluster-gitlab
helm install startx/cluster-compliance
helm install startx/cluster-machine
helm install startx/cluster-certmanager
helm install startx/cluster-oadp
helm install startx/cluster-router
helm install startx/cluster-couchbase
helm install startx/cluster-crunchy
```

### Basic Helm charts

Helm chart without prefix are basic chart. Basic charts configure basic element and are mainly used as a dependency of more complex chart.

| Chart                              | Source                                                                            | Description                                                      |
| ---------------------------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| **[project](charts/project.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/project)  | create a project with limits, quotas, networkpolicy and rbac set |
| **[operator](charts/operator.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/operator) | create an operator with subscription (openshift) or CRD (k8s)    |
| **[sxapi](charts/sxapi.md)**       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/sxapi)    | deploy a small micro-service endpoint                            |

#### Use Basic charts

```bash
# Add the STARTX helm repository
helm repo add startx https://startxfr.github.io/helm-repository/packages/
# Add individual charts
helm install startx/project
helm install startx/operator
helm install startx/sxapi
```

### Chaos Helm charts

Helm chart prefixed with `chaos-` are part of the chaos suite. 
You can deploy various tools used for chaos-testing openshift and kubernetes clusters.

| Chart                                          | Source                                                                                  | Description                                                |
| ---------------------------------------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| **[chaos](charts/chaos.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/chaos)          | Deploy a full chaos test suite                             |
| **[chaos-cerberus](charts/chaos-cerberus.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-cerberus) | Deploy Cerberus component as part of a chaos environment   |
| **[chaos-kraken](charts/chaos-kraken.md)**     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-kraken)   | Deploy Kraken component as part of a chaos environment     |
| **[chaos-mesh](charts/chaos-mesh.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-mesh)     | Deploy Chaos-mesh component as part of a chaos environment |
| **[chaos-litmus](charts/chaos-litmus.md)**     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-litmus)   | Deploy Litmus component as part of a chaos environment     |
| **[chaos-monkey](charts/chaos-monkey.md)**     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/chaos-monkey)   | Deploy Kubemonkey component as part of a chaos environment |

#### Use Chaos charts

```bash
# Add the STARTX helm repository
helm repo add startx https://startxfr.github.io/helm-repository/packages/
# Add individual charts
helm install startx/chaos
helm install startx/chaos-cerberus
helm install startx/chaos-kraken
helm install startx/chaos-mesh
helm install startx/chaos-litmmus
helm install startx/chaos-monkey
```

### Examples Helm charts

Helm chart prefixed with `example-` are Example chart. Example are used in demo and various workshop to show how to use helm as part of a gitops toolchain.

| Chart                                                              | Source                                                                                            | Description                                                                           |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| **[example-imagestreams](charts/example-imagestreams.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-imagestreams)     | An example on how to deploy multiple image streams using helm                         |
| **[example-knative](charts/example-knative.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-knative)          | An example on how to deploy application using serverless                              |
| **[example-deployment](charts/example-deployment.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-deployment)       | An example on how to deploy simple applications using helm and a deployment           |
| **[example-html](charts/example-html.md)**                         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-html)             | An example on how to deploy webserver using helm and a deployment                     |
| **[example-php](charts/example-php.md)**                           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-php)              | An example on how to deploy PHP application                                           |
| **[example-pod](charts/example-pod.md)**                           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-pod)              | An example on how to deploy simple applications using helm and a pod                  |
| **[example-sxapi](charts/example-sxapi.md)**                       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-sxapi)            | An example on how to deploy simple micro-applications using helm and an sxapi toolkit |
| **[example-catalog](charts/example-catalog.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-catalog)          | Various demo examples                                                                 |
| **[example-chaos](charts/example-chaos.md)**                       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-chaos)            | An example for deploying a choas test suite                                           |
| **[example-fruitapp-project](charts/example-fruitapp-project.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-fruitapp-project) | Deploy fruitapp CI/CD demo with common and project structure (like namespaces)        |
| **[example-fruitapp-shared](charts/example-fruitapp-shared.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-fruitapp-shared)  | Deploy shared component like database and secrets                                     |
| **[example-fruitapp-app](charts/example-fruitapp-app.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/example-fruitapp-app)     | Deploy application stack into an environment                                          |

#### Use Examples charts

```bash
# Add the STARTX helm repository
helm repo add startx https://startxfr.github.io/helm-repository/packages/
# Add individual charts
helm install startx/example-deployment
helm install startx/example-html
helm install startx/example-imagestreams
helm install startx/example-knative
helm install startx/example-php
helm install startx/example-pod
helm install startx/example-sxapi
helm install startx/example-chaos
helm install startx/example-fruitapp-project
helm install startx/example-fruitapp-shared
helm install startx/example-fruitapp-app
```

## Install STARTX repository

### 1. Using Helm

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

### 2. Using Openshift

#### 2.1. Deploy via HelmChartRepository

```bash
cat <<EOF | oc apply -f -
apiVersion: helm.openshift.io/v1beta1
kind: HelmChartRepository
metadata:
  name: "startx"
  labels:
    app.kubernetes.io/name: "startx-chart"
spec:
  name: "startx"
  connectionConfig:
    url: "https://startxfr.github.io/helm-repository/packages"
EOF
```

#### 2.2. Deploy via HelmChartRepository (archive)

If you need to run your in an older version of Openshift, or access to archived version of helm chart, 
you can load the archive repository

```bash
cat <<EOF | oc apply -f -
apiVersion: helm.openshift.io/v1beta1
kind: HelmChartRepository
metadata:
  name: "startx-archives"
  labels:
    app.kubernetes.io/name: "startx-archives-chart"
spec:
  name: "startx-archives"
  connectionConfig:
    url: "https://startxfr.github.io/helm-repository/packages-archives"
EOF
```

#### 2.3. List all charts

You can use the [Openshift developper perspective of your console](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.11/html-single/web_console/#odc-about-developer-perspective)

### 3. Install local helm

#### 3.1. Clonning this repository

```bash
git clone https://startxfr.github.io/helm-repository.git
cd helm-repository
```

#### 3.2. List all charts

```bash
# Add the STARTX helm repository
helm repo add startx .
# List all charts in the STARTX repository
helm list startx
```

#### 3.3 Install a local chart

```bash
# Add the STARTX helm repository
helm repo add startx .
# Install the STARTX available chart
helm install <chart-name>
```

## Install using ArgoCD

If you whan to deploy theses charts using ArgoCD, you can follow the [install using ArgoCD guide](install-argocd)

## Install building environment

In order to contribute to this repository, you must get the full developement environment by following the [install build environment guide](install-build)

## History and releases

Read history [traceback](history) for more information on change and released version. Complementary information could be found in the [release convention](releases)
Notice that every chart in this repository follow it's own release lifecycle. You can refer to it by reading every chart documentation page.

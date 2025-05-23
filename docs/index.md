# STARTX helm repository

[![release](https://img.shields.io/badge/release-v17.14.19-blue.svg)](https://github.com/startxfr/helm-repository/releases/tag/17.14.19) [![last commit](https://img.shields.io/github/last-commit/startxfr/helm-repository.svg)](https://github.com/startxfr/helm-repository) [![Doc](https://readthedocs.org/projects/helm-repository/badge)](https://helm-repository.readthedocs.io) [![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX-blue.svg)](https://artifacthub.io/packages/search?repo=startx)

helm charts for various infrastructure configuration and services running under an Openshift Container Platform (or OKD).

## Helm repository content

This repository host various helm chart targeting the Openshift Container Platform environment. Charts could be
divided into 4 main category 

- [basic charts](index.md#basic-helm-charts) used to configure basic element such as project (NS, NP, RB, SA) or operators subscriptions
- [cluster charts](index.md#cluster-helm-charts) used to deploy various add-on at the cluster level
- [chaos charts](index.md#chaos-helm-charts) used to deploy various chaos testing tools and chaos pipelines
- [examples charts](index.md#examples-helm-charts) used to deploy various examples charts

### Basic Charts

Helm chart without prefix are basic chart. Basic charts configure basic element and are mainly used as a dependency of more complex chart.

| Chart                              | Source                                                                            | Description                                                      |
| ---------------------------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| **[project](charts/project.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/project)  | create a project with limits, quotas, networkpolicy and rbac set |
| **[operator](charts/operator.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/operator) | create an operator with subscription (openshift) or CRD (k8s)    |
| **[sxapi](charts/sxapi.md)**       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/sxapi)    | deploy a small micro-service endpoint                            |


### Cluster Charts

Helm chart prefixed with `cluster-` are Cluster chart. Cluster charts configure cluster configuration or enable cluster service.

| Chart                                                        | Source                                                                                         | Description                                                                                                                           |
| ------------------------------------------------------------ | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **[cluster-config](charts/cluster-config.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-config)        | global configuration of an openshift cluster                                                                                          |
| **[cluster-rbac](charts/cluster-rbac.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-rbac)          | configure various RBAC aspects                                                                                                        |
| **[cluster-auth](charts/cluster-auth.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-auth)          | configure Auth at the cluster level                                                                                                   |
| **[cluster-console](charts/cluster-console.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-console)       | configure the openshift console at the cluster level                                                                                  |
| **[cluster-storage](charts/cluster-storage.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-storage)       | enable StoragesClass at the cluster level                                                                                             |
| **[cluster-localstorage](charts/cluster-localstorage.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-localstorage)  | enable local storage at the cluster level                                                                                             |
| **[cluster-logging](charts/cluster-logging.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-logging)       | deploy a EFK (puit de log) at the cluster level                                                                                       |
| **[cluster-pipeline](charts/cluster-pipeline.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-pipeline)      | enable tekton pipeline at the cluster level                                                                                           |
| **[cluster-istio](charts/cluster-istio.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-istio)         | enable ServiceMesh at the cluster level                                                                                               |
| **[cluster-knative](charts/cluster-knative.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-knative)       | enable Serverless (knative) at the cluster level                                                                                      |
| **[cluster-ocs](charts/cluster-ocs.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-ocs)           | enable Openshift Container Storage at the cluster level                                                                               |
| **[cluster-kubevirt](charts/cluster-kubevirt.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-kubevirt)      | enable kubevirt at the cluster level                                                                                                  |
| **[cluster-vault](charts/cluster-vault.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-vault)         | enable hashicorp vault service at the cluster level                                                                                   |
| **[cluster-vault-config](charts/cluster-vault-config.md)**   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-vault-config)  | enable hashicorp vault configuration service at the cluster level                                                                     |
| **[cluster-quay](charts/cluster-quay.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-quay)          | enable Quay.io private repository at the cluster level                                                                                |
| **[cluster-ansible](charts/cluster-ansible.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-ansible)       | enable Ansible automation at the cluster level                                                                                        |
| **[cluster-3scale](charts/cluster-3scale.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-3scale)        | deploy a 3Scale infrastructure at the cluster level                                                                                   |
| **[cluster-vpa](charts/cluster-vpa.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-vpa)           | enable VerticalPodAutoscaler at the cluster level                                                                                     |
| **[cluster-sso](charts/cluster-sso.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-sso)           | enable Redhat-SSO at the cluster level                                                                                                |
| **[cluster-ptp](charts/cluster-ptp.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-ptp)           | enable Precision Time Protocol at the cluster level                                                                                   |
| **[cluster-nexus](charts/cluster-nexus.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-nexus)         | enable Nexus at the cluster level                                                                                                     |
| **[cluster-keycloak](charts/cluster-keycloak.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-keycloak)      | enable Keycloak at the cluster level                                                                                                  |
| **[cluster-gitlab](charts/cluster-gitlab.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-gitlab)        | enable Gitlab at the cluster level                                                                                                    |
| **[cluster-compliance](charts/cluster-compliance.md)**       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-compliance)    | enable Compliance at the cluster level                                                                                                |
| **[cluster-machine](charts/cluster-machine.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-machine)       | enable Machine management at the cluster level                                                                                        |
| **[cluster-router](charts/cluster-router.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-router)        | enable Router management at the cluster level                                                                                         |
| **[cluster-certmanager](charts/cluster-certmanager.md)**     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-certmanager)   | enable CertManager at the cluster level                                                                                               |
| **[cluster-oadp](charts/cluster-oadp.md)**                   | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-oadp)          | enable Application Data Protection (Backup) at the cluster level                                                                      |
| **[cluster-router](charts/cluster-router.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-router)        | configure router(s) at the cluster level                                                                                              |
| **[cluster-couchbase](charts/cluster-couchbase.md)**         | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-couchbase)     | configure couchbase at the cluster level                                                                                              |
| **[cluster-crunchy](charts/cluster-crunchy.md)**             | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-crunchy)       | configure crunchyDatabase at the cluster level                                                                                        |
| **[cluster-mustgather](charts/cluster-mustgather.md)**       | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-mustgather)    | configure mustgather at the cluster level                                                                                             |
| **[cluster-nfd](charts/cluster-nfd.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-nfd)           | configure Node Feature Discovery at the cluster level                                                                                 |
| **[cluster-gpu](charts/cluster-gpu.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-gpu)           | configure GPU Drivers (NVidia) at the cluster level                                                                                   |
| **[cluster-descheduler](charts/cluster-descheduler.md)**     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-descheduler)   | configure KubeDescheduler to optimize pod distribution                                                                                |
| **[cluster-mtv](charts/cluster-mtv.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-mtv)           | configure Migration toolkit for virtualisation                                                                                        |
| **[cluster-mtc](charts/cluster-mtc.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-mtc)           | configure Migration toolkit for Containers                                                                                            |
| **[cluster-mtr](charts/cluster-mtr.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-mtr)           | configure Migration toolkit for Runtimes                                                                                              |
| **[cluster-devworkspaces](charts/cluster-devworkspaces.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-devworkspaces) | enable Dev workspace at the cluster level                                                                                             |
| **[cluster-costs](charts/cluster-costs.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-costs)         | configure the costs management features                                                                                               |
| **[cluster-maintenance](charts/cluster-maintenance.md)**     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-maintenance)   | configure the node maintenance feature                                                                                                |
| **[cluster-mongo](charts/cluster-mongo.md)**                 | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-mongo)         | configure MongoDB at the cluster level                                                                                                |
| **[cluster-kubecost](charts/cluster-kubecost.md)**           | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-kubecost)      | enable Kubecost cost dashboard                                                                                                        |
| **[cluster-kepler](charts/cluster-kepler.md)**               | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-kepler)        | enable Kepler power consumption observability                                                                                         |
| **[cluster-dvo](charts/cluster-dvo.md)**                     | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-dvo)           | enable Deployment Validation Operator (DVO)  to checks deployments and other resources against a curated collection of best practices |


### Chaos Charts

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

### Examples Charts

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

### Deprecated Charts

List of the deprecated helm charts.

| Chart                                              | Source                                                                                | Description                |
| -------------------------------------------------- | ------------------------------------------------------------------------------------- | -------------------------- |
| **[cluster-metering](charts/cluster-metering.md)** | [source](https://github.com/startxfr/helm-repository/tree/14/charts/cluster-metering) | REPLACED by costManagement |
| **[cluster-jenkins](charts/cluster-jenkins.md)**   | [source](https://github.com/startxfr/helm-repository/tree/14/charts/cluster-jenkins)  | NOT used anymore           |  | **[cluster-workspace](charts/cluster-workspace.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/cluster-workspace) | REPLACED by cluster-devworkspaces chart |


### Helm repositories

=== "Stable"

    |                 |                                                                                                |
    | --------------- | ---------------------------------------------------------------------------------------------- |
    | **Repository**  | **[stable](https://helm-repository.readthedocs.io/en/latest/repos/stable/index.yaml)**         |
    | **Description** | The default repository  with latest stable release for 16,15,14,13,12,11,10,9,8 and 7 releases |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable`           |

=== "Noschema"

    |                 |                                                                                                 |
    | --------------- | ----------------------------------------------------------------------------------------------- |
    | **Repository**  | **[noschema](https://helm-repository.readthedocs.io/en/latest/repos/noschema/index.yaml)**      |
    | **Description** | Repository without schema definition                                                            |
    | **Command**     | `helm repo add startx-noschema https://helm-repository.readthedocs.io/en/latest/repos/noschema` |

=== "17"

    |                 |                                                                                  |
    | --------------- | -------------------------------------------------------------------------------- |
    | **Repository**  | **[17](https://helm-repository.readthedocs.io/en/latest/repos/17/index.yaml)**   |
    | **Description** | Archive repository for the 17.x packages (Compatible with OCP 4.17.x)            |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/17` |

=== "16"

    |                 |                                                                                  |
    | --------------- | -------------------------------------------------------------------------------- |
    | **Repository**  | **[16](https://helm-repository.readthedocs.io/en/latest/repos/16/index.yaml)**   |
    | **Description** | Archive repository for the 16.x packages (Compatible with OCP 4.16.x)            |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/16` |

=== "15"

    |                 |                                                                                  |
    | --------------- | -------------------------------------------------------------------------------- |
    | **Repository**  | **[15](https://helm-repository.readthedocs.io/en/latest/repos/15/index.yaml)**   |
    | **Description** | Archive repository for the 15.x packages (Compatible with OCP 4.15.x)            |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/15` |

=== "14"

    |                 |                                                                                  |
    | --------------- | -------------------------------------------------------------------------------- |
    | **Repository**  | **[14](https://helm-repository.readthedocs.io/en/latest/repos/14/index.yaml)**   |
    | **Description** | Archive repository for the 14.x packages (Compatible with OCP 4.14.x)            |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/14` |

=== "13"

    |                 |                                                                                  |
    | --------------- | -------------------------------------------------------------------------------- |
    | **Repository**  | **[13](https://helm-repository.readthedocs.io/en/latest/repos/13/index.yaml)**   |
    | **Description** | Archive repository for the 13.x packages (Compatible with OCP 4.13.x)            |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/13` |

=== "12"

    |                 |                                                                                  |
    | --------------- | -------------------------------------------------------------------------------- |
    | **Repository**  | **[12](https://helm-repository.readthedocs.io/en/latest/repos/12/index.yaml)**   |
    | **Description** | Archive repository for the 12.x packages (Compatible with OCP 4.12.x)            |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/12` |

=== "11"

    |                 |                                                                                  |
    | --------------- | -------------------------------------------------------------------------------- |
    | **Repository**  | **[11](https://helm-repository.readthedocs.io/en/latest/repos/11/index.yaml)**   |
    | **Description** | Archive repository for the 11.x packages (Compatible with OCP 4.11.x)            |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/11` |

=== "10"

    |                 |                                                                                  |
    | --------------- | -------------------------------------------------------------------------------- |
    | **Repository**  | **[10](https://helm-repository.readthedocs.io/en/latest/repos/10/index.yaml)**   |
    | **Description** | Archive repository for the 10.x packages (Compatible with OCP 4.10.x)            |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/10` |

=== "9"

    |                 |                                                                                 |
    | --------------- | ------------------------------------------------------------------------------- |
    | **Repository**  | **[9](https://helm-repository.readthedocs.io/en/latest/repos/9/index.yaml)**    |
    | **Description** | Archive repository for the 9.x packages (Compatible with OCP 4.9.x)             |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/9` |

=== "8"

    |                 |                                                                                 |
    | --------------- | ------------------------------------------------------------------------------- |
    | **Repository**  | **[8](https://helm-repository.readthedocs.io/en/latest/repos/8/index.yaml)**    |
    | **Description** | Archive repository for the 8.x packages (Compatible with OCP 4.8.x)             |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/8` |

=== "7"

    |                 |                                                                                 |
    | --------------- | ------------------------------------------------------------------------------- |
    | **Repository**  | **[7](https://helm-repository.readthedocs.io/en/latest/repos/7/index.yaml)**    |
    | **Description** | Archive repository for the 7.x packages (Compatible with OCP 4.7.x)             |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/7` |

=== "6 and previous"

    |                 |                                                                                  |
    | --------------- | -------------------------------------------------------------------------------- |
    | **Repository**  | **[6x](https://helm-repository.readthedocs.io/en/latest/repos/6x/index.yaml)**   |
    | **Description** | Archive repository for the 6.x packages (Compatible with OCP 4.6.x)              |
    | **Command**     | `helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/6x` |


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

#### 1.3. Add the startx helm repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable
```

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
    url: "https://helm-repository.readthedocs.io/en/latest/repos/stable"
EOF
```

#### 2.2. Deploy via HelmChartRepository (archive)

If you need to run your in an older version of Openshift, or access to archived version of helm chart, 
you can load one of the archive repository. 

This example show how to load charts from the v13 archive repository.

```bash
cat <<EOF | oc apply -f -
apiVersion: helm.openshift.io/v1beta1
kind: HelmChartRepository
metadata:
  name: "startx-v13"
  labels:
    app.kubernetes.io/name: "startx-v13-charts"
spec:
  name: "startx-v13"
  connectionConfig:
    url: "https://helm-repository.readthedocs.io/en/latest/repos/13"
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

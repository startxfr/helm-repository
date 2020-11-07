# STARTX helm : operator

This helm chart is used to configure various operator using subscription (openshift) or CRD (k8s) ressources.

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
helm show chart startx/operator
```

### 4. Install this chart

```bash
helm install startx/operator
```

## Default values

Deployment of codeready-workspace subscription with :

- 1 **operatorGroup** named **codeready-workspaces** with the following characteristics
  - deployed in namespace **openshift-workspaces**
  - provide API **CheCluster.v1.org.eclipse.che**
- 1 **subscription** named **codeready-workspaces** to deploy codeready operator with the following characteristics
  - operator name is **codeready-workspaces**
  - operator version is **2.3.0**
  - operator catalog is **redhat-operators** located in **openshift-marketplace**

```bash
# base configuration running default configuration
helm install startx/operator
```

## Others values availables

- **values-crw-2.3.0** : Startx codeready-workspace operator version 2.3.0 (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-crw-2.3.0.yaml)) deploying the following environment
  - 1 **operatorGroup** named **codeready-workspaces** with the following characteristics
    - deployed in namespace **openshift-workspaces**
    - provide API **CheCluster.v1.org.eclipse.che**
  - 1 **subscription** named **codeready-workspaces** to deploy codeready operator with the following characteristics
    - operator name is **codeready-workspaces**
    - operator version is **2.3.0**
    - operator catalog is **redhat-operators** located in **openshift-marketplace**

```bash
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-crw-2.3.0.yaml
```

- **values-tekton-1.0.1** : Startx codeready-workspace operator version 2.3.0 (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-tekton-1.0.1.yaml)) deploying the following environment
  - 1 **subscription** named **openshift-pipelines-operator-rh** to deploy tekton operator with the following characteristics
    - operator name is **openshift-pipelines-operator-rh**
    - operator is deployed in the **openshift-operators** namespace
    - operator version is **1.0.1**
    - operator catalog is **redhat-operators** located in **openshift-marketplace**
    - operator channel is **ocp-4.5**
    - operator custom provider is **openshift-pipelines-operator**

```bash
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-tekton-1.0.1.yaml
```

- **values-3scale-0.6.0** : Startx 3scale operator version 0.6.0 (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-3scale-0.6.0.yaml)) deploying the following environment
  - 1 **operatorGroup** named **3scale-operator** with the following characteristics
    - deployed in namespace **startx-3scale**
    - provide all 3scale API
  - 1 **subscription** named **3scale-operator** to deploy codeready operator with the following characteristics
    - operator name is **3scale-operator**
    - operator is deployed in the **startx-3scale** namespace
    - operator version is **0.6.0**
    - operator catalog is **redhat-operators** located in **openshift-marketplace**
    - operator channel is **threescale-2.9**
    - operator custom provider is **3scale-operator**

```bash
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-3scale-0.6.0.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.36  | 2020-10-31 | Initial commit for this helm chart with default value example
| 0.2.37  | 2020-10-31 | Enable subscription and operatorGroup creation and add values file for tekton-1.0.1, crw-2.3.0 and scale-0.6.0 deployment
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.1   | 2020-11-01 | Move to go templates for notes generation
| 0.3.3   | 2020-11-01 | Test new scope for note template helper
| 0.3.21  | 2020-11-06 | Align all charts on the repository release 0.3.21
| 0.3.23  | 2020-11-07 | Add engineVersion to all chart (set to 4.5.12) and update all appVersion with the relevant information
| 0.3.25  | 2020-11-07 | NOTES content is more accurate and detailed
| 0.3.27  | 2020-11-07 | Stable notes
| 0.3.29  | 2020-11-07 | Improve helm hook ordering cordinated with higher cluster-xxx helm chart depending on this chart
| 0.3.30  | 2020-11-08 | Improve operator options

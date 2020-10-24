# STARTX helm : demo-project

This helm chart is used to create a project, or namespace, with various options constraint resources
like networkPolicy, RoleBinding, LimitRange and Quotas.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### Get information about this chart

```bash
helm show chart startx/demo-project
```

### Install this chart

```bash
helm install startx/demo-project
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **project** named **example**
- 1 **project role** giving the **basic-user** role to **mygroup_example** group
- 1 **project role** giving the **basic-user** role to **myuser_example** user
- 2 project **networkPolicy** rule to allow ingress traffic and traffic from same namespace
- 1 project **limitRange** with the following parameters
  - Pod minimum to 20m CPU and 20M memory
  - Pod maximum to 200m CPU and 256Mi memory
  - Container minimum to 10m CPU and 10M memory
  - Container maximum to 100m CPU and 128Mi memory
- 1 project **quotas** with the following parameters
  - Maximum CPU limit set to 800m
  - Maximum memory limit set to 1024Mi
  - Maximum CPU request set to 400m
  - Maximum memory request set to 512Mi
  - Pod maximum to 200m CPU and 256Mi memory
  - No persistent volume claim
  - Maximum of 4 pods in the project
  - Maximum of 2 services in the project

```bash
# base configuration running default configuration
helm install startx/demo-project
```

## Others values availables

- **startx** : Default STARTX project environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-project/values-startx.yaml))

```bash
helm install startx/demo-project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-project/values-startx.yaml
```

- **demo-argocd** : Startx demo argocd project environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-project/values-demo-argocd.yaml))

```bash
helm install startx/demo-project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-project/values-demo-argocd.yaml
```

- **demo-helm** : Startx demo helm project environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-project/values-demo-helm.yaml))

```bash
helm install startx/demo-project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-project/values-demo-helm.yaml
```

- **demo-kustomize** : Startx demo kustomize project environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-project/values-demo-kustomize.yaml))

```bash
helm install startx/demo-project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/demo-project/values-demo-kustomize.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.0.1   | 2020-10-01 | Initial commit
| 0.1.0   | 2020-10-07 | Release 0.1 stable release for all charts
| 0.1.22  | 2020-10-23 | add user support and update startx demo value example
| 0.2.0   | 2020-10-24 | Improve cluster-rbac options
| 0.2.1  | 2020-10-24 | publish stable update for the full repository
| 0.2.2  | 2020-10-24 | Repository update with all chart release

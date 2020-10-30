# STARTX helm : operator

This helm chart is used to create a operator, or namespace, with various options constraint resources
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
helm show chart startx/operator
```

### Install this chart

```bash
helm install startx/operator
```

## Default values

Complete deployment of a operator with the following characteristics :

- 1 **operator** named **example**
- 1 **operator role** giving the **basic-user** role to **mygroup_example** group
- 1 **operator role** giving the **basic-user** role to **myuser_example** user
- 2 operator **networkPolicy** rule to allow ingress traffic and traffic from same namespace
- 1 operator **limitRange** with the following parameters
  - Pod minimum to 20m CPU and 20M memory
  - Pod maximum to 200m CPU and 256Mi memory
  - Container minimum to 10m CPU and 10M memory
  - Container maximum to 100m CPU and 128Mi memory
- 1 operator **quotas** with the following parameters
  - Maximum CPU limit set to 800m
  - Maximum memory limit set to 1024Mi
  - Maximum CPU request set to 400m
  - Maximum memory request set to 512Mi
  - Pod maximum to 200m CPU and 256Mi memory
  - No persistent volume claim
  - Maximum of 4 pods in the operator
  - Maximum of 2 services in the operator

```bash
# base configuration running default configuration
helm install startx/operator
```

## Others values availables

- **startx** : Default STARTX operator environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-startx.yaml))

```bash
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-startx.yaml
```

- **demo-argocd** : Startx demo argocd operator environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-demo-argocd.yaml))

```bash
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-demo-argocd.yaml
```

- **demo-helm** : Startx demo helm operator environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-demo-helm.yaml))

```bash
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-demo-helm.yaml
```

- **demo-kustomize** : Startx demo kustomize operator environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-demo-kustomize.yaml))

```bash
helm install startx/operator -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/operator/values-demo-kustomize.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.0.1   | 2020-09-14 | Initial commit for this repository
| 0.2.5   | 2020-10-23 | Create operator context
| 0.2.8   | 2020-10-24 | Improve operator options
| 0.2.11  | 2020-10-25 | publish stable update for the full repository
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release
| 0.2.33  | 2020-10-30 | Create chart operator from project

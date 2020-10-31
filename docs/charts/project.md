# STARTX helm : project

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
helm show chart startx/project
```

### Install this chart

```bash
helm install startx/project
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
helm install startx/project
```

## Others values availables

- **startx** : Default STARTX project environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx.yaml))

```bash
helm install startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-startx.yaml
```

- **demo-argocd** : Startx demo argocd project environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-argocd.yaml))

```bash
helm install startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-argocd.yaml
```

- **demo-helm** : Startx demo helm project environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-helm.yaml))

```bash
helm install startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-helm.yaml
```

- **demo-kustomize** : Startx demo kustomize project environment (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-kustomize.yaml))

```bash
helm install startx/project -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/project/values-demo-kustomize.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.2.33  | 2020-10-31 | Initial commit for this helm chart with default value example
| 0.2.51  | 2020-10-31 | Adding vlaues files for startx, kustomize, helm and argocd projects creation
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.2.94  | 2020-10-31 | Aligned stable release of all startx charts
| 0.2.96  | 2020-10-31 | Stable version 0.2.96 preparing the 0.3 release
| 0.2.96  | 2020-10-31 | Stable version 0.2.96 preparing 0.3 release

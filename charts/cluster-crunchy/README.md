# Cluster crunchy

This helm chart is used to deploy CrunchyDB instances managed by a dedicated operator.
This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-crunchy
```

### 4. Install this chart

```bash
helm install cluster-crunchy startx/cluster-crunchy
```

## Deploy this helm chart with ArgoCD

### 1. Create the project

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-project
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "crunchy-demo"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "stable"
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: project.enabled
      value: "true"
EOF
```

## 2. Deploy the operator

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-operator
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "openshift-operators"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "stable"
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: operator.enabled
      value: "true"
EOF
```

## 2. Deploy a crunchy instance

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: crunchy-instance
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "crunchy-demo"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-crunchy/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "stable"
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: cluster.enabled
      value: "true"
    - name: loader.enabled
      value: "true"
EOF
```

## Default values

Complete deployment of a project with the following characteristics :

xxxxxx TO DO xxxxxx

```bash
# base configuration running default configuration
helm install cluster-crunchy startx/cluster-crunchy
```

## Others values availables

- **startx** : CrunchyDB operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx.yaml))

```bash
helm install cluster-crunchy startx/cluster-crunchy -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx.yaml
```

## History

| Release  | Date       | Description                                            |
| -------- | ---------- | ------------------------------------------------------ |
| 11.28.68 | 2023-02-26 | Create cluster-crunchy skeleton from cluster-couchbase |
| 11.28.68 | 2023-02-26 | Create cluster-crunchy skeleton from cluster-couchbase
| 11.28.69 | 2023-03-07 | publish stable update for the full repository
| 11.28.89 | 2023-04-01 | publish stable update for the full repository

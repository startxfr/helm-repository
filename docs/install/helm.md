# install via helm

## 0. Requirements

```bash
yum install yq helm -y
```

## 1. Connect to an openshift cluster

```bash
oc login -t <my-token> <my-openshift-api>
```

If you don't have access to an openshift cluster, consider using codeready-container to
run locally a simulated cluster.

## 2. Add the startx helm repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable
```

## 3. Install your release

Install the chart into your cluster

```bash
helm install mypod  startx/example-pod
```

## 4. Delete your release

Uninstall the chart in your cluster.

```bash
helm uninstall mypod
```

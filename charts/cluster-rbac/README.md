# Helm-chart STARTX : cluster-rbac

This helm chart used to configure cluster RBAC

## Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

## Get information about this chart

```bash
helm show chart startx/cluster-rbac
```

## Install this chart

```bash
helm install cluster-rbac startx/cluster-rbac
```

## Install specific values

This chart is delivered with 2 values files :

### Default values

```bash
helm template cluster-rbac startx/cluster-rbac -v https://github.com/startxfr/helm-repository/blob/master/charts/cluster-rbac/values.yaml | oc apply -f -
```

### startx values

```bash
helm template cluster-rbac startx/cluster-rbac -v https://github.com/startxfr/helm-repository/blob/master/charts/cluster-rbac/values-startx.yaml | oc apply -f -
```
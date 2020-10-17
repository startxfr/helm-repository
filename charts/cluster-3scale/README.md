# Helm-chart STARTX : cluster-3scale

This helm chart used to configure 3scale at the cluster level

## Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

## Get information about this chart

```bash
helm show chart startx/cluster-3scale
```

## Install this chart

```bash
helm install cluster-3scale startx/cluster-3scale
```

## Install specific values

This chart is delivered with 2 values files :

### Default values

```bash
helm template cluster-3scale startx/cluster-3scale -v https://github.com/startxfr/helm-repository/blob/master/charts/cluster-3scale/values.yaml | oc apply -f -
```

### startx values

```bash
helm template cluster-3scale startx/cluster-3scale -v https://github.com/startxfr/helm-repository/blob/master/charts/cluster-3scale/values-startx.yaml | oc apply -f -
```

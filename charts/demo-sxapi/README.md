# Helm-chart STARTX : demo-sxapi

This helm chart must have a description

## Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

## Get information about this chart

```bash
helm show chart startx/demo-sxapi
```

## Install this chart

```bash
helm install startx/demo-sxapi
```

## Install specific values

This chart is delivered with 4 values files :

### Default values

```bash
helm template demo-sxapi startx/demo-sxapi -v https://github.com/startxfr/helm-repository/blob/master/charts/demo-sxapi/values.yaml | oc apply -f -
```

### dev values

```bash
helm template demo-sxapi startx/demo-sxapi -v https://github.com/startxfr/helm-repository/blob/master/charts/demo-sxapi/values-dev.yaml | oc apply -f -
```

### version 0.0.1 values

```bash
helm template demo-sxapi startx/demo-sxapi -v https://github.com/startxfr/helm-repository/blob/master/charts/demo-sxapi/values-v0.0.1.yaml | oc apply -f -
```

### version 0.0.2 values

```bash
helm template demo-sxapi startx/demo-sxapi -v https://github.com/startxfr/helm-repository/blob/master/charts/demo-sxapi/values-v0.0.2.yaml | oc apply -f -
```

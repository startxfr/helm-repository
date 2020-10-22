# Helm-chart STARTX : example-sxapi

This helm chart must have a description

## Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

## Get information about this chart

```bash
helm show chart startx/example-sxapi
```

## Install this chart

```bash
helm install startx/example-sxapi
```

## Install specific values

This chart is delivered with 4 values files :

### Default values

```bash
helm template example-sxapi startx/example-sxapi -v https://github.com/startxfr/helm-repository/blob/master/charts/example-sxapi/values.yaml | oc apply -f -
```

### dev values

```bash
helm template example-sxapi startx/example-sxapi -v https://github.com/startxfr/helm-repository/blob/master/charts/example-sxapi/values-dev.yaml | oc apply -f -
```

### version 0.0.1 values

```bash
helm template example-sxapi startx/example-sxapi -v https://github.com/startxfr/helm-repository/blob/master/charts/example-sxapi/values-v0.0.1.yaml | oc apply -f -
```

### version 0.0.2 values

```bash
helm template example-sxapi startx/example-sxapi -v https://github.com/startxfr/helm-repository/blob/master/charts/example-sxapi/values-v0.0.2.yaml | oc apply -f -
```

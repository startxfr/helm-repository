# Helm-chart STARTX : cluster-config

This helm chart used to configure cluster generic behaviours like image prunning and cluster auto-scaling capacity 

## Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-charts-ocp-infra/packages/
```

## Get information about this chart

```bash
helm show chart startx/cluster-config
```

## Install this chart

This chart is use as a package envelop for configuration of cluster ressources already existing
It can't be use as a common helm-chart (using ```helm install```) but should be used the
following way :

```bash
helm template cluster-config startx/cluster-config | oc apply -f -
```

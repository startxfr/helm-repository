# Helm-chart STARTX : cluster-acm

This helm chart must have a description

## Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

## Get information about this chart

```bash
helm show chart startx/cluster-acm
```

## Install this chart

```bash
helm install startx/cluster-acm
```
| 0.0.1  | 2021-01-23 | Create chart cluster-acm from _sample_
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13
| 0.3.153 | 2021-01-23 | publish stable update for the full repository
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments

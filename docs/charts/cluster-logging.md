# ![cluster-logging](https://helm-repository.readthedocs.io/en/latest/img/cluster-logging.svg "Cluster Chart : Logging") Cluster Chart : Logging
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--logging-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+logging+startx)

This helm chart is used to configure Metering at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-logging
```

### 4. Install this chart

```bash
helm install cluster-logging startx/cluster-logging
```

## Default values

Complete deployment of a project with the following characteristics :

Complete deployment of a Logging configuration with the following characteristics :

- 1 **operator** named **cluster-logging** deployed under **openshift-logging**
- 1 **ClusterLogging** instance with configurable log store (Loki or Elastic)
- Optional **ClusterLogForwarder** for external log routing
- Optional **EventRouter** for Kubernetes event collection

## Values files

- **client1** : [values-client1.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-client1.yaml)
- **client2** : [values-client2.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-client2.yaml)
- **mgmt1** : [values-mgmt1.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-mgmt1.yaml)
- **pfd** : [values-pfd.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-pfd.yaml)
- **startx** : [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-startx.yaml)
- **startx_noinfra** : [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-startx_noinfra.yaml)

```bash
helm install cluster-logging startx/cluster-logging -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-logging/values-client1.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-logging/examples/argocd/
oc apply -k .
```

### Applications



## External secrets

The log forwarder secret (`logforwarder.secret`) can come from an external
store (Vault, AWS Secrets Manager...) through the
[External Secrets Operator](https://external-secrets.io) instead of the chart
values. With `logforwarder.secret.externalSecret.enabled: true`, the chart
renders an `ExternalSecret` producing the Secret `logforwarder.secret.name` in
the logging namespace, with the keys of your choice, so the
`ClusterLogForwarder` outputs referencing it are unchanged. Without
`externalSecret`, the chart keeps rendering the Secret from the values.

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
logforwarder:
  secret:
    enabled: true
    name: elasticsearch-external
    externalSecret:
      enabled: true
      dataFrom:
        - extract:
            key: ocp/logging/elasticsearch
```

An `externalSecret` block accepts `secretStoreRef` and `refreshInterval`
(defaults: `externalSecretDefaults`), `remoteRefs` (map of secret key to ESO
`remoteRef`) and the raw ESO fields `data`, `dataFrom` and `template`. Rendering
fails when no store is set or when no key source is provided.

## History

| Release  | Date       | Description                                                                                                      |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.75 | 2026-01-22 | Adding creation of the logging-admin service account |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.12 | 2026-06-18 | Improve cluster-logging options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |
| 21.3.412 | 2026-11-22 | full repository release: internal pins on the previous published version (ADR-0006) |
| 21.3.416 | 2026-11-23 | stable update: chart fixes (project, cluster-mongo, cluster-oadp, cluster-pipeline, cluster-machine, example-catalog); cluster-dvo accepts the grafana keys next to graphana, which keeps priority |

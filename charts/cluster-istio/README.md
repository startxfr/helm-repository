# ![cluster-istio](https://helm-repository.readthedocs.io/en/latest/img/cluster-istio.svg "Cluster Chart : Istio") Cluster Chart : Istio
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--istio-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+istio+startx)

This helm chart is used to configure Istio at the cluster level.

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
helm show chart startx/cluster-istio
```

### 4. Install this chart

```bash
helm install cluster-istio startx/cluster-istio
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **openshift-distributed-tracing** without constraints
- 1 **operator:** named **servicemeshoperator** configured with
  - The **stable** channel for community release
  - The **v2.6.17** version
  - Deployed under the **openshift-operators** project
- 1 **operator:** named **jaeger-product** configured with
  - The **stable** channel for community release
  - The **v1.65.0** version
  - Deployed under the **openshift-distributed-tracing** project
- 1 **operator:** named **kiali-ossm** configured with
  - The **stable** channel for community release
  - The **v2.22.5** version
  - Deployed under the **openshift-operators** project
- 1 **operator:** named **loki-operator** configured with
  - The **stable-6.2** channel for community release
  - The **6.2.1** version
  - Deployed under the **openshift-operators-redhat** project
- 1 **operator:** named **elasticsearch-operator** configured with
  - The **stable** channel for community release
  - The **5.8.19** version
  - Deployed under the **openshift-operators-redhat** project


```bash
# Create the project
helm install cluster-gpu-project startx/cluster-gpu --set project.enabled=true,operator.enabled=false,gpu.enabled=false
# Deploy the istio operator
helm install cluster-gpu-operator startx/cluster-gpu --set project.enabled=false,operator.enabled=true,gpu.enabled=false && sleep 10
# Configure default istio resources
helm install cluster-gpu-instance startx/cluster-gpu --set project.enabled=false,operator.enabled=false,gpu.enabled=true
```

### Sail operator (Service Mesh 3)

The `sail` values deploy the `sailoperator.io/v1` `IstioCNI` and `Istio` resources and the `telemetry.istio.io/v1` `Telemetry` resources, as an alternative to the `maistra.io` `ServiceMeshControlPlane`. Each list item accepts `labels`, `annotations` (override the default sync-wave 20, 25 and 30) and a free `spec`. The Sail operator is installed by `operatorSail.enabled` (package `servicemeshoperator3`, `openshift-operators`, no OperatorGroup): check the package and channel of your catalog before enabling it.

## Values files

- **startx** : Startx Istio service configuration using service-mesh operator (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-startx.yaml))

```bash
helm install cluster-istio startx/cluster-istio -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-startx.yaml
```

### Other values files

Values files without a detailed section above (each one is a complete set of values for `helm install cluster-istio startx/cluster-istio -f <file>`) :

- [values-members-demo-istio-mg.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-members-demo-istio-mg.yaml) : against `values-startx.yaml`: differ on 140 keys, by top-level key: `operatorJaeger` (23), `project` (23), `operatorElastic` (22), `operatorIstio` (22), ...
- [values-members-demo-istio.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-members-demo-istio.yaml) : context `startx/default/infra`; against `values-startx.yaml`: differ on 140 keys, by top-level key: `operatorJaeger` (23), `project` (23), `operatorElastic` (22), `operatorIstio` (22), ...
- [values-members-sxv4-dev.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-members-sxv4-dev.yaml) : context `startx/default/infra`; against `values-startx.yaml`: differ on 141 keys, by top-level key: `operatorJaeger` (23), `project` (23), `operatorElastic` (22), `operatorIstio` (22), ...
- [values-members-sxv4-factory.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-members-sxv4-factory.yaml) : context `startx/default/infra`; against `values-startx.yaml`: differ on 141 keys, by top-level key: `operatorJaeger` (23), `project` (23), `operatorElastic` (22), `operatorIstio` (22), ...
- [values-members-sxv4-preprod.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-members-sxv4-preprod.yaml) : context `startx/default/infra`; against `values-startx.yaml`: differ on 141 keys, by top-level key: `operatorJaeger` (23), `project` (23), `operatorElastic` (22), `operatorIstio` (22), ...
- [values-members-sxv4-prod.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-members-sxv4-prod.yaml) : context `startx/default/infra`; against `values-startx.yaml`: differ on 141 keys, by top-level key: `operatorJaeger` (23), `project` (23), `operatorElastic` (22), `operatorIstio` (22), ...
- [values-members.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-members.yaml) : context `startx/default/infra`; against `values-startx.yaml`: differ on 138 keys, by top-level key: `operatorJaeger` (23), `project` (23), `operatorElastic` (22), `operatorIstio` (22), ...
- [values-mg.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-mg.yaml) : against `values-startx.yaml`: differ on 15 keys, by top-level key: `project` (4), `operatorIstio` (3), `operatorKiali` (3), `istio` (2), ...
- [values-prgmk.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-prgmk.yaml) : against `values-startx.yaml`: differ on 27 keys, by top-level key: `project` (10), `operatorIstio` (4), `operatorKiali` (4), `context` (2), ...
- [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-istio/values-startx_noinfra.yaml) : context `startx/default/infra`; against `values-startx.yaml`: differ on 5 keys, by top-level key: `operatorElastic` (1), `operatorIstio` (1), `operatorJaeger` (1), `operatorKiali` (1), ...

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-istio/examples/argocd/
oc apply -k .
```

### Applications

## History

| Release  | Date       | Description                                                                                                                  |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.12 | 2026-06-18 | Improve cluster-istio options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.378 | 2026-11-19 | clusterScoped option and RHOAI 3.x overlay; Sail operator values, tracked Chart.lock |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-20 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |
| 21.3.412 | 2026-11-22 | full repository release: internal pins on the previous published version (ADR-0006) |
| 21.3.416 | 2026-11-23 | stable update: chart fixes (project, cluster-mongo, cluster-oadp, cluster-pipeline, cluster-machine, example-catalog); cluster-dvo accepts the grafana keys next to its historical keys, which keep priority |

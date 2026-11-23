# ![cluster-machine](https://helm-repository.readthedocs.io/en/latest/img/cluster-machine.svg "Cluster Chart : Machine") Cluster Chart : Machine
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--machine-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+machine+startx)

This helm chart is used to configure the Machine api of your cluster.

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
helm show chart startx/cluster-machine
```

### 4. Install this chart

```bash
helm install cluster-machine startx/cluster-machine
```

## Default values

Every block of `values.yaml` is disabled (`machineConfigPool`, `machineConfig`, `machineAutoscaler`, `machineHealthCheck`, `machineSet` are all `enabled: false`), so the default values render nothing. `machineSet.list` holds one example item (`a-infra`, type `infra`, 1 replica, instance type `m6i.large`), `cluster.autoscaler.enabled` is `false`.

```bash
# base configuration running default configuration
helm install cluster-machine startx/cluster-machine
```

### AWS spot instances

An AWS `machineSet.list` item accepts `spotMarketOptions` (map or YAML string) rendered in the provider spec. Use an empty map (`spotMarketOptions: {}`) to request spot instances at the on-demand maximum price, or set `maxPrice`. The `machineAutoscaler` is managed independently.

## Values files

Every file is a complete set of values (`machineSet`, `machineAutoscaler`... lists), used with `helm install cluster-machine startx/cluster-machine -f <file>`. `context.cluster` of a file names the machine profile it creates.

- **startx sizes** : `values-startx-<size>.yaml`, one profile per cluster size (see [values-startx-default.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-machine/values-startx-default.yaml)). What each one creates:

  | file | machine sets | autoscaler |
  | ---- | ------------ | ---------- |
  | `values-startx-centi.yaml` | none (context only) | no |
  | `values-startx-centigpu.yaml` | worker-gpu 1 x g6.2xlarge, 1 replica(s); app 8 x g6.2xlarge/g7e.2xlarge/m5.xlarge, 2 replica(s) | no |
  | `values-startx-deca.yaml` | infra 3 x r5a.2xlarge, 3 replica(s); app 3 x c5a.xlarge, 3 replica(s) | no |
  | `values-startx-deci.yaml` | none (context only) | no |
  | `values-startx-default.yaml` | infra 3 x r5a.2xlarge, 3 replica(s); app 9 x t3a.2xlarge/t3a.large/t3a.xlarge, 3 replica(s) | no |
  | `values-startx-giga.yaml` | infra 3 x r5a.2xlarge, 0 replica(s); app 3 x r5a.2xlarge, 3 replica(s); gpu 2 x g4dn.xlarge, 0 replica(s) | no |
  | `values-startx-hecto.yaml` | infra 3 x r5a.2xlarge, 0 replica(s); app 3 x t3a.xlarge, 3 replica(s) | no |
  | `values-startx-kilo.yaml` | infra 3 x r5a.2xlarge, 0 replica(s); storage 3 x r5a.2xlarge, 0 replica(s); app 3 x t3a.2xlarge, 3 replica(s) | no |
  | `values-startx-mega.yaml` | infra 3 x r5a.2xlarge, 3 replica(s); app 9 x t3a.2xlarge/t3a.large/t3a.xlarge, 5 replica(s) | no |
  | `values-startx-metal.yaml` | infra 3 x r5a.2xlarge, 3 replica(s); storage 3 x r5a.2xlarge, 3 replica(s); app 9 x t3a.2xlarge/t3a.large/t3a.xlarge, 5 replica(s); virt 3 x c5.metal, 1 replica(s); gpu 3 x g4dn.xlarge, 0 replica(s) | no |
  | `values-startx-metal2.yaml` | infra 3 x r5a.2xlarge, 3 replica(s); storage 3 x r5a.2xlarge, 3 replica(s); app 9 x t3a.2xlarge/t3a.large/t3a.xlarge, 5 replica(s); virt 3 x c5.metal, 1 replica(s) | no |
  | `values-startx-micro.yaml` | none (context only) | no |
  | `values-startx-milli.yaml` | none (context only) | no |
  | `values-startx-nano.yaml` | none (context only) | no |
  | `values-startx-pico.yaml` | none (context only) | no |
  | `values-startx-snoai.yaml` | worker 1 x g6.8xlarge, 0 replica(s) | no |
  | `values-startx-snobig.yaml` | worker 1 x c5a.12xlarge, 0 replica(s) | no |
  | `values-startx-snobm.yaml` | worker 1 x c5.metal, 0 replica(s) | no |
  | `values-startx-snosmall.yaml` | worker 1 x m6a.4xlarge, 0 replica(s) | no |
  | `values-startx-tera.yaml` | infra 3 x r5a.2xlarge, 0 replica(s) | yes |
  | `values-startx.yaml` | app 3 x m6i.xlarge, 3 replica(s) | no |

- **sxv4** : `values-startx-sxv4-dev.yaml`, `values-startx-sxv4-factory.yaml`, `values-startx-sxv4-full.yaml` : application machine sets with the machine autoscaler enabled
- **startx without infra nodes** : `values-startx_noinfra-*.yaml` (20 files, with `values-startx_noinfra.yaml`); same profile as `values-startx-<size>.yaml`:
  identical file for centi, deci, micro, milli, nano, pico, snoai, snobig;
  same without the infra machine sets for centigpu, deca, default, giga, hecto, mega, snobm, snosmall;
  other content for kilo, metal, metal2 (compare the two files).
- **customer clusters** : `values-mg-*.yaml`, `values-cdf-poc.yaml`, `values-ppmc-s1.yaml`, `values-prgmk-*.yaml`, one cluster each. What each one creates:

  | file | machine sets | autoscaler |
  | ---- | ------------ | ---------- |
  | `values-cdf-poc.yaml` | infra 1 x unspecified type, 2 replica(s) | no |
  | `values-mg-client1.yaml` | infra 3 x m5a.2xlarge, 3 replica(s); app 6 x c5a.xlarge/m5a.2xlarge, 0 replica(s) | no |
  | `values-mg-client2.yaml` | infra 3 x m5a.2xlarge, 3 replica(s); app 6 x c5a.xlarge/m5a.2xlarge, 0 replica(s) | no |
  | `values-mg-mgmt1.yaml` | infra 3 x m5a.2xlarge, 3 replica(s); storage 3 x m5a.2xlarge, 0 replica(s); app 3 x c5a.xlarge, 4 replica(s) | no |
  | `values-mg-pfd.yaml` | infra 3 x m5a.2xlarge, 3 replica(s); worker 12 x m5a.2xlarge/m5a.4xlarge/m5a.xlarge, 10 replica(s) | no |
  | `values-ppmc-s1.yaml` | set 2 x unspecified type, 4 replica(s) | no |
  | `values-prgmk-p1.yaml` | set 1 x unspecified type, 1 replica(s) | no |
  | `values-prgmk-r1.yaml` | set 1 x unspecified type, 1 replica(s) | no |

```bash
helm install cluster-machine startx/cluster-machine -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-machine/values-startx-default.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-machine/examples/argocd/
oc apply -k .
```

### Applications

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.13 | 2026-06-19 | Improve cluster-machine options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.279 | 2026-08-16 | imrpove centigpu profile |
| 21.30.202 | 2026-08-16 | Improve cluster-machine options |
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
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |
| 21.3.412 | 2026-11-22 | full repository release: internal pins on the previous published version (ADR-0006) |
| 21.3.416 | 2026-11-23 | stable update: chart fixes (project, cluster-mongo, cluster-oadp, cluster-pipeline, cluster-machine, example-catalog); cluster-dvo accepts the grafana keys next to graphana, which keeps priority |

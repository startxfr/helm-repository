# ![chaos-kraken](https://helm-repository.readthedocs.io/en/latest/img/chaos-kraken.svg "Chaos Chart : Kraken") Chaos Chart : Kraken
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_chaos--kraken-2B83E2.svg)](https://artifacthub.io/packages/search?ts_query_web=chaos+kraken+startx)

This helm chart used to deploy kraken on Openshift or Kubernetes cluster.
Kraken is as a chaos engine with chaos scenarios for Openshift clusters.

This chart is part of the [chaos startx helm chart series](https://helm-repository.readthedocs.io#chaos-helm-charts) focused on deploying various kind of chaos tools for cluster infrastructure or applications chaos-testing. [chaos-xxx charts](https://helm-repository.readthedocs.io#chaos-helm-charts).

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
helm show chart startx/chaos-kraken
```

### 4. Install this component

```bash
# Install the kraken project
helm install --set project.enabled=true chaos-kraken-project  startx/chaos-kraken
# Deploy the kraken instance
helm install --set kraken.enabled=true -n chaos-kraken chaos-kraken-instance startx/chaos-kraken
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | kraken     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 5.0.0     | Version name of this application (default use Chart appVersion)                   |

### chaos-kraken values dictionary

| Key                            | Default                | Description                                                                                                                                                                                                                                                                       |
| ------------------------------ | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project                        | {...}                  | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/project/#project-values-dictionary) for more options) |
| project.enable                 | false                  | Enable creation of the namespace                                                                                                                                                                                                                                                  |
| kraken                         | {...}                  | Configuration of the kraken deployment                                                                                                                                                                                                                                            |
| kraken.enable                  | false                  | Unleash the kraken ;)                                                                                                                                                                                                                                                             |
| kraken.expose                  | true                   | Enable exposition for this application (route based)                                                                                                                                                                                                                              |
| kraken.cerberusUrl             | url                    | Fill the cerberus server url. (prefer internal)                                                                                                                                                                                                                                   |
| kraken.mode                    | pipeline               | Kraken mode (could be job or pipeline)                                                                                                                                                                                                                                            |
| kraken.job                     | {...}                  | configuration of the job mode                                                                                                                                                                                                                                                     |
| kraken.job.prefix              | kraken-test            | Job name prefix                                                                                                                                                                                                                                                                   |
| kraken.pipeline                | {...}                  | configuration of the pipeline mode                                                                                                                                                                                                                                                |
| kraken.pipeline.prefix         | kraken-test            | pipelinerun name prefix                                                                                                                                                                                                                                                           |
| kraken.aws                     | {...}                  | AWS configuration section (must have privileged accesss to Openshift deployed resources like VPC, subnet, EC2 instance)                                                                                                                                                            |
| kraken.aws.enabled             | false                  | enable the aws integration                                                                                                                                                                                                                                                        |
| kraken.aws.credentials         | {...}                  | credentials (mandatory if enabled)                                                                                                                                                                                                                                                |
| kraken.aws.credentials.region  | eu-west-3              | used AWS region                                                                                                                                                                                                                                                                   |
| kraken.aws.credentials.key_id  | AKIAXXX...             | AWS accesss key ID                                                                                                                                                                                                                                                                 |
| kraken.aws.credentials.secret  | "xxxxxxxxxx"           | AWS secret accesss key                                                                                                                                                                                                                                                             |
| kraken.kubeconfig              | {...}                  | Kubeconfig of the supervised tested cluster (mandatory)                                                                                                                                                                                                                           |
| kraken.kubeconfig.mode         | token                  | Connection mode to use for the cluster (could be token or file)                                                                                                                                                                                                                   |
| kraken.kubeconfig.token        | {...}                  | If mode is token, this section must be filled                                                                                                                                                                                                                                     |
| kraken.kubeconfig.token.server | https://localhost:6443 | The server URL to the target cluster API                                                                                                                                                                                                                                          |
| kraken.kubeconfig.token.token  | sha256~XXX             | The token to use to get accesss. This token must have full cluster admin accesss to perform some chaos scenarios                                                                                                                                                                    |
| kraken.kubeconfig.file         | ""                     | If mode is token, this property must be set with a full kubeconfig content                                                                                                                                                                                                        |

## Values files

### Default values file (values.yaml)

Simple kraken with default configuration :

- 1 **project** named **chaos-kraken**
- 1 **scc** with privileged context for **kraken** deployment
- 1 **configmap** with kraken 21 generic scenarios, various scripts and configuration
- 1 **configmap** with kubeconfig of the targeted cluster
- 12 **pipeline** named **kraken-test-xxx**
- 1 **service** to the **kraken** pods
- 1 **route** to the **kraken** service

```bash
# Running the default configuration
helm install --set project.enable=true chaos-kraken-project startx/chaos-kraken
helm install --set kraken.enable=true chaos-kraken-instance startx/chaos-kraken
```

### STARTX values file (values-startx-xxx.yaml)

Same as the default configuration but with namespace prefixed with startx-

```bash
# Configuration running demo example configuration
helm install chaos-kraken-project startx/chaos-kraken -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-kraken/values-startx-project.yaml
helm install chaos-kraken-deploy startx/chaos-kraken -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-kraken/values-startx-deploy.yaml
```

## Usage examples

### Run kraken in job mode (one-shot chaos run)

Deploy kraken as a Kubernetes Job that runs a node failure scenario once:

```yaml
# my-kraken-job-values.yaml
context:
  scope: myorg
  cluster: prod-cluster
  environment: prod
  component: chaos
  app: kraken-prod

kraken:
  enabled: true
  expose: false
  cerberusUrl: http://cerberus.chaos-cerberus.svc.cluster.local:8080
  mode: job
  job:
    prefix: kraken-node-failure
  kubeconfig:
    mode: token
    token:
      server: https://api.prod-cluster.example.com:6443
      token: sha256~REPLACE_WITH_YOUR_TOKEN
```

```bash
helm install chaos-kraken-job startx/chaos-kraken -f my-kraken-job-values.yaml -n chaos-kraken
```

### Run kraken in pipeline mode (Tekton)

Deploy kraken using a Tekton PipelineRun for each scenario (requires OpenShift Pipelines):

```yaml
# my-kraken-pipeline-values.yaml
kraken:
  enabled: true
  cerberusUrl: http://cerberus.chaos-cerberus.svc.cluster.local:8080
  mode: pipeline
  pipeline:
    prefix: kraken-test
  kubeconfig:
    mode: token
    token:
      server: https://api.prod-cluster.example.com:6443
      token: sha256~REPLACE_WITH_YOUR_TOKEN
```

```bash
helm install chaos-kraken-pipeline startx/chaos-kraken -f my-kraken-pipeline-values.yaml -n chaos-kraken
```

### Run kraken with AWS integration (node stop/start)

Enable AWS credentials to allow kraken to stop/start EC2 instances during node failure scenarios:

```yaml
# my-kraken-aws-values.yaml
kraken:
  enabled: true
  mode: job
  aws:
    enabled: true
    credentials:
      region: eu-west-3
      key_id: AKIAXXX_REPLACE_WITH_REAL_KEY
      secret: "REPLACE_WITH_REAL_SECRET"
  kubeconfig:
    mode: token
    token:
      server: https://api.prod-cluster.example.com:6443
      token: sha256~REPLACE_WITH_YOUR_TOKEN
```

```bash
helm install chaos-kraken-aws startx/chaos-kraken -f my-kraken-aws-values.yaml -n chaos-kraken
```

## History

| Release  | Date       | Description                                                                                                                      |
| -------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.15 | 2026-03-02 | Prepare upgrading dependency to 19.23.11 |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.7 | 2026-03-02 | Update dependencies to version 20.14.0 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.1 | 2026-03-02 | Prepare release 21.3.x with 21.x dependencies |
| 21.3.3 | 2026-03-02 | Upgrade dependencies to v21.3.0 |
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |

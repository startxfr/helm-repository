# Chaos - Kraken

This helm chart used to deploy kraken on Openshift or Kubernetes cluster. 
Kraken is as a chaos engine with chaos scenarios for Openshift clusters. 

This chart is part of the [chaos startx helm chart series](https://helm-repository.readthedocs.io#chaos-helm-charts) focused on deploying various kind of chaos tools for cluster infrastructure or applications chaos-testing. [chaos-xxx charts](https://helm-repository.readthedocs.io#chaos-helm-charts).

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
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
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)                   |
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | sxapi     | Application name (functionnal tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

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
| kraken.aws                     | {...}                  | AWS configuration section (must have privileged access to Openshift deployed resources like VPC, subnet, EC2 instance)                                                                                                                                                            |
| kraken.aws.enabled             | false                  | enable the aws integration                                                                                                                                                                                                                                                        |
| kraken.aws.credentials         | {...}                  | credentials (mandatory if enabled)                                                                                                                                                                                                                                                |
| kraken.aws.credentials.region  | eu-west-3              | used AWS region                                                                                                                                                                                                                                                                   |
| kraken.aws.credentials.key_id  | AKIAXXX...             | AWS access key ID                                                                                                                                                                                                                                                                 |
| kraken.aws.credentials.secret  | "xxxxxxxxxx"           | AWS secret access key                                                                                                                                                                                                                                                             |
| kraken.kubeconfig              | {...}                  | Kubeconfig of the supervised tested cluster (mandatory)                                                                                                                                                                                                                           |
| kraken.kubeconfig.mode         | token                  | Connection mode to use for the cluster (could be token or file)                                                                                                                                                                                                                   |
| kraken.kubeconfig.token        | {...}                  | If mode is token, this section must be filled                                                                                                                                                                                                                                     |
| kraken.kubeconfig.token.server | https://localhost:6443 | The server URL to the target cluster API                                                                                                                                                                                                                                          |
| kraken.kubeconfig.token.token  | sha256~XXX             | The token to use to get access. This token must have full cluster admin access to perform some chaos scenarios                                                                                                                                                                    |
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

## History

| Release  | Date       | Description                                                                                                                      |
| -------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 10.12.5  | 2022-06-03 | Initial commit of the example and poc chart example-chaos                                                                        |
| 10.12.8  | 2022-06-11 | Initial commit for this helm chart as part of the chaos suite                                                                    |
| 10.12.26 | 2022-06-17 | Create the chaos-kraken chart as part of the startx chaos chart suite                                                            |
| 10.12.28 | 2022-06-17 | Upgrade the chaos-kraken helm chart schema with full option support. Link to upstream project release latest (no stable release) |
| 10.12.29 | 2022-06-17 | Align all charts to version 10.12.29                                                                                             |
| 10.12.29 | 2022-06-17 | publish stable update for the full repository                                                                                    |
| 10.12.30 | 2022-06-17 | Improved logo and global documentation                                                                                           |
| 10.12.33 | 2022-06-17 | publish stable update for the full repository                                                                                    |
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31                                                                                        |
| 10.12.35 | 2022-06-18 | Improve icon                                                                                                                     |
| 10.12.39 | 2022-06-18 | Align all chart to revision 10.12.39                                                                                             |
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41                                                                                             |
| 10.12.42 | 2022-06-18 | Improve schema default values, notes and polish helm deployment documentation                                                    |
| 10.12.43 | 2022-06-18 | Improve doc for helm deployment                                                                                                  |
| 10.12.46 | 2022-06-18 | publish stable update for the full repository                                                                                    |
| 10.12.47 | 2022-06-18 | Minor improvment in doc and sample values                                                                                        |
| 10.12.49 | 2022-06-18 | publish stable update for the full repository                                                                                    |
| 10.12.53 | 2022-06-18 | publish stable update for the full repository                                                                                    |
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts                                                                                               |
| 10.12.72 | 2022-07-02 | Common release                                                                                                                   |
| 10.12.77 | 2022-07-02 | Stable for clients                                                                                                               |
| 10.12.81 | 2022-07-02 | publish stable update for the full repository                                                                                    |
| 10.12.97 | 2022-07-03 | publish stable update for the full repository                                                                                    |
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart                                                                                         |
| 11.5.3   | 2022-09-17 | Align all STARTX charts to release 11.5.3                                                                                        |
| 11.7.1   | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release                                                                 |
| 11.7.3   | 2022-10-02 | publish stable update for the full repository                                                                                    |
| 11.7.9   | 2022-10-02 | publish stable update for the full repository                                                                                    |
| 11.7.10 | 2022-10-02 | Stable release for all packages
| 11.7.11 | 2022-10-02 | publish stable update for the full repository
| 11.7.15 | 2022-10-02 | publish stable update for the full repository
| 11.7.17 | 2022-10-02 | publish stable update for the full repository
| 11.7.31 | 2022-10-29 | publish stable update for the full repository
| 11.7.33 | 2022-10-29 | Update all startx packages to release 11.7.33
| 11.7.41 | 2022-11-02 | publish stable update for the full repository
| 11.7.61 | 2022-11-30 | publish stable update for the full repository
| 11.7.62 | 2022-11-30 | Debug console links and notifications
| 11.7.63 | 2022-11-30 | publish stable update for the full repository
| 11.7.64 | 2022-11-30 | Increment sxapi version
| 11.7.67 | 2022-11-30 | Debug depedencies on sub charts
| 11.7.69 | 2022-11-30 | Finished dependencies stabilization

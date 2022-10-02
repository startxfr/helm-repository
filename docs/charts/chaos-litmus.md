# Chaos - Litmus

This helm chart used to deploy litmus on Openshift or Kubernetes cluster. 
Litmus is as a watchdog who act as a global cluster healthcheck. 

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
helm show chart startx/chaos-litmus
```

### 4. Install this component

```bash
# Install the litmus project
helm install --set project.enabled=true chaos-litmus-project  startx/chaos-litmus
# Deploy the litmus instance
helm install --set litmus.enabled=true -n chaos-litmus chaos-litmus-instance startx/chaos-litmus
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

### chaos-litmus values dictionary

| Key            | Default | Description                                                                                                                                                                                                                                                                       |
| -------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project        | {...}   | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/project/#project-values-dictionary) for more options) |
| project.enable | false   | Enable creation of the namespace                                                                                                                                                                                                                                                  |
| litmus         | {...}   | Configuration of the litmus deployment. Inherit from the [official litmus chart](https://litmuschaos.github.io/litmus-helm) (see [chart options](https://litmuschaos.github.io/litmus-helm) for more options)                                                                     |
| litmus.enable  | false   | Enable deploying the litmus watchdog                                                                                                                                                                                                                                              |

## Values files

### Default values file (values.yaml)

Simple litmus with default configuration :

- 1 **project** named **chaos-litmus**
- 1 **scc** with privileged context for 9 **litmus** serviceaccount
- 1 **litmus** deployment using official helm chart
- 1 **route** to the **litmus** service

```bash
# Running the default configuration
helm install --set project.enable=true chaos-litmus-project startx/chaos-litmus
helm install --set litmus.enable=true chaos-litmus-instance startx/chaos-litmus
```

### STARTX values file (values-startx-xxx.yaml)

Same as the default configuration but with namespace prefixed with startx-

```bash
# Configuration running demo example configuration
helm install chaos-litmus-project startx/chaos-litmus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-litmus/values-startx-project.yaml
helm install chaos-litmus-deploy startx/chaos-litmus -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-litmus/values-startx-deploy.yaml
```

## History

| Release  | Date       | Description                                                                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 10.12.5  | 2022-06-03 | Initial commit of the example and poc chart example-chaos                                                                                              |
| 10.12.8  | 2022-06-11 | Initial commit for this helm chart as part of the chaos suite                                                                                          |
| 10.12.26 | 2022-06-17 | Create the chaos-litmus chart as part of the startx chaos chart suite                                                                                  |
| 10.12.28 | 2022-06-17 | Upgrade the chaos-litmus helm chart schema with limited support for litmus external chart (no external schema). Link to upstream project release 2.9.0 |
| 10.12.29 | 2022-06-17 | Align all charts to version 10.12.29                                                                                                                   |
| 10.12.29 | 2022-06-17 | publish stable update for the full repository                                                                                                          |
| 10.12.30 | 2022-06-17 | Improved logo and global documentation                                                                                                                 |
| 10.12.33 | 2022-06-17 | publish stable update for the full repository                                                                                                          |
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31                                                                                                              |
| 10.12.35 | 2022-06-18 | Improve icon                                                                                                                                           |
| 10.12.39 | 2022-06-18 | Align all chart to revision 10.12.39                                                                                                                   |
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41                                                                                                                   |
| 10.12.42 | 2022-06-18 | Improve schema default values, notes and polish helm deployment documentation
| 10.12.43 | 2022-06-18 | Improve doc for helm deployment
| 10.12.46 | 2022-06-18 | publish stable update for the full repository
| 10.12.47 | 2022-06-18 | Minor improvment in doc and sample values
| 10.12.49 | 2022-06-18 | publish stable update for the full repository
| 10.12.53 | 2022-06-18 | publish stable update for the full repository
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts
| 10.12.72 | 2022-07-02 | Common release
| 10.12.77 | 2022-07-02 | Stable for clients
| 10.12.81 | 2022-07-02 | publish stable update for the full repository
| 10.12.97 | 2022-07-03 | publish stable update for the full repository
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart
| 11.5.3 | 2022-09-17 | Align all STARTX charts to release 11.5.3
| 11.7.1 | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release
| 11.7.3 | 2022-10-02 | publish stable update for the full repository
| 11.7.9 | 2022-10-02 | publish stable update for the full repository

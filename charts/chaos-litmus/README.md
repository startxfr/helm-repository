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
| 10.12.42 | 2022-06-18 | Improve schema default values, notes and polish helm deployment documentation                                                                          |
| 10.12.43 | 2022-06-18 | Improve doc for helm deployment                                                                                                                        |
| 10.12.46 | 2022-06-18 | publish stable update for the full repository                                                                                                          |
| 10.12.47 | 2022-06-18 | Minor improvment in doc and sample values                                                                                                              |
| 10.12.49 | 2022-06-18 | publish stable update for the full repository                                                                                                          |
| 10.12.53 | 2022-06-18 | publish stable update for the full repository                                                                                                          |
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts                                                                                                                     |
| 10.12.72 | 2022-07-02 | Common release                                                                                                                                         |
| 10.12.77 | 2022-07-02 | Stable for clients                                                                                                                                     |
| 10.12.81 | 2022-07-02 | publish stable update for the full repository                                                                                                          |
| 10.12.97 | 2022-07-03 | publish stable update for the full repository                                                                                                          |
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart                                                                                                               |
| 11.5.3   | 2022-09-17 | Align all STARTX charts to release 11.5.3                                                                                                              |
| 11.7.1   | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release                                                                                       |
| 11.7.3   | 2022-10-02 | publish stable update for the full repository                                                                                                          |
| 11.7.9   | 2022-10-02 | publish stable update for the full repository                                                                                                          |
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
| 11.7.67 | 2022-11-30 | Debug depedencies on sub charts
| 11.7.69 | 2022-11-30 | Finished dependencies stabilization
| 11.7.73 | 2022-12-04 | Align all packages to release 11.7.73
| 11.7.75 | 2022-12-04 | publish stable update for the full repository
| 11.7.77 | 2022-12-05 | publish stable update for the full repository
| 11.7.87 | 2023-02-15 | publish stable update for the full repository
| 11.7.88 | 2023-02-15 | publish stable update for the full repository
| 11.7.91 | 2023-02-16 | publish stable update for the full repository
| 11.7.93 | 2023-02-16 | align dependencies to version 11.7.89
| 11.7.97 | 2023-02-19 | publish stable update for the full repository
| 11.28.11 | 2023-02-19 | publish stable update for the full repository
| 11.28.15 | 2023-02-19 | publish stable update for the full repository
| 11.28.16 | 2023-02-19 | publish stable update for the full repository
| 11.28.19 | 2023-02-19 | publish stable update for the full repository
| 11.28.21 | 2023-02-19 | Upgrade all dependencies packages to release 11.28.15
| 11.28.23 | 2023-02-21 | publish stable update for the full repository
| 11.28.25 | 2023-02-21 | Debug route NS scope placement
| 11.28.27 | 2023-02-21 | All chart aligned to release 11.28.27
| 11.28.29 | 2023-02-21 | publish stable update for the full repository
| 11.28.35 | 2023-02-21 | publish stable update for the full repository
| 11.28.39 | 2023-02-21 | Improve chaos-litmus options
| 11.28.39 | 2023-02-21 | Improve chaos-litmus options
| 11.28.40 | 2023-02-21 | Improve chaos-litmus options
| 11.28.41 | 2023-02-21 | Improve chaos-litmus options
| 11.28.49 | 2023-02-21 | publish stable update for the full repository
| 11.28.59 | 2023-02-21 | publish stable update for the full repository
| 11.28.60 | 2023-02-21 | publish stable update for the full repository
| 11.28.67 | 2023-02-23 | publish stable update for the full repository
| 11.28.69 | 2023-03-07 | publish stable update for the full repository
| 11.28.89 | 2023-04-01 | publish stable update for the full repository
| 11.28.93 | 2023-04-20 | publish stable update for the full repository
| 11.28.95 | 2023-04-21 | publish stable update for the full repository
| 11.28.99 | 2023-04-21 | publish stable update for the full repository
| 11.28.103 | 2023-05-04 | publish stable update for the full repository
| 11.28.127 | 2023-06-12 | publish stable update for the full repository
| 11.28.128 | 2023-06-12 | publish stable update for the full repository
| 11.28.129 | 2023-06-13 | publish stable update for the full repository
| 11.28.201 | 2023-07-06 | publish stable update for the full repository
| 11.28.207 | 2023-07-06 | publish stable update for the full repository
| 11.28.230 | 2023-08-18 | Align all helm chart to release 11.28.230 stable release
| 11.30.0 | 2023-08-18 | Align all helm chart to release 11.30.0 stable for OCP 4.11.30
| 11.40.0 | 2023-08-18 | Align all helm chart to release 11.40.0 stable for OCP 4.11.40
| 11.47.0 | 2023-08-18 | Align all helm chart to release 11.47.0 stable for OCP 4.11.47
| 11.47.1 | 2023-08-18 | Update appVersion in Chart.yml
| 11.47.1 | 2023-08-18 | Update appVersion in Chart.yml
| 12.0.0 | 2023-08-18 | Align all helm chart to release 12.0.0 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.1 | 2023-08-18 | Align all helm chart to release 12.0.1 transitionnal for OCP 4.12.0 target (unstable)
| 12.0.3 | 2023-08-18 | Update all chart dependencies to 12.0.0 release (unstable)
| 12.0.5 | 2023-08-18 | publish stable update for the full repository
| 12.0.11 | 2023-08-18 | publish stable update for the full repository
| 12.30.1 | 2023-09-29 | release 12.30.1 aligned and tested with OCP 4.12.30
| 12.36.1 | 2023-09-29 | release 12.36.0 aligned with OCP 4.12.36 (unstable)
| 12.36.9 | 2023-10-01 | publish stable update for the full repository
| 12.36.36 | 2023-10-11 | publish stable update for the full repository
| 12.36.49 | 2023-11-13 | publish stable update for the full repository

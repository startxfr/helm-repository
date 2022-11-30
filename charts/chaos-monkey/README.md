# Chaos - Kube-monkey

This helm chart used to deploy kube-monkey on Openshift or Kubernetes cluster. 
Monkey is as a watchdog who act as a global cluster healthcheck. 

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
helm show chart startx/chaos-monkey
```

### 4. Install this component

```bash
# Install the monkey project
helm install --set project.enabled=true chaos-monkey-project  startx/chaos-monkey
# Deploy the monkey instance
helm install --set monkey.enabled=true  chaos-monkey-instance startx/chaos-monkey
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

### chaos-monkey values dictionary

| Key            | Default | Description                                                                                                                                                                                                                                                                       |
| -------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project        | {...}   | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/project/#project-values-dictionary) for more options) |
| project.enable | false   | Enable creation of the namespace                                                                                                                                                                                                                                                  |
| monkey         | {...}   | Configuration of the kube-monkey deployment. Inherit from the [asobti kube-monkey chart](https://asobti.github.io/kube-monkey/charts/repo) (see [chart options](https://asobti.github.io/kube-monkey/charts/repo) for more options)                                               |
| monkey.enable  | false   | Enable deploying the kube-monkey watchdog                                                                                                                                                                                                                                         |

## Values files

### Default values file (values.yaml)

Simple monkey with default configuration :

- 1 **project** named **chaos-monkey**
- 1 **scc** with privileged context for **monkey** deployment
- 1 **kube-monkey** deployment using asobti helm chart

```bash
# Install the kube-monkey project
helm install --set project.enable=true chaos-monkey-project startx/chaos-monkey
# Deploy the kube-monkey instance
helm install --set monkey.enable=true -n chaos-monkey chaos-monkey-instance startx/chaos-monkey
```

### STARTX values file (values-startx-xxx.yaml)

Same as the default configuration but with namespace prefixed with startx-

```bash
# Configuration running demo example configuration
helm install chaos-monkey-project startx/chaos-monkey -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-monkey/values-startx-project.yaml
helm install chaos-monkey-deploy startx/chaos-monkey -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/chaos-monkey/values-startx-deploy.yaml
```

## History

| Release  | Date       | Description                                                                                                                                                 |
| -------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 10.12.5  | 2022-06-03 | Initial commit of the example and poc chart example-chaos                                                                                                   |
| 10.12.8  | 2022-06-11 | Initial commit for this helm chart as part of the chaos suite                                                                                               |
| 10.12.26 | 2022-06-17 | Create the chaos-monkey chart as part of the startx chaos chart suite                                                                                       |
| 10.12.28 | 2022-06-17 | Upgrade the chaos-monkey helm chart schema with limited support for kube-monkey external chart (no external schema). Link to upstream project release 1.4.1 |
| 10.12.29 | 2022-06-17 | Align all charts to version 10.12.29                                                                                                                        |
| 10.12.29 | 2022-06-17 | publish stable update for the full repository                                                                                                               |
| 10.12.30 | 2022-06-17 | Improved logo and global documentation                                                                                                                      |
| 10.12.33 | 2022-06-17 | publish stable update for the full repository                                                                                                               |
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31                                                                                                                   |
| 10.12.35 | 2022-06-18 | Improve icon                                                                                                                                                |
| 10.12.39 | 2022-06-18 | Align all chart to revision 10.12.39                                                                                                                        |
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41                                                                                                                        |
| 10.12.42 | 2022-06-18 | Improve schema default values, notes and polish helm deployment documentation                                                                               |
| 10.12.43 | 2022-06-18 | Improve doc for helm deployment                                                                                                                             |
| 10.12.46 | 2022-06-18 | publish stable update for the full repository                                                                                                               |
| 10.12.47 | 2022-06-18 | Minor improvment in doc and sample values                                                                                                                   |
| 10.12.49 | 2022-06-18 | publish stable update for the full repository                                                                                                               |
| 10.12.53 | 2022-06-18 | publish stable update for the full repository                                                                                                               |
| 10.12.71 | 2022-06-28 | Debug the appVersion in all charts                                                                                                                          |
| 10.12.72 | 2022-07-02 | Common release                                                                                                                                              |
| 10.12.77 | 2022-07-02 | Stable for clients                                                                                                                                          |
| 10.12.81 | 2022-07-02 | publish stable update for the full repository                                                                                                               |
| 10.12.97 | 2022-07-03 | publish stable update for the full repository                                                                                                               |
| 10.12.99 | 2022-09-16 | Initialize OCP 4.11 upgrade on all chart                                                                                                                    |
| 11.5.3   | 2022-09-17 | Align all STARTX charts to release 11.5.3                                                                                                                   |
| 11.7.1   | 2022-10-01 | Upgrade chart to latest release available for OCP 4.11.7 release                                                                                            |
| 11.7.3   | 2022-10-02 | publish stable update for the full repository                                                                                                               |
| 11.7.9   | 2022-10-02 | publish stable update for the full repository                                                                                                               |
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

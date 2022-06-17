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
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### 3. Get information about this chart

```bash
helm show chart startx/chaos-litmus
```

### 4. Install this chart

```bash
helm install startx/chaos-litmus
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

| Key                              | Default                | Description                                                                                                                                                                                                                                                                       |
| -------------------------------- | ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| project                          | {...}                  | Configuration of the project (or namespace). Inherit from the [project chart](https://helm-repository.readthedocs.io/en/latest/charts/project) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/project/#project-values-dictionary) for more options) |
| project.enable                   | false                  | Enable creation of the namespace                                                                                                                                                                                                                                                  |
| litmus                          | {...}                  | Configuration of the litmus deployment. Inherit from the [official litmus chart](https://litmuschaos.github.io/litmus-helm) (see [chart options](https://litmuschaos.github.io/litmus-helm) for more options) |
| litmus.enable                  | false                  | Enable deploying the litmus watchdog                                                                                                                                                                                                                                            |

## Values files

### Default values file (values.yaml)

Simple litmus with default configuration :

- 1 **project** named **chaos-litmus**
- 1 **scc** with privilegied context for 9 **litmus** serviceaccount
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

| Release | Date       | Description                                                   |
| ------- | ---------- | ------------------------------------------------------------- |
| 10.12.5 | 2022-06-03 | Initial commit of the example and poc chart example-chaos     |
| 10.12.8 | 2022-06-11 | Initial commit for this helm chart as part of the chaos suite |
| 10.12.26 | 2022-06-17 | Create the chaos-litmus chart as part of the startx chaos chart suite

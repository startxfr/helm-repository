# Chaos

This helm chart is used to deploy a chaos test suite composed of cerberus, kraken, litmus, chaos mesh and kube-monkey.

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
helm show chart startx/chaos
```

### 4. Install this chart

```bash
helm install chaos startx/chaos
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                                                                                                                                                                                                                                               |
| ------------------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)                                                                                                                                                                                                                                     |
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)                                                                                                                                                                                                                                           |
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod)                                                                                                                                                                                                                         |
| context.component   | demo      | Component name of this application (logical tenant)                                                                                                                                                                                                                                                       |
| context.app         | sxapi     | Application name (functionnal tenant, default use Chart name)                                                                                                                                                                                                                                             |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                                                                                                                                                                                                                                           |
| cerberus            | {...}     | Configuration of the cerberus component. Inherit from the [chaos-cerberus chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-cerberus) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-cerberus/#chaos-cerberus-values-dictionary) for more options) |
| kraken              | {...}     | Configuration of the kraken component. Inherit from the [chaos-kraken chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-kraken) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-kraken/#chaos-kraken-values-dictionary) for more options)           |
| litmus              | {...}     | Configuration of the litmus component. Inherit from the [chaos-litmus chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-litmus) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-litmus/#chaos-litmus-values-dictionary) for more options)           |
| mesh                | {...}     | Configuration of the chaos-mesh component. Inherit from the [chaos-mesh chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-mesh) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-mesh/#chaos-mesh-values-dictionary) for more options)               |
| monkey              | {...}     | Configuration of the kube-monkey component. Inherit from the [chaos-monkey chart](https://helm-repository.readthedocs.io/en/latest/charts/chaos-monkey) (see [chart options](https://helm-repository.readthedocs.io/en/latest/charts/chaos-monkey/#chaos-monkey-values-dictionary) for more options)      |

## Values files

### Default values file (values.yaml)

#### Deploy chaos namespaces

Deploy the chaos test suite environment :

- 1 **project** named **chaos-cerberus**
- 1 **project** named **chaos-kraken**
- 1 **project** named **chaos-litmus**
- 1 **project** named **chaos-mesh**
- 1 **project** named **chaos-monkey**

```bash
helm install \
 --set cerberus.enable=true --set cerberus.project.enable=true \
 --set kraken.enable=true   --set kraken.project.enable=true \
 --set litmus.enable=true   --set litmus.project.enable=true \
 --set mesh.enable=true     --set mesh.project.enable=true \
 --set monkey.enable=true   --set monkey.project.enable=true \
 chaos startx/chaos
```

#### Deploy cerberus

Deploy the cerberus component

```bash
helm install \
--set cerberus.enable=true --set cerberus.cerberus.enable=true \
chaos-cerberus startx/chaos-cerberus
```

#### Deploy kraken

Deploy the kraken component

```bash
helm install \
--set kraken.enable=true --set kraken.kraken.enable=true \
chaos-kraken startx/chaos-kraken
```

#### Deploy litmus

Deploy the litmus component

```bash
helm install \
--set litmus.enable=true --set litmus.litmus.enable=true \
chaos-litmus startx/chaos-litmus
```

#### Deploy Chaos-mesh

Deploy the chaos-mesh component

```bash
helm install \
--set mesh.enable=true --set mesh.mesh.enable=true \
chaos-mesh startx/chaos-mesh
```

#### Deploy Kube-monkey

Deploy the kube-monkey component

```bash
helm install \
--set monkey.enable=true --set monkey.monkey.enable=true \
chaos-monkey startx/chaos-monkey
```

## History

| Release  | Date       | Description                                                                                                                        |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| 10.12.5  | 2022-06-03 | Initial commit of the example and poc chart example-chaos                                                                          |
| 10.12.8  | 2022-06-11 | Initial commit for this helm chart as part of the chaos suite                                                                      |
| 10.12.26 | 2022-06-17 | Create the chaos-mesh chart as part of the startx chaos chart suite                                                                |
| 10.12.28 | 2022-06-17 | Upgrade the chaos-cerberus helm chart schema with full option support. Link to upstream project release latest (no stable release) |
| 10.12.29 | 2022-06-17 | Align all charts to version 10.12.29                                                                                               |
| 10.12.29 | 2022-06-17 | publish stable update for the full repository                                                                                      |
| 10.12.30 | 2022-06-17 | Improved logo and global documentation                                                                                             |
| 10.12.33 | 2022-06-17 | version all dependencies charts                                                                                                    |
| 10.12.33 | 2022-06-17 | publish stable update for the full repository                                                                                      |
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31                                                                                          |
| 10.12.35 | 2022-06-18 | Improve icon                                                                                                                       |
| 10.12.39 | 2022-06-18 | Align all chart to revision 10.12.39
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41
| 10.12.42 | 2022-06-18 | Improve schema default values, notes and polish helm deployment documentation

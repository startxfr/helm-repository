# ![example-fruitapp-shared](https://helm-repository.readthedocs.io/en/latest/img/example-fruitapp-shared.svg "Example Chart : Fruitapp shared") Example Chart : Fruitapp - shared
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_example--fruitapp--shared-E28A2B.svg)](https://artifacthub.io/packages/search?ts_query_web=example+fruitapp+startx)

This helm chart is used to deploy all shared components required for a particular environment.

This chart is part of the [example-fruitapp-xxx startx helm chart series](https://helm-repository.readthedocs.io#examples-helm-charts) focused on deploying various kind of application consuming the cluster services deployed using the [cluster-xxx charts](https://helm-repository.readthedocs.io#cluster-helm-charts).

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
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable/
```

### 3. Get information about this chart

```bash
helm show chart startx/example-fruitapp-shared
```

### 4. Install this chart

```bash
helm install example-fruitapp-shared startx/example-fruitapp-shared
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | fruitapp     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### example-fruitapp-shared values dictionary

| Key                         | Default                   | Description                                                                                        |
| --------------------------- | ------------------------- | -------------------------------------------------------------------------------------------------- |
| namespace                   | fruitapp-preprod          | Project used fot theses resources                                                                  |
| database                    | {}                        | Configuration of the database components                                                           |
| database.enabled            | true                      | Enable database for this project                                                                   |
| database.name               | fruitapp                  | Database name used                                                                                 |
| database.user               | fruitapp-preprod          | Database username                                                                                  |
| database.password           | fruitapp-preprod-password | Database password associated to the user                                                           |
| database.storage_capacitity | 1Gi                       | Database storage quantity                                                                          |
| database.storage_class      | gp3-csi                       | Database storage quality                                                                           |
| database.memory_limit       | 256Mi                     | Database memory limit                                                                              |
| database.version            | latest                    | The postgressql version (should be one of latest, 10-el7, 10-el8, 9.6-el8, 13-el8, 12-el8, 12-el7) |

## Values files

### Default values file (values.yaml)

Deploy all shared services for a given namespace with the following characteristics :

- 1 **pvc** named **postgresql-preprod** with
  - **gp3-csi** storage class
  - **1Gi** allocation
- 1 **secret** named **db** with all databse credentials
- 1 **service** named **db** routing internal calls to pods
- 1 **deployment** named **db** with
  - port **5432** exposed
  - path **/var/lib/pgsql/data** mounted with volume **postgresql-preprod**

```bash
# base configuration running default configuration
helm install example-fruitapp-shared startx/example-fruitapp-shared
```

## History

| Release  | Date       | Description                                                      |
| -------- | ---------- | ---------------------------------------------------------------- |
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
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |
| 21.3.167 | 2026-06-23 | publish stable update for the full repository |
| 21.3.181 | 2026-06-23 | publish stable update for the full repository |
| 21.3.182 | 2026-06-23 | publish stable update for the full repository |

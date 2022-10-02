# Example Fruitapp -shared

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
helm repo add startx https://helm-repository.readthedocs.io/en/latest/packages/
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
| context.cluster     | localhost | Name of the cluster running this application (plateform tenant)                   |
| context.environment | dev       | Name of the environement for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | sxapi     | Application name (functionnal tenant, default use Chart name)                     |
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
| database.storage_class      | gp2                       | Database storage quality                                                                           |
| database.memory_limit       | 256Mi                     | Database memory limit                                                                              |
| database.version            | latest                    | The postgressql version (should be one of latest, 10-el7, 10-el8, 9.6-el8, 13-el8, 12-el8, 12-el7) |

## Values files

### Default values file (values.yaml)

Deploy all shared services for a given namespace with the following characteristics :

- 1 **pvc** named **postgresql-preprod** with
  - **gp2** storage class
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

| Release | Date       | Description                                                   |
| ------- | ---------- | ------------------------------------------------------------- |
| 9.8.239 | 2022-05-28 | Initial commit for this helm chart with default value example |
| 9.8.240 | 2022-05-29 | Improve the schema                                            |
| 9.8.253 | 2022-05-29 | Align all charts dependencies to release 9.8.251
| 9.8.277 | 2022-05-31 | publish stable update for the full repository
| 9.15.1 | 2022-06-01 | Align all chart for Openshift 4.9.15
| 9.15.2 | 2022-06-01 | Align all charts to release 9.15.1
| 9.15.3 | 2022-06-01 | Align all charts to release 9.15.3
| 10.12.1 | 2022-06-01 | Align all charts to release 10.12.1
| 10.12.3 | 2022-06-01 | publish stable update for the full repository
| 10.12.4 | 2022-06-01 | Align all charts to release 10.12.4
| 10.12.5 | 2022-06-01 | publish stable update for the full repository
| 10.12.22 | 2022-06-04 | Align all chart to release version 10.12.22
| 10.12.23 | 2022-06-04 | Basi chart dependencies upgraded to version 10.12.5
| 10.12.29 | 2022-06-17 | publish stable update for the full repository
| 10.12.30 | 2022-06-17 | Improved logo and global documentation
| 10.12.33 | 2022-06-17 | publish stable update for the full repository
| 10.12.34 | 2022-06-17 | Align all dependencies charts to 10.12.31
| 10.12.41 | 2022-06-18 | Align all charts to version 10.12.41
| 10.12.46 | 2022-06-18 | publish stable update for the full repository
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

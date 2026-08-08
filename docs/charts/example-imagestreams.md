# ![example-imagestreams](https://helm-repository.readthedocs.io/en/latest/img/example-imagestreams.svg "Example Chart : ImageStreams") Example Chart : ImageStreams
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_example--imagestreams-E28A2B.svg)](https://artifacthub.io/packages/search?ts_query_web=example+imagestreams+startx)

This helm chart is used to used to load imagestreams into a given namespace.

This chart is part of the [example-xxx startx helm chart series](https://helm-repository.readthedocs.io#examples-helm-charts) focused on deploying various kind of application consuming the cluster services deployed using the [cluster-xxx charts](https://helm-repository.readthedocs.io#cluster-helm-charts).

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
helm show chart startx/example-imagestreams
```

### 4. Install this chart

```bash
helm install example-imagestreams startx/example-imagestreams
```

## Values dictionary

### context values dictionary

| Key                 | Default   | Description                                                                       |
| ------------------- | --------- | --------------------------------------------------------------------------------- |
| context.scope       | default   | Name of the global scope for this application (organisational tenant)             |
| context.cluster     | localhost | Name of the cluster running this application (platform tenant)                   |
| context.environment | dev       | Name of the environment for this application (ex: dev, factory, preprod or prod) |
| context.component   | demo      | Component name of this application (logical tenant)                               |
| context.app         | example-imagestreams     | Application name (functional tenant, default use Chart name)                     |
| context.version     | 0.0.1     | Version name of this application (default use Chart appVersion)                   |

### chart values dictionary

| Key          | Default | Description                             |
| ------------ | ------- | --------------------------------------- |
| enabled      | false   | Enable the create of the images streams |
| imagestreams | []      | List of imagestreams (see next section) |

### imagestreams values dictionary

| Key         | Default       | Description                                 |
| ----------- | ------------- | ------------------------------------------- |
| name        | default       | Image stream name                           |
| enabled     | true          | enable the image stream                     |
| namespace   | openshift     | Namespace were imagestream must resid       |
| displayName | Default image | Display name of the image stream            |
| labels      | string        | Labels for the image stream                 |
| tags        | []            | List of imagestreamstags (see next section) |

### imagestreamstags values dictionary

| Key              | Default        | Description                                                   |
| ---------------- | -------------- | ------------------------------------------------------------- |
| name             | latest         | tag name                                                      |
| enabled          | true           | enable the image stream tag                                   |
| desc             | {}             | description of the image stream                               |
| desc.iconClass   | icon-openshift | icon class to use for this image and tags                     |
| desc.provider    | startx         | name of the provider                                          |
| desc.displayName | Default linux  | Display name of this tag                                      |
| desc.description | string         | desription of this tag                                        |
| desc.tags        | string         | list of tags for this IST                                     |
| desc.supports    | string         | supported service                                             |
| desc.sampleRepo  | url            | sample repository                                             |
| source           | {}             | source for this image stream tag                              |
| source.kind      | docker         | kind of source for this tag (is or docker, default is docker) |
| source.image     | string         | Image source (from repository or image streams) (mandatory)   |
| source.namespace | openshift      | Image source namespace (for kind is)                          |

## Values files

### Default values file (values.yaml)

Simple imageStream deployment of a container image with the following characteristics :

- **1 imageStream** named **default** with **1 tag** :
  - **latest** representing container image **quay.io/startx/fedora:latest**

```bash
# base configuration running default configuration
helm install example-imagestreams startx/example-imagestreams
```

### STARTX values file (values-startx.yaml)

Imagestreams of startx public images hosted on quay.io and dockerhub. Theses stream are created into the **openshift** namespace.

- **1 imageStream** named **startx-os** based on **quay.io/startx/fedora** repository images. This imageStream contain **14 tags**
  - **fc26** representing container image **quay.io/startx/fedora:26**
  - **fc27** representing container image **quay.io/startx/fedora:27**
  - **fc28** representing container image **quay.io/startx/fedora:28**
  - **fc29** representing container image **quay.io/startx/fedora:29**
  - **fc30** representing container image **quay.io/startx/fedora:30**
  - **fc31** representing container image **quay.io/startx/fedora:31**
  - **fc32** representing container image **quay.io/startx/fedora:32**
  - **rawhide** representing container image **quay.io/startx/fedora:latest**
  - **ubi8** representing container image **quay.io/startx/ubi:8**
  - **centos8** representing container image **quay.io/startx/centos:8**
  - **centos7** representing container image **quay.io/startx/centos:7**
  - **centos6** representing container image **quay.io/startx/centos:6**
  - **alpine3** representing container image **quay.io/startx/alpine:3**
  - **latest** alias of the **rawhide** tag
- **1 imageStream** named **startx-apache** based on **quay.io/startx/apache** with **14 tags** (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- **1 imageStream** named **startx-couchbase** based on **quay.io/startx/couchbase** with **12 tags** (fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6 and latest)
- **1 imageStream** named **startx-mariadb** based on **quay.io/startx/mariadb** with **14 tags** (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- **1 imageStream** named **startx-memcache** based on **quay.io/startx/memcache** with **14 tags** (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- **1 imageStream** named **startx-mongodb** based on **quay.io/startx/mongodb** with **14 tags** (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- **1 imageStream** named **startx-nodejs** based on **quay.io/startx/nodejs** with **14 tags** (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- **1 imageStream** named **startx-ooconv** based on **quay.io/startx/ooconv** with **11 tags** (fc27, fc28, fc29, fc30, fc31, fc32, rawhide, centos7, centos6, alpine3 and latest)
- **1 imageStream** named **startx-php** based on **quay.io/startx/php** with **14 tags** (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- **1 imageStream** named **startx-postgresql** based on **quay.io/startx/postgresql** with **14 tags** (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- **1 imageStream** named **startx-chrome** based on **quay.io/startx/chrome** with **7 tags** (fc30, fc31, fc32, rawhide, centos7, alpine3 and latest)
- **1 imageStream** named **startx-firefox** based on **quay.io/startx/firefox** with **7 tags** (fc30, fc31, fc32, rawhide, centos7, alpine3 and latest)

```bash
# configuration for the startx public images
helm install example-imagestreams-startx startx/example-imagestreams -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-startx.yaml
```

### SXV4 values file (values-sxv4.yaml)

Imagestreams of container image used in the sxv4 project (depend on the sxtartx imagestreams examples previously exposed).

- **1 imageStream** named **sxv4-apache** with **3 tags** :
  - **dev** alias of the **startx-apache:latest** imagestream in **openshift** namespace
  - **test** alias of the **startx-apache:alpine3** imagestream in **openshift** namespace
  - **stable** alias of the **startx-apache:ubi8** imagestream in **openshift** namespace
- **1 imageStream** named **sxv4-mariadb** with **3 tags** :
  - **dev** alias of the **startx-mariadb:latest** imagestream in **openshift** namespace
  - **test** alias of the **startx-mariadb:alpine3** imagestream in **openshift** namespace
  - **stable** alias of the **startx-mariadb:ubi8** imagestream in **openshift** namespace
- **1 imageStream** named **sxv4-nodejs** with **3 tags** :
  - **dev** alias of the **startx-nodejs:latest** imagestream in **openshift** namespace
  - **test** alias of the **startx-nodejs:alpine3** imagestream in **openshift** namespace
  - **stable** alias of the **startx-nodejs:ubi8** imagestream in **openshift** namespace
- **1 imageStream** named **sxv4-php** with **3 tags** :
  - **dev** alias of the **startx-php:latest** imagestream in **openshift** namespace
  - **test** alias of the **startx-php:alpine3** imagestream in **openshift** namespace
  - **stable** alias of the **startx-php:ubi8** imagestream in **openshift** namespace

```bash
# configuration for the sxv4 project
helm install example-imagestreams-sxv4 startx/example-imagestreams -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-sxv4.yaml
```

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
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
| 21.3.199 | 2026-06-24 | publish stable update for the full repository |
| 21.3.201 | 2026-06-24 | publish stable update for the full repository |
| 21.3.202 | 2026-06-24 | publish stable update for the full repository |
| 21.3.205 | 2026-06-24 | publish stable update for the full repository |
| 21.3.229 | 2026-08-08 | publish stable update for the full repository |

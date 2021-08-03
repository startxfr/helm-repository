# Example imagestreams

This helm chart is used to used to load imagestreams into a given namespace.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
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
helm show chart startx/example-imagestreams
```

### 4. Install this chart

```bash
helm install startx/example-imagestreams
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
helm install startx/example-imagestreams
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
helm install startx/example-imagestreams -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-startx.yaml
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
helm install startx/example-imagestreams -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-sxv4.yaml
```

## History

| Release | Date       | Description                                                                       |
| ------- | ---------- | --------------------------------------------------------------------------------- |
| 0.3.133 | 2020-11-15 | Create chart example-imagestreams from example-imagestreams                       |
| 0.3.135 | 2020-11-15 | Add support for loading startx and sxv4 images streams into the openshift catalog |
| 0.3.135 | 2020-11-23 | Improve documentation for all examples charts                                     |
| 0.3.141 | 2020-11-24 | publish stable update for the full repository                                     |
| 0.3.151 | 2021-01-23 | Upgrade chart to OCP version 4.3.13                                               |
| 0.3.153 | 2021-01-23 | publish stable update for the full repository                                     |
| 0.3.165 | 2021-01-23 | Upgrade all chart dependencies                                                    |
| 0.3.167 | 2021-01-24 | Remove conditional dependencies for argocd compatibility in HA environments       |
| 0.3.169 | 2021-01-24 | Move to 0.3.155 dependencies                                                      |
| 0.3.187 | 2021-02-13 | Align example chart release to 0.3.187                                            |
| 0.3.191 | 2021-02-13 | Update cluster chart dependencies to 0.3.189                                      |
| 0.3.199 | 2021-02-20 | prepare alpha release of 0.4 and update dependencies charts                       |
| 0.3.201 | 2021-02-20 | Update icon and image for charts                                                  |
| 0.3.203 | 2021-02-21 | Upgrade chart release informations                                                |
| 0.3.207 | 2021-04-19 | Core chart dependencies moved to v0.3.205                                         |
| 0.3.209 | 2021-05-06 | Prepare upgrade to 4.7 and add template for AFD                                   |
| 0.3.215 | 2021-05-06 | Align all chart to release 0.3.215                                                |
| 0.3.225 | 2021-05-10 | Update all chart to use new RBAC naming                                           |
| 0.3.305 | 2021-06-04 | publish stable update for the full repository                                     |
| 0.3.343 | 2021-06-06 | publish stable update for the full repository                                     |
| 0.3.381 | 2021-06-10 | Align example and cluster charts dependencies to basic chart version 0.3.377      |
| 0.3.390 | 2021-06-12 | Prepare 0.4.0 release
| 0.3.423 | 2021-06-17 | Prepare the v0.4 release. Stable aligned version of all charts
| 0.3.431 | 2021-07-05 | Move to dependencies 1.18.0
| 0.3.480 | 2021-08-03 | publish stable update for the full repository
| 0.3.998 | 2021-08-04 | publish stable update for the full repository

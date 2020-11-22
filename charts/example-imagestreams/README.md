# STARTX helm : example-imagestreams

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

Simple imagestreams deployment of a container image with the following characteristics :

- 1 **imagestreams** named **default** with **1 tag** :
  - **latest** representing container image **quay.io/startx/fedora:latest**

```bash
# base configuration running default configuration
helm install startx/example-imagestreams
```

### STARTX values file (values-startx.yaml)

Imagestreams of startx public images hosted on quay.io and dockerhub.

- 1 **imagestreams** named **startx-os** with **14 tags** (detailed as an example for all imagestreams)
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
- 1 **imagestreams** named **startx-apache** with **14 tags** from **quay.io/startx/apache** repository (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- 1 **imagestreams** named **startx-couchbase** with **12 tags** from **quay.io/startx/couchbase** repository (fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6 and latest)
- 1 **imagestreams** named **startx-mariadb** with **14 tags** from **quay.io/startx/mariadb** repository (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- 1 **imagestreams** named **startx-memcache** with **14 tags** from **quay.io/startx/memcache** repository (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- 1 **imagestreams** named **startx-mongodb** with **14 tags** from **quay.io/startx/mongodb** repository (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- 1 **imagestreams** named **startx-nodejs** with **14 tags** from **quay.io/startx/nodejs** repository (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- 1 **imagestreams** named **startx-ooconv** with **11 tags** from **quay.io/startx/ooconv** repository (fc27, fc28, fc29, fc30, fc31, fc32, rawhide, centos7, centos6, alpine3 and latest)
- 1 **imagestreams** named **startx-php** with **14 tags** from **quay.io/startx/php** repository (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- 1 **imagestreams** named **startx-postgresql** with **14 tags** from **quay.io/startx/postgresql** repository (fc26, fc27, fc28, fc29, fc30, fc31, fc32, rawhide, ubi8, centos8, centos7, centos6, alpine3 and latest)
- 1 **imagestreams** named **startx-chrome** with **7 tags** from **quay.io/startx/chrome** repository (fc30, fc31, fc32, rawhide, centos7, alpine3 and latest)
- 1 **imagestreams** named **startx-firefox** with **7 tags** from **quay.io/startx/firefox** repository (fc30, fc31, fc32, rawhide, centos7, alpine3 and latest)

```bash
# configuration for the startx public images
helm install startx/example-imagestreams -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/example-sxapi/values-startx.yaml
```

### SXV4 values file (values-sxv4.yaml)

Imagestreams of container image used in the sxv4 project (depend on the sxtartx imagestreams examples previously exposed).

- 1 **imagestreams** named **sxv4-apache** with **3 tags** :
  - **dev** alias of the **startx-apache:latest** imagestream in **openshift** namespace
  - **test** alias of the **startx-apache:alpine3** imagestream in **openshift** namespace
  - **stable** alias of the **startx-apache:ubi8** imagestream in **openshift** namespace
- 1 **imagestreams** named **sxv4-mariadb** with **3 tags** :
  - **dev** alias of the **startx-mariadb:latest** imagestream in **openshift** namespace
  - **test** alias of the **startx-mariadb:alpine3** imagestream in **openshift** namespace
  - **stable** alias of the **startx-mariadb:ubi8** imagestream in **openshift** namespace
- 1 **imagestreams** named **sxv4-nodejs** with **3 tags** :
  - **dev** alias of the **startx-nodejs:latest** imagestream in **openshift** namespace
  - **test** alias of the **startx-nodejs:alpine3** imagestream in **openshift** namespace
  - **stable** alias of the **startx-nodejs:ubi8** imagestream in **openshift** namespace
- 1 **imagestreams** named **sxv4-php** with **3 tags** :
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

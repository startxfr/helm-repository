<<<<<<< HEAD
# helm-repository [![latest](https://img.shields.io/badge/latest-v10.12.97-blue.svg)](https://github.com/startxfr/helm-repository/releases/tag/10.12.34) [![last commit](https://img.shields.io/github/last-commit/startxfr/helm-repository.svg)](https://github.com/startxfr/helm-repository) [![Doc](https://readthedocs.org/projects/helm-repository/badge)](https://helm-repository.readthedocs.io)
=======
# helm-repository [![latest](https://img.shields.io/badge/latest-v10.12.114-blue.svg)](https://github.com/startxfr/helm-repository/releases/tag/10.12.34) [![last commit](https://img.shields.io/github/last-commit/startxfr/helm-repository.svg)](https://github.com/startxfr/helm-repository) [![Doc](https://readthedocs.org/projects/helm-repository/badge)](https://helm-repository.readthedocs.io)
>>>>>>> devel

helm charts for various infrastructure configuration and services running under an Openshift Container Platform (or OKD).

## Install chart from repository

### 1. Requirements

#### 1.1. install cli dependencies

```bash
yum install yq -y
```

#### 1.2. install helm

```bash
yum install helm -y
```

#### 1.3. Beiing connected to an openshift cluster

```bash
oc login -t <my-token> <my-openshift-api>
```

If you don't have access to an openshift cluster, consider using codeready-container
to run locally a simulated cluster.

### 2. Install repository

#### 2.1. Install this repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

#### 2.2. List all chart in this repository

```bash
helm search repo startx
```

### 3. Install chart

#### 3.1. Show chart detail

```bash
helm show chart startx/sxapi
```

#### 3.2. Install chart into cluster

```bash
helm install sxapi-demo startx/sxapi
```

## Install chart building environment

In order to get the full developement environment, you must stick to the following procedure

### 1. Get a copy of the repository

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository
```

### 2. Create a new chart

```bash
./sx-helm mychart create
```

### 3. Test a chart

```bash
./sx-helm mychart test
```

### 4. Package a chart

```bash
./sx-helm mychart package
```

### 5. Release a chart

```bash
./sx-helm mychart package auto
```

### 6. Delete a chart

```bash
./sx-helm mychart delete
```

## Release convention

Read the [release convention](https://helm-repository.readthedocs.io/en/latest/releases) for release details.

## Release history

Read the [doc history](https://helm-repository.readthedocs.io/en/latest/history) for release details.

# helm-charts-ocp-infra

helm charts for various infrastructure configuration and services running under an Openshift Container Platform (or OKD)

## Install chart from repository

XXXXX

## Install chart building environment

In order to get the full developement environment, you must stick to the following procedure

### 1. Get a copy of the repository

```bash
git clone https://github.com/startxfr/helm-charts-ocp-infra.git
cd helm-charts-ocp-infra
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

- MAJOR version for major helm structural changes that lead to break the compatibility with previous version (ex: X.0.0)
- MINOR version for major functionality ehancement added in a backwards compatible manner (ex: 0.X.0)
- PATCH version for bug, security and functionnals updates, backwards compatible for continous delivery (ex: 0.0.X)
- PRE-RELEASE version for an unstable release that might not satisfy the intended compatibility requirements (ex: 0.0.0-beta)
- BUILD version to identify to differents build during release preparation (ex: 0.0.0-tag)

Only MAJOR, MINOR and PATCH are mandatory for releasing an application.

Minor or patch release with an **odd number** are used for **stable** and releasable version.
A **even** minor or patch number indicate a release **not stable** and releasable.

The CI chain will run integration test suite and promote to a stable release number the code if
test are OK.

### Examples

- major release : `0.1.17` to `1.0.0`
- minor release : `1.0.0` to `1.1.0`
- patch release : `1.1.0` to `1.1.1`
- pre-release : `1.1.1` to `1.1.2-alpha`
- build release : `1.1.2+20200313144700` or `1.1.2-alpha+20200313144700`

## Release rules

- Major releases defined by startx strategy (driven by technology improvments)
- Minor releases defined by cross-chart, startx's driven roadmap
- Patch releases defined by technical issues related to charts
- pre-release defined as part of major and minor release lifecycle
- build release used only during dev, test, build CI operations

## Release history

### version 0.0.x (chanteix)

| Release | Date     | Description                                     |
| ------- | -------- | ----------------------------------------------- |
| 0.0.1   | 20-09-26 | Initial commit                                  |

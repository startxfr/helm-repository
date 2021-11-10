# Release convention

- **MAJOR** version is aligned to the **minor** version of Openshift 4.x version. (ex:  chart version 8.x.x is stable for OCP 4.8.x releases)
- **MINOR** version is aligned to the **patch** version of Openshift 4.x.x version. (ex:  chart version 8.13.x is stable for OCP 4.8.13 release)
- PATCH version for major functionality ehancement added in a backwards compatible manner (ex: 8.13.x)
- PRE-RELEASE version for bug, security and functionnals updates, backwards compatible for continous delivery (ex: 8.13.23-beta)

Only MAJOR, MINOR and PATCH are mandatory for naming a chart release.

Patch release with an **odd number** are used for **stable** and releasable version.
A **even** minor on the patch number indicate a release **not stable** and releasable.

The CI chain will run integration test suite and promote to a stable release number the code if
test are OK.

## Release rules

- Major releases defined by openshift minor change under the 4.x release
- Minor releases defined by openshift patch change under the 4.x.x release
- Patch releases defined by technical issues related to charts
- pre-release defined as part of major and minor release lifecycle

## Examples

- major release : `7.22.1` to `8.2.0`
- minor release : `8.2.0` to `8.3.1`
- patch release : `8.3.0` to `8.3.3`
- pre-release : `8.3.4` to `8.3.5-alpha`
- build release : `8.3.6+20210813144700` or `8.3.6-alpha+20210813144700`

## Link with Openshift lifecycle

Major release of Openshift Container Platform will lead to a Major release of this respository components.
Minor or patched Openshift Container Platform release will be stabilized within a Minor release of this repository chart.

# Release convention

- MAJOR version for major helm structural changes that lead to break the compatibility with previous version (ex: X.0.0)
- MINOR version for major functionality ehancement added in a backwards compatible manner (ex: 0.X.0)
- PATCH version for bug, security and functionnals updates, backwards compatible for continous delivery (ex: 0.0.X)
- PRE-RELEASE version for an unstable release that might not satisfy the intended compatibility requirements (ex: 0.0.0-beta)
- BUILD version to identify to differents build during release preparation (ex: 0.0.0-tag)

Only MAJOR, MINOR and PATCH are mandatory for naming a chart release.

Minor or patch release with an **odd number** are used for **stable** and releasable version.
A **even** minor or patch number indicate a release **not stable** and releasable.

The CI chain will run integration test suite and promote to a stable release number the code if
test are OK.

## Release rules

- Major releases defined by startx strategy (driven by technology improvments : helm, OCP)
- Minor releases defined by cross-chart, startx's driven roadmap
- Patch releases defined by technical issues related to charts
- pre-release defined as part of major and minor release lifecycle
- build release used only during dev, test, build CI operations

## Examples

- major release : `0.1.17` to `1.0.0`
- minor release : `1.0.0` to `1.1.0`
- patch release : `1.1.0` to `1.1.1`
- pre-release : `1.1.1` to `1.1.2-alpha`
- build release : `1.1.2+20200313144700` or `1.1.2-alpha+20200313144700`

## Link with Openshift lifecycle

Major release of Openshift Container Platform will lead to a Major release of this respository components.
Minor or patched Openshift Container Platform release will be stabilized within a Minor release of this repository chart.

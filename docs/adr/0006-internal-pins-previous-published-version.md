# ADR-0006 Internal dependency pins are the latest version already published

- Status: accepted (2026-11-22)
- Deciders: helm-repository maintainers
- Amends: [ADR-0001](0001-release-only-changed-charts.md) (a dependency release no longer forces the release of its
  dependents) and [ADR-0005](0005-generated-locks-not-tracked.md) (the pins are no longer aligned on the version just
  released, and the release order is no longer computed)

## Context

A chart that depends on another chart of this repository (`project`, `operator`, `sxapi`, `cluster-rbac`, the
`chaos-*` wrappers...) pins that dependency in `Chart.yaml`. Until now the release moved every pin to the version
released in the same run: in a full release `project` and all its dependents carried the same version (21.3.410
everywhere). A chart whose pin equals its own version cannot be rebuilt until its dependency is published, so the
release had to order the charts leaves first, refresh the repository index in the middle of the run
(`releaseRefreshResolutionIndex`) and compute the dependents of every released chart (`release-closure.py`). When a
download failed (`cluster-dell-csm` in 21.3.398: dependency download failed in the first pass, packaged in a second
pass) the whole chain stopped, and a complete rebuild from a clean checkout was not possible.

## Decision

- **The pin of an internal dependency is the highest version of that chart already published in the index of its
  repository, strictly lower than the version of the chart that carries the pin.** It is never equal to the chart
  version, so every chart can be built from the repository as it is published, in any order.
- An *internal dependency* is a `dependencies[]` item whose `repository` is served by this repository bucket
  (`HELM_REPO_BASEURL` of `.tools/config`). Upstream charts (kargo, vault, qdrant, gitlab, chaos-mesh, litmus,
  kube-monkey) and other registries are not concerned.
- The candidates are the versions of the **same MAJOR.MINOR** as the chart. At the first release of an OpenShift minor
  (21.4.0 after 21.3.x) no published version exists in that minor: the release is **refused**, and the procedure is
  to release the charts that have no internal dependency first (`make release CHART=project VERSION=21.4.0`, same for
  `operator`, `sxapi`, `cluster-rbac`...), publish, then release the others (they pin 21.4.0). The pins are never taken
  from the previous minor.
- The index is the one served by the dependency `repository` (`.../21/index.yaml`). When it cannot be downloaded the
  tool stops with exit code 2 and changes nothing: it never falls back to the versions of the local tree.
- A dependency that has no published version below the target is an error: publish that chart first, in a release of
  its own (new charts take two releases).
- One implementation, `.tools/bump-pins.py`, called by `routerChartRelease` for every chart with the version the
  chart is about to get (`--below`): `make release CHART=`, `/release-chart`, `/release-devel`, `release-charts` and
  `release-all` all go through it. A dependency that changed is **not** released again with its dependents:
  `release-closure.py`, the leaves-first order and the intermediate index refresh are removed.
- Guards, each proving something different:

  | Guard | Where | What it proves |
  | ----- | ----- | -------------- |
  | `bump-pins.py --check-offline` | `ci-check.sh static`, CI | offline: every pin is an exact `X.Y.Z` strictly lower than its chart version. It cannot know whether that version is published |
  | `bump-pins.py --below <next>` | `release-preflight.sh` | online: every pin resolves in the index below the version about to be released |
  | `bump-pins.py --check` | on demand | online: the pins in the tree are lower than the chart version **and** listed in the index |
  | `release-verify.sh` (`pins`) | after a release | the pin in each published package is lower than the release and its `.tgz` is served |

## Consequences

- A fix in `project` or `operator` reaches a dependent only when that dependent is released again. Procedure in two
  steps: (1) release and publish the dependency; (2) release the dependents that must take it (`make release CHART=<name>`,
  or `RELEASE_ALL=true make release-charts`): the release tool resolves their pins to the new version. `sx-helm
  changed-charts` lists the dependents whose pin lags behind the index (`bump-pins.py --lagging`).
- A dependent that needs a feature of a dependency (for instance `dockercfg.existingSecret` of `project` 21.3.398)
  must be released after that dependency is published, so its pin contains the feature.
- Between two releases `Chart.yaml` files may carry a pin equal to the chart version only until the next release
  rewrites them: the offline check is red on such a tree. The release run (or the pins commit that precedes it) must
  restore the rule.
- Chart.lock files stay generated artifacts (ADR-0005): a dependent of a release locks the versions resolved at its
  packaging, which are the published pins.
- Consumers keep pinning released chart versions in their own `Chart.yaml` (ADR-0004); the pins of this repository do
  not change that protocol.

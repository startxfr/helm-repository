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
- The candidates are the versions of the **same MAJOR.MINOR** as the chart. A pin is therefore never taken from the
  previous minor, and a chart cannot be released at `X.Y.0` with a pin on another chart of the same minor: the first
  releases of a minor are made in **rounds, one per level** of the dependency graph (below).
- **Bootstrap of an OpenShift minor** (first release of 21.4 after 21.3.x). `.tools/bump-pins.py --levels` lists the
  charts by depth in the internal dependency graph: level 0 = charts without internal dependency (`project`,
  `operator`, `sxapi`, `cluster-rbac`, `cluster-auth`, `cluster-config`...), level N = charts with at least one
  dependency of level N-1 (on 21.3.410: 17 charts at level 0, 71 at level 1, `chaos`, `cluster-3scale`,
  `cluster-quay` and `example-catalog` at level 2). Release the levels in order, each round with the next patch
  version: level 0 as `21.4.0`, publish, level 1 as `21.4.1` (its pins resolve to `21.4.0`), publish, level 2 as
  `21.4.2` (pins on `21.4.0`/`21.4.1`), publish. The index of the repository must list a round before the next round
  starts, otherwise the tool refuses (nothing published to pin); the publication between rounds (`make publish`) merges
  `devel` into `master` and pushes both each time. The literal commands are in `/new-major-release`.
  Charts of different levels then carry different versions until the next full release (ADR-0001 already allows it).
- The index is the one served by the dependency `repository` (`.../21/index.yaml`). When it cannot be downloaded the
  tool stops with exit code 2 and changes nothing: it never falls back to the versions of the local tree.
  A multi-chart release (`releaseAllCharts`) downloads and parses each index once for the whole run: the cli creates a
  temporary directory (`BUMP_PINS_CACHE`) and the start time of the run (`BUMP_PINS_RUN`), and removes the directory
  at the end. The index only changes at `make publish`, never during a release. An entry of another run or fetched
  before the start of the run is refused (exit 2); an inherited value is never trusted. The resolution is unchanged.
- A dependency that has no published version below the target is an error: publish that chart first, in a release of
  its own (new charts take two releases).
- One implementation, `.tools/bump-pins.py`, called by `routerChartRelease` for every chart with the version the
  chart is about to get (`--below`): `make release CHART=`, `/release-chart`, `/release-devel`, `release-charts` (the
  normal path for a release of several charts) and `release-all` all go through it. A dependency that changed is **not** released again with its dependents:
  `release-closure.py`, the leaves-first order and the intermediate index refresh are removed.
- Guards, each proving something different:

  | Guard | Where | What it proves |
  | ----- | ----- | -------------- |
  | `bump-pins.py --check-offline` | `ci-check.sh static`, CI | offline: every pin is an exact `X.Y.Z` strictly lower than its chart version. It cannot know whether that version is published |
  | `bump-pins.py --check` | on demand | online: the pins in the tree are lower than the chart version **and** listed in the index |
  | `release-preflight.sh` | before publication, stage-aware | tree already conform (after `release-charts` or after the pins commit): `bump-pins.py --check`, every pin is published. Tree not conform yet (before the release run): `bump-pins.py --below <next>`, every pin resolves in the index below the version about to be released |
  | `release-verify.sh` (`pins`) | after a release | the pin in each published package is lower than the release and its `.tgz` is served. Releases before 21.3.412 (`PINS_RULE_FROM`) predate the rule: a pin equal to the release is accepted there |

## Consequences

- A fix in `project` or `operator` reaches a dependent only when that dependent is released again **at a version above
  the version of the dependency that carries the fix**: the pin is always strictly below the version being released.
  Example: `project` fixed and published as 21.3.413; a dependent released at its default next version 21.3.413 resolves
  its pin to 21.3.410 (the highest version below 21.3.413), only a release at 21.3.414 or above takes the fix.
  Procedure in two steps: (1) release and publish the dependency; (2) release the dependents with a `VERSION` above it
  (`VERSION=21.3.414 make release CHART=<name>`, or `RELEASE_ALL=true VERSION=21.3.414 make release-charts`). Two guards:
  `bump-pins.py --lagging` (printed by `sx-helm changed-charts`) lists each dependent that pins a version lower than the
  highest published version of its dependency and the action (`release <chart> at a version above B`); it stays quiet
  for a dependency whose highest published version is the version of the dependent itself, which is the state of
  every dependent right after a full release at that version. And the release path prints a visible `WARNING` (it does
  not fail) when a chart is released at V while a dependency already has a published version >= V in the same minor,
  naming the version the release must exceed.
- A dependent that needs a feature of a dependency (for instance `dockercfg.existingSecret` of `project` 21.3.398)
  must be released after that dependency is published, so its pin contains the feature.
- Between two releases `Chart.yaml` files may carry a pin equal to the chart version only until the next release
  rewrites them: the offline check is red on such a tree. The release run (or the pins commit that precedes it) must
  restore the rule.
- Chart.lock files stay generated artifacts (ADR-0005): a dependent of a release locks the versions resolved at its
  packaging, which are the published pins.
- Consumers keep pinning released chart versions in their own `Chart.yaml` (ADR-0004); the pins of this repository do
  not change that protocol.

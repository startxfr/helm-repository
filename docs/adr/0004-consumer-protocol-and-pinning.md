# ADR-0004 Consumer protocol: pin releases, announce changes

- Status: accepted (2026-11-19)
- Deciders: helm-repository maintainers, with the zuno-demo maintainers

## Context

Consumers use the charts in two ways: Helm dependencies pinned in their `Chart.yaml` and locked in `Chart.lock`
(the safe way), and ArgoCD Applications that track a git branch such as `devel` with automated sync (unsafe: every
push is deployed within minutes). On 2026-11-19 pushes to `devel` re-synchronized several Applications on a shared
cluster.

## Decision

- Consumers pin a published chart version or an immutable git tag. A moving branch (`devel`, `master`, `stable`) is
  not a deployment target, and automated sync on a branch is discouraged.
- Every release creates an annotated tag named after the repository version (`21.3.N`). A pushed tag is never moved.
- Index URLs published in `stable`, `noschema` and `release-21` use HTTPS only (consumer ADR-0602 C4).
- Before pushing a change to a chart a known consumer uses (`cluster-rbac`, `operator`, `cluster-ods`,
  `cluster-certmanager`, `cluster-gpu`, `cluster-nfd`, `cluster-machine`, `cluster-prometheus`, `cluster-istio`),
  `helm-manager` tells the consumer's coordination session first.
- Consumers send their requests to `helm-manager`, who triages them: a request that blocks a consumer or breaks a
  consumer ADR has priority; the others go into the next release window. `helm-manager` is the only session that
  pushes, releases, publishes and tags.
- The public contract of the consumed charts (rendered kinds and key values) is covered by contract tests
  (`tests/contract/`).
- Before a push, `.tools/render-compare.sh <last-tag>` compares the rendered manifests of the consumed charts with the
  last release and its result is sent to the consumers. After a publish, `.tools/release-postflight.sh` checks that
  the versions listed in `.tools/consumer-pins.txt` are still in the stable index with an unchanged digest and are
  downloadable. Consumers can ask to add their pinned versions to that file.

## Consequences

- A release never reaches a consumer without an explicit version bump on their side.
- Breaking a documented contract requires a major note in the release history.

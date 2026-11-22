# ADR-0005 Chart.lock and subchart archives are not tracked

- Status: accepted (2026-11-19), amended in part by [ADR-0006](0006-internal-pins-previous-published-version.md) (2026-11-22):
  the pins are no longer aligned on the version released in the same run and the release order is no longer computed
- Deciders: helm-repository maintainers

## Context

Fifteen charts tracked their `Chart.lock` and the others ignored it through 70 per-chart `.gitignore` files,
while `cluster-istio` joined the tracked group during the Sail work. The lock of an internal chart only records
the versions and the digest of the dependencies that `helm dependency update` resolves, and every dependency
pin in a `Chart.yaml` is an exact version.

## Decision

- `Chart.lock` files and the `charts/<chart>/charts/` subchart archives are generated artifacts and are never tracked.
  The root `.gitignore` ignores them; per-chart `.gitignore` files are not needed for that.
- The release and the CI run `helm dependency update` themselves in a clean copy of the chart.
- Internal dependency pins (`project`, `operator`, `sxapi`, `cluster-*`, `chaos-*`) are exact and are aligned
  by `.tools/bump-pins.py` while a release runs. *Superseded by ADR-0006:* a pin is the latest version already
  published, strictly lower than the chart version; there is no leaves-first order any more.

## Consequences

- No lock churn in release commits and no stale tracked lock.
- A dependent can only be released after its dependencies exist on S3 (ADR-0006: the pin is a version already published, so any order works).
- Consumers keep their own locks (ADR-0004): they are the only place where a lock matters.

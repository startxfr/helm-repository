# ADR-0005 Chart.lock and subchart archives are not tracked

- Status: accepted (2026-11-19)
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
  by `.tools/bump-pins.py` while a release runs: charts are released in dependency order (leaves first) and a
  dependent takes the version just released for its dependencies (see ADR-0001).

## Consequences

- No lock churn in release commits and no stale tracked lock.
- A dependent can only be released after its dependencies exist on S3: the release order is computed, not alphabetical.
- Consumers keep their own locks (ADR-0004): they are the only place where a lock matters.

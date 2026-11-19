# ADR-0001 Release only the charts that changed

- Status: accepted (2026-11-19)
- Deciders: helm-repository maintainers

## Context

Until release 21.3.377 every release bumped all charts to the same version (91 charts at once), even when their
content did not change. Consumers pin chart versions in their own `Chart.yaml` and commit a `Chart.lock`: each
repository release therefore forced them to rebuild and re-lock dependencies that had not changed (see ADR-0004).

## Decision

- A release bumps and publishes only the charts whose content changed, plus the charts whose dependency pins were
  updated because a dependency changed.
- A chart that changes takes the next repository version (`.tools/repo-release`, `21.3.N`). Charts that did not change
  keep their previous version: versions across charts are no longer identical.
- The repository version stays the identity of a release: it is the annotated git tag created at promotion time
  (see ADR-0004) and the value of `.tools/repo-release`.
- A full release of every chart stays available (`make release-charts`) for a new OpenShift release or a change of
  the shared tooling.

## Consequences

- Consumers re-lock only what they use.
- `helm-repository` history tables list real changes instead of generic "full repository release" rows.
- The tooling must compute the list of changed charts since the previous release tag (`git diff --name-only <tag>..HEAD`).

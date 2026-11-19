# Roadmap

Plan agreed on 2026-11-19 to stabilize and harmonize the repository. Priorities: first never break a consumer (P0),
then make regressions visible (P1), then harmonize (P2), then validate on real clusters (P3).

| Item | Priority | Owner | Status |
| ---- | -------- | ----- | ------ |
| Publication protocol and consumer tags (ADR-0004) | P0 | helm-manager | done (tags per release; announce before pushing) |
| `cluster-auth` switch `auth.oauth.enabled`, ownership docs for `cluster-config` (ADR-0002) | P0 | helm-assist | done, unreleased |
| CI workflow (lint, template matrix, schemas, docs sync, misspellings guard on added lines) | P1 | helm-assist | done, not yet run on GitHub |
| Contract tests for the charts consumed by zuno (`tests/contract/run.sh`, 55 assertions, CI job) | P1 | helm-assist | done |
| Changed-only releases (ADR-0001) | P1 | helm-manager | done, first use at the next release |
| Remove the `master-4.x` / `stable-4.x` propagation | P1 | helm-manager | done |
| Versioned generator for `values-app` files | P2 | helm-assist | planned |
| Second misspelling wave (case variants: "Environement" in 74 schemas, plateform, ressource, graphana key excluded), bundled with the conventions release | P2 | helm-assist | planned |
| Regenerate the ArgoCD examples from one template (146 examples still at 21.3.199) | P2 | helm-assist | planned |
| Align `values.yaml` headers and README sections with the convention | P2 | helm-assist | planned |
| Replace the 7 provisional icons with the real logos | P2 | maintainers | open |
| Default spec of `cluster-ods` for RHOAI 3.x, validation on RHOAI 3.5 GA | P3 | helm-assist with zuno-demo | open |
| `unifai`: install the operator through the chart on a real cluster | P3 | maintainers | open |

Roles: `helm-manager` is the only session that pushes, releases, publishes and tags and arbitrates priorities with
the consumers; `helm-assist` prepares chart and documentation changes in local commits.

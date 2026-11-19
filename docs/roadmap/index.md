# Roadmap

Plan agreed on 2026-11-19 to stabilize and harmonize the repository. Priorities: first never break a consumer (P0),
then make regressions visible (P1), then harmonize (P2), then validate on real clusters (P3).

| Item | Priority | Owner | Status |
| ---- | -------- | ----- | ------ |
| Publication protocol and consumer tags (ADR-0004) | P0 | helm-manager | done (tags per release; announce before pushing) |
| `cluster-auth` switch `auth.oauth.enabled`, ownership docs for `cluster-config` (ADR-0002) | P0 | helm-assist | done, released in 21.3.379 |
| CI workflow (lint, template matrix, schemas, docs sync, blocking misspellings guard, contract tests) | P1 | helm-assist | done, first run on GitHub pending (triggers: pull request, push to devel) |
| Contract tests for the charts consumed by zuno (`tests/contract/run.sh`, 55 assertions, CI job) | P1 | helm-assist | done |
| Changed-only releases (ADR-0001) | P1 | helm-manager | done, in use from the next release (21.3.379 was a deliberate full release) |
| Remove the `master-4.x` / `stable-4.x` propagation | P1 | helm-manager | done |
| Versioned generator for `values-app` files (`.tools/generate-values-app.py`), `destinationNamespace` in `cluster-argocd` | P2 | helm-assist | done, released in 21.3.379 |
| Second misspelling wave (case variants, 75 schemas) and blocking CI guard | P2 | helm-assist | done, released in 21.3.379 |
| Align `values.yaml` first line (21 charts), README sections (26 + 14 charts), ArgoCD examples on `21.3.x` (205 files) | P2 | helm-assist | done, released in 21.3.379 |
| Replace the 7 provisional icons with the real logos | P2 | maintainers | open |
| Default spec of `cluster-ods` for RHOAI 3.x, validation on RHOAI 3.5 GA | P3 | helm-assist with zuno-demo | open |
| `unifai`: install the operator through the chart on a real cluster | P3 | maintainers | open |

Roles: `helm-manager` is the only session that pushes, releases, publishes and tags and arbitrates priorities with
the consumers; `helm-assist` prepares chart and documentation changes in local commits.

## Releases

| Release | Date | Content |
| ------- | ---- | ------- |
| 21.3.377 | 2026-11-19 | full release: aligned dependency pins, schemas, docs; tag used by demo333 pins |
| 21.3.378 | 2026-11-19 | `cluster-ods` (`clusterScoped`, RHOAI 3.x overlay), `cluster-istio` (Sail operator, tracked `Chart.lock`) |
| 21.3.379 | 2026-11-19 | conventions wave (spelling, READMEs, ArgoCD examples, `values-app` files), `cluster-auth` `auth.oauth.enabled`, `cluster-argocd` `destinationNamespace` |

## Next

- First CI run on GitHub, then fix what it reports.
- Validate `cluster-ods` on RHOAI 3.5 GA and choose the default component list (RHOAI 2.x components are still the default).
- Install the `unifai` operator through the chart on a real cluster.
- Replace the 7 provisional icons.
- From the next release on, only the changed charts are released (ADR-0001).

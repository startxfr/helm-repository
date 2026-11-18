# ![cluster-unifai](https://helm-repository.readthedocs.io/en/latest/img/cluster-unifai.svg "Cluster Chart : UnifAI") Cluster Chart : UnifAI (deprecated)

**This chart is deprecated and replaced by the [unifai](unifai.md) chart.**

`cluster-unifai` packaged the UnifAI component charts directly. UnifAI is now deployed by its own operator, and
the [unifai](unifai.md) chart installs that operator and a `UnifaiStack` resource.

The published `cluster-unifai` packages (up to 21.3.362) remain in the repository but do not install with their
default values and receive no further update. Do not use them for a new deployment.

## Moving to unifai

There is no in-place upgrade : the two charts do not share their values nor their resources. Install the
[unifai](unifai.md) chart in a new namespace, then remove the `cluster-unifai` release.

## History

| Release  | Date       | Description                                                                                   |
| -------- | ---------- | --------------------------------------------------------------------------------------------- |
| 21.3.1   | 2026-10-15 | Create chart cluster-unifai from cluster-kubecost                                             |
| 21.3.2   | 2026-10-15 | Rebuild as an umbrella chart vendoring the real component charts from startxfr/UnifAI (devel) |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release                                                  |
| 21.3.309 | 2026-10-27 | Adding new charts percona and align all to v21.3.309                                          |
| 21.3.321 | 2026-11-05 | Adding external secret management                                                             |
| 21.3.361 | 2026-11-10 | Release 21.3.361 for all charts                                                               |
| 21.3.362 | 2026-11-18 | publish stable update for the full repository                                                 |
| -        | 2026-11-18 | Deprecated, replaced by the unifai chart                                                      |

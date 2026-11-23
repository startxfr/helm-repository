# Quality tools

Scripts written by the `helm-quality` review agent to review chart patches and to verify releases.
They are helpers, not part of the release chain (`sx-helm`, `.tools/cli`, `release-*.sh` never call them).

Conventions of all the shell scripts:

- the repository is the one containing the script (`git rev-parse --show-toplevel`), they never write in it;
- the work files go to `$QUALITY_WORK` (default `${TMPDIR:-/tmp}/helm-quality`);
- review scripts work on a clean `git archive` of a commit, never on the working copy;
- nothing is written to S3, nothing is committed, tagged or pushed.

## Release verification (read only: indexes, downloads, git objects)

| Script | Usage | What it checks |
| ------ | ----- | -------------- |
| `verify-release.sh` | `<version> <approved-head>` | every chart of the tag is at `<version>` in the `stable` and `21` indexes, tag = `stable`, the approved head is an ancestor, nothing changed outside Chart.yaml / README / docs copies / indexes, three package digests |
| `all-packages.sh` | `<version>` | downloads the 92 packages of both indexes: digest, `stable` = `21` byte for byte, embedded Chart.yaml and subcharts = the tag and its pins, one History row, packaged README = tag README. Result in `$QUALITY_WORK/a<version>/summary.txt` |
| `rv.sh`, `rv-orig.sh`, `rv-patched.sh` | see the header of each | patch before/after render, and release verification variants |
| `rc-orig.sh`, `rc-patched.sh` | `<old-ref>` | compare the manifests rendered by a release tag and by HEAD |
| `watch-repo.sh` | none | one line per new commit touching `charts/` or `.tools/` |

## Patch review (clean archive of the base + `git apply`)

| Script | Usage | What it checks |
| ------ | ----- | -------------- |
| `project-golden.sh` | none | render-golden of `charts/project` and of every dependent, packaged at its pinned version |
| `dep-golden.sh` | `<dep chart> <patch> <base> <dependent ...>` | same for another dependency chart |
| `project-review.sh` | `<commit>` | review of a `charts/project` commit against a baseline snapshot in `$QUALITY_WORK/dk/snap-base` |
| `unifai-review.sh`, `unifai-review2.sh` | `<commit>` | UnifAI release bump: digests of `release.json` in the chart, old digests gone, CRDs and rules unchanged, render diff, CI modes (the release file is read from `$QUALITY_WORK/ub/`) |
| `apps-waves.py` | `<tree> <chart>` | renders every ArgoCD Application of a chart, wave by wave |
| `schema-blocks.py` | `<before tree> <after tree>` | validates every `operator` block with the old and the new schema |
| `dvo-matrix.py`, `dvo-matrix2.py` | see the header | cluster-dvo input matrix, before/after |
| `scenario_keys.py`, `krkn-run.sh` | see the header | krkn scenario keys against the upstream examples, and a krkn run in a pod |
| `prove-newchart.sh` | `<SRC> <NEW> <SRCSHORT> <SHORT>` | runs the commands of the `/new-chart` skill literally on a clean copy and the CI modes after it |

## Generators used for the README conventions (already applied, kept as a record)

`order-title-fix.py`, `values-files-reorg.py`, `values-files-batch1.py`, `values-files-engine.py`,
`values-files-docfix.py`, `values-files-chaos-argocd.py`, `ci-conventions.py`, `readme-layout-check.py`,
`vf-profile.py`, `mk.sh`. Each one takes a clean tree as argument, stops when a claim it writes is
not true in the files, and `mk.sh` builds a patch from the generators on the current HEAD.

# update-chart-deps

Re-pin the internal dependencies (`project`, `operator`, `sxapi`, `cluster-rbac`, `chaos-*`...) of the charts on the latest versions already published, then release the dependents that must take them (ADR-0006).

## The rule

A pin on a chart served by the repository bucket is the **highest version of that chart already published** in the index of its `repository` (same `MAJOR.MINOR`), **strictly lower than the version of the chart that carries the pin**. A pin is never equal to its own chart version. The release resolves the pins itself (`.tools/bump-pins.py --below <next version>`, called by `routerChartRelease`): this command is for the case where a dependency was released and its dependents must take it **now**, before the next full release.

## Usage

```
/update-chart-deps [--dry-run] [--family <family>]
```

Examples:
```
/update-chart-deps                    # list the lagging dependents, release them
/update-chart-deps --dry-run          # only list the pins that lag behind the index
/update-chart-deps --family cluster   # only cluster-* charts
```

## What this command does

1. Lists the pins older than the latest published version (`.tools/bump-pins.py --lagging`)
2. Releases each lagging dependent (`make release CHART=<name>`): the release tool re-resolves its pins on the published versions below the new version, and refuses (nothing written) when the index is unreachable or a dependency was never published
3. Publishes the result (`make publish-chart` / `make publish`) when the user asks for it

It never edits a `version:` of a dependency by hand and never pins a dependency on a version that is not yet published (publish the dependency first, in a release of its own).

**Prerequisites**: `helm`, `yq`, `aws` and `python3` with PyYAML in PATH (`~/.local/bin/`). Run with `PATH="/home/cl/.local/bin:$PATH"`.

## Instructions

You are executing the update-chart-deps command. Arguments: `$ARGUMENTS`

**Step 0 — Parse arguments**

- `--dry-run` in `$ARGUMENTS` → `DRY_RUN=true`, else `false`
- `--family <name>` (one of: chaos, cluster, example) → `TARGET_FAMILY=<name>`, else `all`

**Step 1 — Check the starting point**

```bash
export PATH="/home/cl/.local/bin:$PATH"
git status --short                         # must be clean (no release or other session running)
python3 .tools/bump-pins.py --check-offline   # every pin must already be lower than its chart version
```

If the check fails, stop and report: the tree is in the state of an unfinished release; a release run rewrites the pins.

**Step 2 — List the dependents that lag behind**

```bash
python3 .tools/bump-pins.py --lagging
```

One line per pin: `<chart>: <dependency> pinned on <pin>, <latest> is published`. Keep the charts of `TARGET_FAMILY` (`chaos`, `chaos-*` / `cluster-*` / `example-*`). If the index cannot be downloaded the tool exits with code 2: stop and report, never fall back to the local tree.

Print the list grouped by family. If `DRY_RUN=true`, stop here.

**Step 3 — Release the dependents**

For each chart of the list:

```bash
export PATH="/home/cl/.local/bin:$PATH"
INTERACTIVE=false DESC="pin <dependency> on <version>" make release CHART=<name>
```

The release tool rewrites the pins (`bump-pins.py --apply --only <chart> --below <new version>`) before it bumps and packages. A chart that fails is reported, the others continue. Never release a dependent before the dependency it must take is published.

**Step 4 — Publish and report**

Ask the user before publishing, then `make publish` (or `make publish-chart CHART=<name>`). Print the charts released, the version of each pin resolved, and the errors.

## Known issues

- `helm`, `yq`, `aws` are in `~/.local/bin/`, not in the default PATH.
- A full release takes 30+ minutes (dependency downloads): never pipe it through `head`; run it in the background with its output in a log file.
- A dependency that was never published (new chart) has no version to pin: publish it alone first (ADR-0006), then release its dependents.
- At the first release of a new OpenShift minor no version of the same `MAJOR.MINOR` is published yet: release the charts without internal dependency first (see `/new-major-release`).

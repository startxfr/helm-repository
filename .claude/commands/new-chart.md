# new-chart

Create a new Helm chart by copying the closest existing chart and adapting all metadata.

## Usage

```
/new-chart <family>-<short-name>
```

Example: `/new-chart cluster-nmstate`

## Instructions

You are executing the new-chart command. `$ARGUMENTS` is the full chart name (e.g. `cluster-nmstate`).

**Step 1 — Gather inputs**

Ask for these three pieces of information before doing anything:

| # | Question | Example |
|---|----------|---------|
| 1 | **Chart family** — `example`, `cluster`, or `chaos`? | `cluster` |
| 2 | **Short name** — lowercase, no prefix | `nmstate` |
| 3 | **Description** — one English sentence describing what the chart does | `"configure NMState network operator for node-level network configuration"` |

The full chart name is `<family>-<short-name>` (e.g. `cluster-nmstate`).

**Step 2 — Find the closest existing chart**

Search `charts/` for a chart from the same family that deploys a similar resource type (operator subscription, CRD, console plugin, etc.). Present 2–3 candidates ranked by relevance and ask the user to confirm the source.

Guidance by family:
- `cluster-*` operator → prefer `cluster-nfd`, `cluster-certmanager`, or `cluster-pipeline`
- `cluster-*` with Console Plugin → prefer a chart that already has a `consoleplugin.yaml` template
- `example-*` → prefer the closest `example-*` by resource type
- `chaos-*` → prefer an existing `chaos-*` chart

**Step 3 — Copy and rename**

```bash
cp -r charts/<source> charts/<family>-<short-name>
```

**Step 4 — Update Chart.yaml and README.md**

**Chart.yaml** — replace every reference to the source chart:

- `name` → `<family>-<short-name>`
- `description` → user-provided sentence (no trailing period)
- `appVersion` → upstream version (or `TODO:` placeholder)
- `icon` → `https://helm-repository.readthedocs.io/en/latest/img/<family>-<short-name>.svg`
- `sources` → update both URLs to the new chart name
- `annotations.artifacthub.io/changes` → `"[<family>-<short-name>] Initial chart creation"`
- `annotations.artifacthub.io/prerelease` → `"true"`
- `version` → keep the source version (bumped on first release)

**README.md** — replace every reference to the source chart:

- Title line, badge URL, description paragraph, `helm install` commands
- `## History` table: delete all rows, add one initial entry:
  ```
  | <version> | <today-date> | Initial chart creation |
  ```
- Fix `context.app` default in value tables: must equal `<family>-<short-name>`

**Step 5 — Clean up templates**

- Always keep: `_helpers.tpl`, `_startx.tpl`, `NOTES.txt`
- Update all template `define` names from `<source>.*` to `<family>-<short-name>.*`
- For `cluster-*` operator charts: keep `subscription.yaml`, `operatorgroup.yaml`; add `consoleplugin.yaml` if the operator ships one
- Remove any template referencing a resource type irrelevant to the new chart
- Copy missing templates from the most similar chart that has them

**Step 6 — Adjust values.yaml**

Keep the `context:` block. Update all operator-specific fields:

- `context.app` → `default-<short-name>`
- `subscription.name` → exact OperatorHub package name
- `subscription.namespace` → operator's target namespace (e.g. `openshift-<short-name>`)
- `subscription.operator.channel` → current stable channel (`stable` unless documented otherwise)
- `subscription.operator.source.name` → `redhat-operators` for Red Hat operators, `certified-operators` otherwise
- `operatorGroup.name` and `operatorGroup.namespace` → match subscription namespace
- `operatorGroup.providedAPIs` → list of CRDs shipped by the operator
- Remove source-chart keys with no equivalent; add CRD-specific keys with inline comments
- Mirror changes in `values-startx.yaml`

**Step 7 — Publish to docs**

**7a — Copy the logo**

```bash
cp docs/img/<source>.svg docs/img/<family>-<short-name>.svg
```

All logos are SVG files in `docs/img/`. The `icon:` path in `Chart.yaml` must reference this file.

**7b — Publish README to docs**

```bash
cp charts/<family>-<short-name>/README.md docs/charts/<family>-<short-name>.md
```

The file in `docs/charts/` must be identical to the chart `README.md`.

**7c — Register in docs/index.md**

Insert a new row in the appropriate family table, after the alphabetically closest existing entry:

```markdown
| **[<family>-<short-name>](charts/<family>-<short-name>.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/<family>-<short-name>) | <description matching Chart.yaml> |
```

Match the column padding of surrounding rows.

**Step 8 — Report (no commit)**

Output a structured summary:

```
## New chart: <family>-<short-name>

Source: charts/<source>  →  charts/<family>-<short-name>/

### Files changed
- Chart.yaml              — name, description, appVersion, icon, sources, annotations
- README.md               — title, badge, description, commands, history reset
- values.yaml             — context.app, subscription, operatorGroup updated
- values-startx.yaml      — mirrors values.yaml changes
- templates/_helpers.tpl  — define names updated
- templates/<old>.yaml    — removed
- templates/<new>.yaml    — added
- docs/img/<family>-<short-name>.svg   — logo (placeholder from source)
- docs/charts/<family>-<short-name>.md — README published
- docs/index.md           — row added in <family> table

### TODOs before first release
- [ ] Confirm appVersion against the actual upstream release
- [ ] Confirm subscription.operator.channel is the current stable channel
- [ ] Run: helm template <family>-<short-name> charts/<family>-<short-name>/
- [ ] Run: helm dependency update charts/<family>-<short-name>/
- [ ] Replace docs/img/<family>-<short-name>.svg with a dedicated icon
```

Do **not** run `git add` or `git commit`.

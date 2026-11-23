# new-chart

Create a new Helm chart by copying the closest existing chart and adapting every name, file and deliverable.
The rules the result must follow are in `docs/contribute-conventions.md`; the result is checked by `.github/scripts/ci-check.sh`.

## Usage

```
/new-chart <family>-<short-name>
```

Example: `/new-chart cluster-nmstate`

## Instructions

You are executing the new-chart command. `$ARGUMENTS` is the full chart name (e.g. `cluster-nmstate`).
Run the commands of each step exactly as written (replace the variables first), from the root of the repository.

**Step 1 - Gather inputs**

Ask for these three pieces of information before doing anything:

| # | Question | Example |
|---|----------|---------|
| 1 | **Chart family** - `example`, `cluster`, or `chaos`? | `cluster` |
| 2 | **Short name** - lowercase, no prefix | `nmstate` |
| 3 | **Description** - one English sentence describing what the chart does | `"configure NMState network operator for node-level network configuration"` |

The full chart name is `<family>-<short-name>` (e.g. `cluster-nmstate`).

**Step 2 - Find the closest existing chart**

Search `charts/` for a chart from the same family that deploys a similar resource type (operator subscription, CRD, console plugin, etc.). Present 2-3 candidates ranked by relevance and ask the user to confirm the source.

Guidance by family:
- `cluster-*` operator → prefer `cluster-nfd`, `cluster-certmanager`, or `cluster-pipeline`
- `cluster-*` with Console Plugin → prefer a chart that already has a `consoleplugin.yaml` template
- `example-*` → prefer the closest `example-*` by resource type
- `chaos-*` → prefer an existing `chaos-*` chart

**Step 3 - Copy, clean and rename**

Set the variables (`SRC` = confirmed source chart, `NEW` = the new chart, `SRCSHORT` / `SHORT` = their names without the family prefix):

```bash
SRC=cluster-nfd; NEW=cluster-demo; SRCSHORT=nfd; SHORT=demo
```

Copy the chart, drop what is generated, keep only the reference values files, then rename every occurrence of the source chart name:

```bash
cp -r charts/$SRC charts/$NEW
rm -rf charts/$NEW/charts charts/$NEW/Chart.lock
find charts/$NEW -maxdepth 1 -name 'values-*.yaml' ! -name values-startx.yaml ! -name values-startx_noinfra.yaml ! -name values-demo.yaml -delete
grep -rlI -- "$SRC" charts/$NEW | xargs -r sed -i "s/$SRC/$NEW/g"
grep -rnI -- "$SRC" charts/$NEW        # must print nothing
grep -rnIw -- "$SRCSHORT" charts/$NEW  # every line printed is a name of the source (key, namespace, context.app, label...): rename it in step 6
```

Why only these values files (`values-startx*.yaml` for `cluster-*` and `chaos-*`, `values-demo.yaml` for `example-*`): the source may carry files of other clusters or customers, and `## Values files` of the README must describe every `values-*.yaml` of the chart (checked in step 9). Add other values files later, each with its description.

**Step 4 - Update Chart.yaml and README.md**

**Chart.yaml** (the rename of step 3 already did `name`, `icon` and `sources`; check them):

- `name` → `<family>-<short-name>`
- `description` → user-provided sentence (no trailing period)
- `appVersion` → upstream version (or `TODO:` placeholder)
- `icon` → `https://helm-repository.readthedocs.io/en/latest/img/<family>-<short-name>.svg`
- `sources` → both URLs name the new chart
- `annotations.artifacthub.io/changes` → `"[<family>-<short-name>] Initial chart creation"`
- `annotations.artifacthub.io/prerelease` → `"true"`
- `version` → keep the source version (set by the release tooling at the first release)
- `dependencies[].version` → left as copied, never edited by hand: the first release resolves every internal pin (`project`, `operator`, `sxapi`, `cluster-rbac`, `chaos-*`...) on the latest version already published below the version of the new chart (ADR-0006, `.tools/bump-pins.py --only <chart> --below <version>`). A dependency that was never published stops the release: release it first, alone. A chart that depends on the new chart can only be released after the new chart is released **and published** (`make publish`).

**README.md** (the rename of step 3 already replaced the chart name in the title, badge, commands and URLs):

- Description paragraph: the user sentence.
- `## History`: delete all rows, add one initial entry (same column layout, the row ends with `|`):
  ```
  | <version> | <today-date> | Initial chart creation |
  ```
- `context.app` default in the value tables: `default-<short-name>` (see step 6).
- `## Values files`: one bullet per `values-*.yaml` left in the chart (`values-startx.yaml`, `values-startx_noinfra.yaml` or `values-demo.yaml`) with a description of what it sets and its `helm install ... -f` line. A file that is not named there fails `ci-check.sh conventions`.
- Keep the other sections of the source README in their order (`docs/contribute-conventions.md`, section 5): Requirements and guidelines, Deploy this helm chart on openshift, Default values, Values files, Values dictionary, Deploy with ArgoCD (mandatory for `cluster-*` and for any chart with `examples/argocd/`), History last.

**Step 5 - Clean up templates**

- Always keep: `_helpers.tpl`, `_startx.tpl`, `NOTES.txt`
- Template `define` names were renamed in step 3 (`<source>.*` → `<family>-<short-name>.*`); `grep -rn 'define' charts/$NEW/templates | head` to confirm
- For `cluster-*` operator charts: keep `subscription.yaml`, `operatorgroup.yaml`; add `consoleplugin.yaml` if the operator ships one
- Remove any template referencing a resource type irrelevant to the new chart
- Copy missing templates from the most similar chart that has them

**Step 6 - Adjust values.yaml and the schema**

Keep the `context:` block. Update all operator-specific fields:

- `context.app` → `default-<short-name>` (the rule of 59 charts; a few older charts use the chart name or another value, they stay as they are)
- `subscription.name` → exact OperatorHub package name
- `subscription.namespace` → operator's target namespace (e.g. `openshift-<short-name>`)
- `subscription.operator.channel` → current stable channel (`stable` unless documented otherwise)
- `subscription.operator.source.name` → `redhat-operators` for Red Hat operators, `certified-operators` otherwise
- `operatorGroup.name` and `operatorGroup.namespace` → match subscription namespace
- `operatorGroup.providedAPIs` → list of CRDs shipped by the operator
- Fix every line printed by the `grep -rnIw "$SRCSHORT"` of step 3 (keys, namespaces, labels, `context.app`), in `values.yaml`, the values files and the templates
- Remove source-chart keys with no equivalent; add CRD-specific keys with inline comments
- Mirror changes in the values files left in the chart (`values-startx.yaml`, `values-startx_noinfra.yaml` or `values-demo.yaml`)

Then update `values.schema.json`. The blocks of the internal dependencies are generated by `.tools/schema-sync.py`; the keys of the chart itself are written by hand in `properties`: rename, add or remove there every key you renamed, added or removed in `values.yaml` (a key renamed in `values.yaml` but not in the schema is reported as missing):

```bash
python3 .tools/schema-sync.py $NEW
python3 .tools/schema-sync.py --check $NEW
.github/scripts/ci-check.sh schema      # must print: schema drift: 0 key(s) missing in 0 chart(s); otherwise it lists the keys to add
```

**Step 7 - ArgoCD deliverables (`cluster-*` and `chaos-*` charts; skip for `example-*`, which have none)**

`charts/$NEW/examples/argocd/` was copied and renamed in step 3: `appproject.yaml`, `kustomization.yaml` and one `application-<wave>.yaml` per wave. Check that every file names `$NEW` (AppProject, Applications, `chart:`, destination namespaces), that the namespaces and sync waves match the new chart, that `kustomization.yaml` lists every file of the directory and that the `spec.project` of every Application is the AppProject of the directory. Then make `## Deploy with ArgoCD` of the README describe these files, and generate the cluster-argocd file:

```bash
python3 .tools/generate-values-app.py $NEW
ls charts/cluster-argocd/values-app-$NEW.yaml
grep -c "$SRC" charts/cluster-argocd/values-app-$NEW.yaml   # must print 0
```

Add the chart to the list *Charts with ArgoCD examples* of `CLAUDE.md` (report it in step 9 if the user does not want `CLAUDE.md` edited).

**Step 8 - Publish to docs**

**8a - Copy the logo**

```bash
cp docs/img/$SRC.svg docs/img/$NEW.svg
```

All logos are SVG files in `docs/img/`. The `icon:` path in `Chart.yaml` must reference this file.

**8b - Publish README to docs**

```bash
cp charts/$NEW/README.md docs/charts/$NEW.md
```

The file in `docs/charts/` must be identical to the chart `README.md`; run this copy again after every later README edit.

**8c - Register in docs/index.md and mkdocs.yml**

Insert a new row in the appropriate family table of `docs/index.md`, after the alphabetically closest existing entry:

```markdown
| **[<family>-<short-name>](charts/<family>-<short-name>.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/<family>-<short-name>) | <description matching Chart.yaml> |
```

Match the column padding of surrounding rows. Add the page to the nav of `mkdocs.yml`, in the section of the family (`Cluster charts`, `Examples charts`, `Chaos charts`), next to the closest entry:

```yaml
    - '<Title>': 'charts/<family>-<short-name>.md'
```

**Step 9 - Check, then report (no commit)**

Run the four CI modes; each must end without `FAIL` and `conventions` must print `ok`:

```bash
.github/scripts/ci-check.sh static
.github/scripts/ci-check.sh schema
.github/scripts/ci-check.sh argocd
CI_CONVENTIONS_STRICT=true .github/scripts/ci-check.sh conventions $NEW
```

Fix what they report and run them again. Then, when the network is available: `helm dependency update charts/$NEW && .github/scripts/ci-check.sh charts $NEW` (lint and render of default values, every values file and every `<key>.enabled`).

Output a structured summary:

```
## New chart: <family>-<short-name>

Source: charts/<source>  →  charts/<family>-<short-name>/

### Files changed
- Chart.yaml              - name, description, appVersion, icon, sources, annotations
- README.md               - title, badge, description, Values files, Deploy with ArgoCD, history reset
- values.yaml             - context.app, subscription, operatorGroup updated
- values-startx.yaml, values-startx_noinfra.yaml (or values-demo.yaml) - mirror values.yaml changes
- values.schema.json      - dependency blocks regenerated, own keys updated
- templates/<old>.yaml    - removed
- templates/<new>.yaml    - added
- examples/argocd/        - renamed and adapted (cluster-*, chaos-*)
- charts/cluster-argocd/values-app-<family>-<short-name>.yaml - generated (cluster-*, chaos-*)
- docs/img/<family>-<short-name>.svg   - logo (placeholder from source)
- docs/charts/<family>-<short-name>.md - README published
- docs/index.md, mkdocs.yml - row and nav entry added

### CI modes
static / schema / argocd / conventions: <result of each>

### TODOs before first release
- [ ] Confirm appVersion against the actual upstream release
- [ ] Confirm subscription.operator.channel is the current stable channel
- [ ] Release the chart, then run `make publish`, before releasing any chart that depends on it (ADR-0006); its own dependencies (project, operator...) must already be published
- [ ] Add the chart to the list *Charts with ArgoCD examples* of CLAUDE.md (cluster-*, chaos-*)
- [ ] Replace docs/img/<family>-<short-name>.svg with a dedicated icon
```

Do **not** run `git add` or `git commit`.

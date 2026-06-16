# helm-repository — CLAUDE.md

**Language**: English only. Never French or any other language in code, comments, commits, or docs.

## Overview

`github.com/startxfr/helm-repository` — Helm chart repository for Openshift/Kubernetes, published on GitHub Pages, ReadTheDocs (helm-repository.readthedocs.io) and ArtifactHub.

Three remotes: `origin` (GitHub), `gitlab` (GitLab), `monaco` (AWS CodeCommit).

## Chart families

| Prefix | Role |
|--------|------|
| `chaos-*` | Chaos testing tools (cerberus, kraken, litmus, mesh, monkey) + umbrella `chaos` |
| `cluster-*` | Cluster-level configuration via Openshift operators |
| `example-*` | Demo / tutorial deployments |
| `operator` | Generic operator subscription chart |
| `project` | Base chart: project/namespace + RBAC + NetworkPolicy + Quotas + LimitRange |
| `sxapi` | Micro-service deployment based on the sxapi nodejs engine |

## Chart structure (every chart must have all of these)

```
charts/<name>/
  Chart.yaml          ← metadata, version, appVersion, keywords, annotations
  values.yaml         ← default values with inline comments on every top-level key
  values.schema.json  ← JSON Schema for value validation
  README.md           ← documentation (see sections below)
  .helmignore
  templates/
    _helpers.tpl
    _startx.tpl       ← shared STARTX Helm library (copied from .tools/_startx.tpl)
    NOTES.txt
    *.yaml
```

## Chart.yaml rules

- `name`: lowercase, kebab-case, matches directory name
- `description`: single English sentence, must match README intro. Must NOT be a placeholder (`>-` with empty next line) or a copy from another chart.
- `type`: always `application`
- `version`: aligned to OCP release cycle (`MAJOR.MINOR.PATCH`, e.g. `21.3.3`)
- `appVersion`: the upstream component version being deployed
- `kubeVersion`: always set (e.g. `">=1.30.0-0"`)
- `annotations.artifacthub.io/changes`: updated on every release with a one-line change description
- `annotations.artifacthub.io/prerelease`: `"true"` for unstable, `"false"` for stable

## README.md structure (mandatory sections in order)

```markdown
# ![<name>](<svg-url> "<Family> Chart : <Title>") <Family> Chart : <Title>
[![Artifacthub](<badge>)](<search-url>)

<One-paragraph description — must match Chart.yaml description>

This chart is part of the [<family> startx helm chart series](<rtd-url>#<family>-helm-charts)...

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster
### 2. Install the repository
### 3. Get information about this chart
### 4. Install this chart
#### Default values         ← bullet-list of what gets deployed, then `helm install` command
#### Others values availables  ← one entry per values-*.yaml file

## Values dictionary         ← chaos/example/basic charts only
### context values dictionary
### <feature> values dictionary

## Default values            ← cluster-* charts: inline under ### 4. Install this chart

## History

| Release | Date | Description |
| ------- | ---- | ----------- |
| x.y.z   | YYYY-MM-DD | Description |
```

**All history table rows must end with a trailing `|`** — rows without it break Markdown table rendering.

## values.yaml rules

- First line: `# Default values for <chart-name>.`
- Second line: blank
- Third line: `# Application deployment context`
- `context:` is always the first key, with inline comment on every sub-key
- Every top-level key must have at least one `# comment` line immediately above it
- Commented-out examples use `# # Comment` (double `#`) or `# - key: value` style
- `nameOverride` and `versionOverride` must appear commented at the top
- **No French words** in comments

## Recurring misspellings to fix everywhere

| Wrong | Correct |
|-------|---------|
| `environement` | `environment` |
| `plateform` | `platform` |
| `ressource` | `resource` |
| `functionnal` | `functional` |
| `organisational` | `organizational` |
| `recommandations` | `recommendations` |
| `depedencies` | `dependencies` |
| `personnalized` | `personalized` |
| `lest than` | `less than` |
| `graphana` | `grafana` |
| `projet` | `project` |
| `helm_reposistory` | `helm_repository` |

## context.app default value in README tables

The `context.app` default shown in README value tables must match the chart name, not `sxapi`. Charts with wrong default: chaos-*, cluster-vault, cluster-vault-config, example-deployment, example-chaos, example-imagestreams, example-catalog, example-pod, example-fruitapp-*.

## Known wrong Chart.yaml descriptions (stale copy-paste)

| Chart | Current (wrong) | Should be |
|-------|-----------------|-----------|
| `cluster-acs` | "configure Advanced Cluster Manager" | "configure Advanced Cluster Security (ACS/Stackrox)" |
| `cluster-kubevirt` | "configure Code Ready Workspace" | "configure KubeVirt and OpenShift Virtualization" |
| `cluster-logging` | "configure Metering" | "configure Logging (cluster-logging operator)" |

## README placeholder issues

Charts where `description` in README is still the `_sample_` placeholder (`This helm chart must have a description`):
- `cluster-acm`, `cluster-acs`

Charts where `## Default values` section body is still `xxxx to do xxxxxx`:
- `cluster-console`, `cluster-knative`, `cluster-kubevirt`, `cluster-localstorage`, `cluster-logging`, `cluster-mustgather`, `cluster-oadp` *(partial)*, `cluster-odf`, `cluster-ods`, `cluster-storage-efs`

## History table formatting

All rows must use fully-piped Markdown table format:
```markdown
| 21.3.3 | 2026-03-02 | Description here |
```
Not:
```markdown
| 21.3.3 | 2026-03-02 | Description here
```
The missing trailing `|` affects every chart (70+). Fix when editing a chart — do not do a bulk search-replace on history tables as some entries are intentionally truncated for space.

## Duplicate history entries

Charts with duplicate release rows (same release number and date twice):
- `cluster-certmanager` (11.7.18 twice)
- `cluster-nfd` (11.7.18 twice)
- `cluster-crunchy` (11.28.68 twice)
- `project` (0.3.155, 0.3.189, 0.3.217, 7.22.27 each appear twice)

## New chart creation procedure

When the user asks to create a new chart, follow these steps in order.

### Step 1 — Gather inputs (ask if not provided)

Ask the user for the following three pieces of information before doing anything:

| # | Question | Example answer |
|---|----------|---------------|
| 1 | **Chart family** — `example`, `cluster`, or `chaos`? | `cluster` |
| 2 | **Short name** — lowercase, no prefix | `nmstate` |
| 3 | **Description** — one English sentence describing what the chart does | `"configure NMState network operator for node-level network configuration"` |

The full chart name is `<family>-<short-name>` (e.g. `cluster-nmstate`).

### Step 2 — Find the closest existing chart

Search `charts/` for an existing chart from the same family that deploys a similar kind of resource (operator subscription, CRD, console plugin, etc.). Inspect its `Chart.yaml`, `values.yaml`, and `templates/` to judge similarity. Present 2–3 candidates ranked by relevance and ask the user to confirm which one to use as the source.

Criteria by family:
- `cluster-*` that installs an operator → prefer `cluster-nfd`, `cluster-certmanager`, or `cluster-pipeline` as sources.
- `cluster-*` with a Console Plugin → prefer a chart that already has a `consoleplugin` template.
- `example-*` → prefer the closest `example-*` by resource type.
- `chaos-*` → prefer an existing `chaos-*` chart.

### Step 3 — Copy and rename

```bash
cp -r charts/<source> charts/<family>-<short-name>
```

Do not git-add yet.

### Step 4 — Search-and-replace (Chart.yaml and README.md)

Replace every occurrence of the source chart's name with the new chart name. At minimum:

- `Chart.yaml`:
  - `name:` → `<family>-<short-name>`
  - `description:` → the user-provided description (single sentence, no trailing period)
  - `appVersion:` → upstream component version (look it up or leave a `TODO:` placeholder)
  - `annotations.artifacthub.io/changes:` → `"[<family>-<short-name>] Initial chart creation"`
  - `annotations.artifacthub.io/prerelease:` → `"true"`
  - `version:` → keep the same version number as the source (it will be bumped on first release)

- `README.md`:
  - Title line: update chart name and family
  - ArtifactHub badge URL: replace source chart name with new chart name
  - Description paragraph: replace with the user-provided description
  - `helm install` commands: update release name and chart reference
  - `## History` table: **delete all existing rows**, keep only the header row and a single initial entry:
    ```
    | <version> | <today-date> | Initial chart creation |
    ```
  - Fix any `context.app` default value in value tables: must equal `<family>-<short-name>`.

### Step 5 — Clean up templates

Remove templates that do not apply to the new chart. Use the source chart as a starting point but evaluate each file:

- Keep: `_helpers.tpl`, `_startx.tpl`, `NOTES.txt`
- For `cluster-*` operator charts, keep: `subscription.yaml`, `operatorgroup.yaml`; add `consoleplugin.yaml` if the operator ships one
- Remove: any template that references a resource type not relevant to the new chart (e.g. `networkpolicy.yaml` for a pure operator chart)
- If a needed template does not exist in the source, copy it from the most similar chart that has it

### Step 6 — Adjust values.yaml

Keep the `context:` block structure from the source. Update operator-specific sections:

- `operatorGroup.targetNamespaces` — set appropriate namespace scope
- `subscription.channel` — set the current stable channel for the operator (research if unknown, leave `TODO:` if uncertain)
- `subscription.source` — usually `redhat-operators` for Red Hat operators, `certified-operators` otherwise
- `subscription.name` — the exact package name in the OperatorHub catalog
- `subscription.installPlanApproval` — default `Automatic`
- Remove keys from the source that have no equivalent in the new chart
- Add keys for CRDs or config resources specific to the new chart, documented with inline comments

### Step 7 — Publish to docs

After the chart directory is ready, propagate it to the documentation tree.

#### 7a — Copy the logo

Copy the SVG icon from the source chart and rename it for the new chart:

```bash
cp docs/img/<source>.svg docs/img/<family>-<short-name>.svg
```

All logos live in `docs/img/` and are SVG files (not PNG). The icon path in `Chart.yaml` must match:
```yaml
icon: https://helm-repository.readthedocs.io/en/latest/img/<family>-<short-name>.svg
```

#### 7b — Copy the README to docs

```bash
cp charts/<family>-<short-name>/README.md docs/charts/<family>-<short-name>.md
```

The file in `docs/charts/` is the rendered documentation page. It must be identical to the chart `README.md`.

#### 7c — Add the chart to docs/index.md

Open `docs/index.md` and insert a new row in the table of the appropriate chart family. Insert it **after** the alphabetically closest existing entry in the same family block. The row format is:

```markdown
| **[<family>-<short-name>](charts/<family>-<short-name>.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/<family>-<short-name>) | <one-line description matching Chart.yaml description> |
```

Use consistent column padding to match surrounding rows.

### Step 8 — Report (no commit)

After all changes are made, output a structured summary:

```
## New chart: <family>-<short-name>

**Source chart used**: <source>
**Directory created**: charts/<family>-<short-name>/

### Files modified
- Chart.yaml — name, description, appVersion, annotations updated
- README.md — title, description, history table reset
- values.yaml — channel, source, name, namespace scope updated
- docs/img/<family>-<short-name>.svg — logo copied from source
- docs/charts/<family>-<short-name>.md — README published to docs
- docs/index.md — new row added in <family> table

### Templates
- Kept: <list>
- Removed: <list>
- Added: <list>

### TODOs before first release
- [ ] Verify appVersion matches actual upstream release
- [ ] Confirm subscription.channel is the current stable channel
- [ ] Test `helm install` with the generated values
- [ ] Update values.schema.json to reflect new keys
- [ ] Replace docs/img/<family>-<short-name>.svg with a dedicated icon
```

Do **not** run `git add` or `git commit`.

## Commit convention

No mandatory signature defined for this project (unlike go-libs). Use conventional commits:
```
[chart/<name>] <verb>: <description>
[docs] <description>
```

## Copyright

GPL-3.0-or-later (see `artifacthub.io/license` in Chart.yaml). Maintainer: dev@startx.fr

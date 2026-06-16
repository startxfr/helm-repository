# helm-repository — CLAUDE.md

**Language**: English only. Never French or any other language in code, comments, commits, or docs.

## Overview

`github.com/startxfr/helm-repository` — Helm chart repository for Openshift/Kubernetes, published on GitHub Pages, ReadTheDocs (helm-repository.readthedocs.io) and ArtifactHub.

Three remotes: `origin` (GitHub), `gitlab` (GitLab), `monaco` (AWS CodeCommit).

## Chart families

| Prefix      | Role                                                                            |
| ----------- | ------------------------------------------------------------------------------- |
| `chaos-*`   | Chaos testing tools (cerberus, kraken, litmus, mesh, monkey) + umbrella `chaos` |
| `cluster-*` | Cluster-level configuration via Openshift operators                             |
| `example-*` | Demo / tutorial deployments                                                     |
| `operator`  | Generic operator subscription chart                                             |
| `project`   | Base chart: project/namespace + RBAC + NetworkPolicy + Quotas + LimitRange      |
| `sxapi`     | Micro-service deployment based on the sxapi nodejs engine                       |

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
- `description`: single English sentence, must match README intro; never a placeholder or a copy from another chart
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
more information on how to use these resources.

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster
### 2. Install the repository
### 3. Get information about this chart
### 4. Install this chart
#### Default values            ← bullet-list of what gets deployed, then `helm install` command
#### Other available values    ← one entry per values-*.yaml file

## Values dictionary           ← chaos/example/basic charts only
### context values dictionary
### <feature> values dictionary

## Default values              ← cluster-* charts: inline under ### 4. Install this chart

## History

| Release | Date       | Description |
| ------- | ---------- | ----------- |
| x.y.z   | YYYY-MM-DD | Description |
```

**All history table rows must end with a trailing `|`** — rows without it break Markdown table rendering.

## values.yaml rules

- First line: `# Default values for <chart-name>.`
- Second line: blank
- Third line: `# Application deployment context`
- `context:` is always the first key, with an inline comment on every sub-key
- Every top-level key must have at least one `# comment` line immediately above it
- Commented-out examples use `# # Comment` (double `#`) or `# - key: value` style
- `nameOverride` and `versionOverride` appear commented at the top in `chaos-*` and `example-*` charts only
- **No French words** in comments

## Recurring misspellings — fix on sight

| Wrong                      | Correct                  |
| -------------------------- | ------------------------ |
| `theses resources`         | `these resources`        |
| `environement`             | `environment`            |
| `plateform`                | `platform`               |
| `ressource`                | `resource`               |
| `functionnal`              | `functional`             |
| `organisational`           | `organizational`         |
| `recommandations`          | `recommendations`        |
| `depedencies`              | `dependencies`           |
| `personnalized`            | `personalized`           |
| `lest than`                | `less than`              |
| `graphana`                 | `grafana`                |
| `projet`                   | `project`                |
| `helm_reposistory`         | `helm_repository`        |
| `Others values availables` | `Other available values` |

## Known issues — fix when touching a chart

### Wrong `context.app` default in README value tables

Must match the chart name, not `sxapi`. Charts affected: `chaos-*`, `cluster-vault`, `cluster-vault-config`, `example-deployment`, `example-chaos`, `example-imagestreams`, `example-catalog`, `example-pod`, `example-fruitapp-*`.

### Stale copy-paste in Chart.yaml descriptions

| Chart              | Wrong description                    | Correct description                                  |
| ------------------ | ------------------------------------ | ---------------------------------------------------- |
| `cluster-acs`      | "configure Advanced Cluster Manager" | "configure Advanced Cluster Security (ACS/Stackrox)" |
| `cluster-kubevirt` | "configure Code Ready Workspace"     | "configure KubeVirt and OpenShift Virtualization"    |
| `cluster-logging`  | "configure Metering"                 | "configure Logging (cluster-logging operator)"       |

### README placeholders not yet filled

- `description` still `"This helm chart must have a description"`: `cluster-acm`, `cluster-acs`
- `## Default values` body still `"xxxx to do xxxxxx"`: `cluster-console`, `cluster-knative`, `cluster-kubevirt`, `cluster-localstorage`, `cluster-logging`, `cluster-mustgather`, `cluster-oadp` *(partial)*, `cluster-odf`, `cluster-ods`, `cluster-storage-efs`

### Duplicate history rows (same release and date twice)

- `cluster-certmanager` (11.7.18), `cluster-nfd` (11.7.18), `cluster-crunchy` (11.28.68)
- `project` (0.3.155, 0.3.189, 0.3.217, 7.22.27)

## New chart creation procedure

When asked to create a new chart, follow these steps in order.

### Step 1 — Gather inputs

Ask for these three pieces of information before doing anything:

| #   | Question                                                              | Example                                                                     |
| --- | --------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| 1   | **Chart family** — `example`, `cluster`, or `chaos`?                  | `cluster`                                                                   |
| 2   | **Short name** — lowercase, no prefix                                 | `nmstate`                                                                   |
| 3   | **Description** — one English sentence describing what the chart does | `"configure NMState network operator for node-level network configuration"` |

The full chart name is `<family>-<short-name>` (e.g. `cluster-nmstate`).

### Step 2 — Find the closest existing chart

Search `charts/` for a chart from the same family that deploys a similar resource type (operator subscription, CRD, console plugin, etc.). Present 2–3 candidates ranked by relevance and ask the user to confirm the source.

Guidance by family:
- `cluster-*` operator → prefer `cluster-nfd`, `cluster-certmanager`, or `cluster-pipeline`
- `cluster-*` with Console Plugin → prefer a chart that already has a `consoleplugin.yaml` template
- `example-*` → prefer the closest `example-*` by resource type
- `chaos-*` → prefer an existing `chaos-*` chart

### Step 3 — Copy and rename

```bash
cp -r charts/<source> charts/<family>-<short-name>
```

### Step 4 — Update Chart.yaml and README.md

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

### Step 5 — Clean up templates

- Always keep: `_helpers.tpl`, `_startx.tpl`, `NOTES.txt`
- Update all template `define` names from `<source>.*` to `<family>-<short-name>.*`
- For `cluster-*` operator charts: keep `subscription.yaml`, `operatorgroup.yaml`; add `consoleplugin.yaml` if the operator ships one
- Remove any template referencing a resource type irrelevant to the new chart
- Copy missing templates from the most similar chart that has them

### Step 6 — Adjust values.yaml

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

### Step 7 — Publish to docs

#### 7a — Copy the logo

```bash
cp docs/img/<source>.svg docs/img/<family>-<short-name>.svg
```

All logos are SVG files in `docs/img/`. The `icon:` path in `Chart.yaml` must reference this file.

#### 7b — Publish README to docs

```bash
cp charts/<family>-<short-name>/README.md docs/charts/<family>-<short-name>.md
```

The file in `docs/charts/` must be identical to the chart `README.md`.

#### 7c — Register in docs/index.md

Insert a new row in the appropriate family table, after the alphabetically closest existing entry:

```markdown
| **[<family>-<short-name>](charts/<family>-<short-name>.md)** | [source](https://github.com/startxfr/helm-repository/tree/master/charts/<family>-<short-name>) | <description matching Chart.yaml> |
```

Match the column padding of surrounding rows.

### Step 8 — Report (no commit)

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

## Tooling architecture

The repository ships a CLI (`sx-helm`) and a Makefile that wraps it for CI/CD and developer convenience.

```
sx-helm              ← main entrypoint, bash script, routes to functions in .tools/
.tools/config        ← shared configuration (sourced by cli AND included by Makefile)
.tools/cli           ← chart operations (lint, test, package, release, publish, delete …)
.tools/cli-s3        ← AWS S3 sync helpers (upload/download/delete)
```

**Never edit hardcoded values inside `.tools/cli` or `sx-helm` directly.** All tunables live in `.tools/config`.

### .tools/config

Sourced by `.tools/cli` at startup and included by the `Makefile` via `include .tools/config`. Contains:

| Variable | Purpose |
| -------- | ------- |
| `STABLE_MAINRELEASE` / `STABLE_SUBRELEASE` | Current OCP release cycle numbers |
| `WORK_BRANCH` / `MASTER_BRANCH` / `STABLE_BRANCH` | Git branch names |
| `GITHUB_REPONAME` / `GITLAB_REPONAME` | Remote names (`origin` / `gitlab`) |
| `HELM_REPO_AWSBUCKET` / `HELM_REPO_AWSDC` | S3 bucket and region |
| `HELM_REPO_BASEURL` | Public S3 website URL |
| `SXHELM_SIGN` / `SXHELM_SIGN_KEY` / `SXHELM_SIGN_KEYRING` | GPG signing settings |
| `SXHELM_SIGN_KEYPASSPHRASEFILE` | Path to GPG passphrase file |
| `DOC_ADD_HISTORY` | `"true"` to auto-append history rows on release |

### sx-helm command routing

```
sx-helm list                          routerList
sx-helm version                       routerVersion
sx-helm publish                       routerPublish
sx-helm release [auto|-a]             routerRelease
sx-helm archive                       routerArchive
sx-helm archiveLegacy                 routerArchiveLegacy
sx-helm lint-all                      routerLintAll
sx-helm test-all                      routerTestAll
sx-helm package-all                   routerPackageAll
sx-helm syncfroms3                    routerSyncFromS3
sx-helm synctos3                      routerSyncToS3

sx-helm <chart> info                  routerChartInfo
sx-helm <chart> create [version]      routerChartCreate
sx-helm <chart> schemagen             routerChartSchemagen
sx-helm <chart> test                  routerChartTest
sx-helm <chart> package               routerChartPackage
sx-helm <chart> release [ver] [desc]  routerChartRelease
sx-helm <chart> delete                routerChartDelete
sx-helm <chart> publish               routerChartPublish
```

### Environment variables (cli)

| Variable | Default | Purpose |
| -------- | ------- | ------- |
| `INTERACTIVE` | `true` | Set to `false` to skip all `read -r` prompts (mandatory in CI) |
| `VERSION` | `""` | Force a specific version instead of auto-increment |
| `DESC` | `""` | Force a release description instead of prompting |
| `FORCE_DELETE` | `""` | Set to `yes` to skip delete confirmation |

The `INTERACTIVE` guard pattern used throughout `.tools/cli`:
```bash
if [[ "$INTERACTIVE" != "true" ]]; then
    # use $VERSION / $DESC / defaults directly
else
    read -r ...
fi
```

### Makefile usage

The `Makefile` wraps `sx-helm` for CI/CD. It sets `INTERACTIVE=false` by default and translates `make <action> CHART=<name>` → `$(SX) <name> <action>`.

```bash
make help
make list
make version
make info        CHART=cluster-nmstate
make lint        CHART=cluster-nmstate
make lint-all
make test        CHART=cluster-nmstate
make test-all
make schema      CHART=cluster-nmstate
make package     CHART=cluster-nmstate
make package-all
make release     CHART=cluster-nmstate [VERSION=21.3.5] [DESC="fix schema"]
make release-all                       [VERSION=21.3.5] [DESC="stable update"]
make publish
make publish-chart CHART=cluster-nmstate
make archive
make archive-legacy
make sync-pull                         # S3 → local .reposync
make sync-push                         # local .reposync → S3 (with --delete)
make delete      CHART=cluster-nmstate [FORCE_DELETE=yes]
```

Targets that require `CHART=` are protected by the `_require-chart` guard, which prints a usage hint and exits 1.

### Release workflow (single chart)

1. `make release CHART=<name> VERSION=<x.y.z> DESC="<one line>"`  
   — bumps `Chart.yaml` version, appends a history row, signs and packages, uploads to S3.
2. `make publish` — regenerates the Helm index for stable/noschema/current repos and syncs to S3.
3. Commit and push (`devel` → `master` → `stable` → tag).

Auto-increment (no `VERSION=`): patch number is incremented via `chartNextVersion` (awk semver bump in `.tools/cli`).

### S3 sync (cli-s3)

Two safe operations available via the Makefile:

| Target | Function | Direction | `--delete`? |
| ------ | -------- | --------- | ----------- |
| `sync-pull` | `awsS3SyncDownload` | S3 → local | No |
| `sync-push` | `awsS3SyncUploadDelete` | local → S3 | **Yes** |

`sync-push` deletes remote files not present locally — use with care. Always `sync-pull` first.

The low-level `awsS3SyncDownloadDelete` function (local delete on pull) exists but is **not exposed** via any router — it would delete local files not on S3.

---

## Chaos chart specifics

### Tool identity (do not mix up)

| Chart | Tool | Role |
| ----- | ---- | ---- |
| `chaos-cerberus` | Cerberus | Watchdog — global cluster health check via API |
| `chaos-kraken` | Kraken | Chaos engine — injects scenarios (node stop, pod kill, network partition…) |
| `chaos-litmus` | Litmus | Chaos engineering platform — portal + workflows + scheduler |
| `chaos-mesh` | Chaos Mesh | GUI-driven chaos engine — PodChaos, NetworkChaos, TimeChaos CRs |
| `chaos-monkey` | Kube-monkey | Random pod terminator — opt-in via Deployment labels during business hours |

Descriptions that have appeared wrongly as "watchdog who act as a global cluster healthcheck" for litmus, mesh, and monkey — fix on sight.

### README ## Usage examples section

Every chaos chart README must have a `## Usage examples` section after the values dictionary and before `## History`. Each example block uses:

```markdown
### Example title

Short sentence of what this deploys.

\```bash
helm install <release> startx/<chart> \
  --set context.scope=myscope \
  --set <key>=<value>
\```
```

Minimum three examples per chaos chart: (1) default / full stack, (2) minimal, (3) integration or advanced scenario.

---

## Commit convention

No mandatory signature for this project. Use conventional commits:

```
[chart/<name>] <verb>: <description>
[docs] <description>
```

## Copyright

GPL-3.0-or-later (see `artifacthub.io/license` in Chart.yaml). Maintainer: dev@startx.fr

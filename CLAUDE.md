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

## Known issues

See [`.claude/KNOWN_ISSUES.md`](.claude/KNOWN_ISSUES.md) for the full list of recurring bugs to fix when touching a chart.

## New chart creation

Use the `/new-chart <family>-<short-name>` skill — it guides through all 8 steps (gather inputs, find source, copy, update Chart.yaml + README, clean templates, adjust values, publish to docs, report).

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
| `HELM_REPO_SUBDEV` | S3 sub-path for the pre-release devel repo (default: `"devel"`) |
| `HELM_REPO_ARCHIVE_RELEASES` | Space-separated OCP minor release numbers for `sx-helm archive` / `make archive` |
| `HELM_REPO_LEGACY_RELEASES` | Space-separated OCP minor release numbers for `sx-helm archiveLegacy` / `make archive-legacy` |

### S3 sub-repos

| Sub-repo path | Purpose | Populated by |
|---|---|---|
| `devel` | Pre-release charts from `devel` branch | `make publish-devel` / `/release-chart` / `/release-devel` |
| `stable` | Production stable charts | `make publish` |
| `noschema` | Same as stable, no schema validation | `make publish` |
| `release-<N>` | Charts for OCP minor release N (current = `STABLE_MAINRELEASE`) | `make publish` |
| `release-<N>` (archive) | Archived OCP releases from `HELM_REPO_ARCHIVE_RELEASES` | `make archive` |
| `release-<N>` (legacy) | Legacy OCP releases from `HELM_REPO_LEGACY_RELEASES` | `make archive-legacy` |

Each sub-repo has a matching `docs/repos/<path>/index.yaml` committed in git.

### sx-helm command routing

```
sx-helm list                          routerList
sx-helm version                       routerVersion
sx-helm publish                       routerPublish          — stable+noschema+release-XX
sx-helm publish-devel                 routerPublishDevel     — devel sub-repo only
sx-helm release [auto|-a]             routerRelease          — full flow: bump+merge+tag+push
sx-helm release-charts                routerReleaseChartsOnly— bump+package only, no git merge
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
   — bumps `Chart.yaml` version, replaces all `targetRevision: *` in `README.md`, appends a history row, syncs README to `docs/charts/<name>.md`, signs and packages, uploads `.tgz`+`.prov` to **both** `.reposync/stable/` and `.reposync/<STABLE_MAINRELEASE>/`, and uploads both to S3.
2. `make publish` — regenerates the Helm index for stable/noschema/current repos and syncs to S3.
3. Commit and push (`devel` → `master` → `stable` → tag).

Auto-increment (no `VERSION=`): patch number is incremented via `chartNextVersion` (awk semver bump in `.tools/cli`).

**Dual S3 copy**: `routerChartRelease` places every new package into `.reposync/stable/` (primary) **and** `.reposync/$STABLE_MAINRELEASE/` (current release sub-repo). Both are uploaded to S3 immediately. This keeps the `stable` and `release-N` Helm repos in sync after each individual chart release without waiting for `make publish`.

### S3 sync (cli-s3)

Two safe operations available via the Makefile:

| Target | Function | Direction | `--delete`? |
| ------ | -------- | --------- | ----------- |
| `sync-pull` | `awsS3SyncDownload` | S3 → local | No |
| `sync-push` | `awsS3SyncUploadDelete` | local → S3 | **Yes** |

`sync-push` deletes remote files not present locally — use with care. Always `sync-pull` first.

The low-level `awsS3SyncDownloadDelete` function (local delete on pull) exists but is **not exposed** via any router — it would delete local files not on S3.

---

## Slash commands (skills)

Slash commands are defined in `.claude/commands/`. Invoke them with `/command-name [args]`.

### Release workflow — staged pipeline

The recommended release flow runs in 4 ordered stages, each a separate skill:

```
devel (version bump)
  │
  ├─ /release-chart <name>    — single chart: bump + S3 upload + publish-devel
  │
  └─ /release-devel           — all charts: bump + S3 upload + publish-devel
       │
       └─ /release-master     — merge devel→master + publish + propagate master-4.x
            │
            └─ /release-stable — merge master→stable + publish + propagate stable-4.x + tag
```

| Skill | Command | What it does |
|-------|---------|--------------|
| `/release-chart` | `/release-chart <name> [version] [desc]` | Single chart: bump, package, upload to S3, publish devel repo, push devel |
| `/release-devel` | `/release-devel [version] [desc]` | All charts on devel: bump all, package all, publish devel repo, push devel |
| `/release-master` | `/release-master` | Merge devel→master, publish stable repos, propagate to master-4.x, push |
| `/release-stable` | `/release-stable` | Merge master→stable, publish stable repos, propagate to stable-4.x, tag, push |
| `/new-major-release` | `/new-major-release <N>` | Init OCP major release N: update config, create docs/repos/N/, merge to master |

### Key distinctions

- `release-charts` (make target / `routerReleaseChartsOnly`) bumps all chart versions **without** merging branches or creating tags — safe to run on devel multiple times
- `release-all` (make target / `routerRelease`) does the **full** flow: bumps + merges devel→master→stable + tags + pushes — use only for direct one-shot releases
- `publish` regenerates `stable`, `noschema`, `release-<N>` S3 repos
- `publish-devel` regenerates only the `devel` S3 pre-release repo

---

## ArgoCD deployment pattern (cluster-* charts)

Every `cluster-*` chart README must include a `## Deploy via ArgoCD` section with **one AppProject + three Applications**: `cluster-xxx-project`, `cluster-xxx-operator`, `cluster-xxx-app`.

### Namespace naming rules

| Situation | Operator namespace | Instance namespace |
|---|---|---|
| Operator gets its own namespace | `openshift-xxx-operator` | `startx-xxx` |
| Operator runs in `openshift-operators` (no dedicated NS) | `startx-xxx-operator` | `startx-xxx` |

### Application split

| Application | `helm.values` enabled flags | Destination namespace | syncPolicy |
|---|---|---|---|
| `cluster-xxx-project` | `project.enabled: true` + all others `false` | `openshift-xxx-operator` | `CreateNamespace=true` |
| `cluster-xxx-operator` | `operator.enabled: true` + all others `false` | `openshift-xxx-operator` | — |
| `cluster-xxx-app` | `<feature>.enabled: true` + all others `false` | `startx-xxx` | `CreateNamespace=true` |

**Critical**: explicitly set all non-relevant sub-chart enabled flags to `false` in every Application's `helm.values`. Omitting them causes ArgoCD `SharedResourceWarning` when the default values.yaml enables multiple sub-charts.

### ArgoCD AppProject clusterResourceWhitelist

Minimum required cluster-scoped resources: `Namespace`, `OperatorGroup`, `Subscription`, and the operator's CRD kind (e.g. `MustGather.redhatcop.redhat.io`, `Kubecost.charts.kubecost.com`, `MultiClusterHub.operator.open-cluster-management.io`).

### Cascade-delete finalizer

All Applications must carry:
```yaml
finalizers:
  - resources-finalizer.argocd.argoproj.io
```

### SharedResourceWarning fix

When multiple Applications claim the same resource (e.g. a Namespace created by project sub-chart but also referenced by operator sub-chart), add explicit `enabled: false` for each sub-chart that should not deploy it:
```yaml
helm:
  values: |
    project:
      enabled: false
    operator:
      enabled: true
```

### known issues / OLM drift

- OperatorGroup gets extra annotations from OLM after creation → ArgoCD shows OutOfSync on OperatorGroup — this is **expected/normal**, do not try to fix it.
- `additionalLabels` defined as a YAML map in values.yaml causes `wrong type for value; expected string; got map` in namespace templates — override with `additionalLabels: ""` in the Application helm values.
- For operators deploying in `openshift-operators` (shared namespace): `global-operators` OperatorGroup already exists — set `operator.operatorGroup.enabled: false` in the `cluster-xxx-operator` Application to avoid OLM conflict (two OGs block CSV resolution entirely).

### Charts with ArgoCD examples (done)

 `cluster-nexus` · `cluster-nfd` · `cluster-nmstate` · `cluster-3scale` · `cluster-kubecost` · `cluster-mustgather` · `cluster-acm` · `cluster-acs` · `cluster-ansible` · `cluster-argocd` · `cluster-auth` · `cluster-certmanager` · `cluster-compliance` · `cluster-config` · `cluster-console` · `cluster-costs` · `cluster-couchbase` · `cluster-crunchy` · `cluster-descheduler` · `cluster-devworkspaces` · `cluster-dvo` · `cluster-gitlab` · `cluster-gpu` · `cluster-istio` · `cluster-kafka` · `cluster-kargo` · `cluster-kepler` · `cluster-knative`

### Charts pending ArgoCD examples

`cluster-mongo`, `cluster-kubevirt`, `cluster-localstorage`, `cluster-logging`, `cluster-machine`, `cluster-maintenance`, `cluster-mtc`, `cluster-mtr`, `cluster-mtv`, `cluster-oadp`, `cluster-odf`, `cluster-ods`, `cluster-pipeline`, `cluster-ptp`, `cluster-quay`, `cluster-rbac`, `cluster-redis`, `cluster-router`, `cluster-sso`, `cluster-storage`, `cluster-storage-efs`, `cluster-vault`, `cluster-vault-config`, `cluster-vpa`

### Atomic update process per chart

For each chart to update, do these steps in order:
1. Update `appVersion` in `Chart.yaml` to current upstream operator version
2. Update version, channel, namespace names in `values.yaml` (and all `values-startx*.yaml`)
3. Add `## ArgoCD deployment` section to `README.md` with AppProject + 3 Applications, then `cp README.md docs/charts/<name>.md`
4. Ask for approval, then run `./sx-helm <chart-name> release && ./sx-helm publish` — **this publishes the chart to S3 and updates the index**
5. Deploy the 3 ArgoCD Applications on the test cluster using the **newly published version** (`targetRevision` set by auto-update in release)
6. Verify sync succeeds; adjust values/templates if needed, then re-release if needed
7. Update CLAUDE.md charts-done list

**IMPORTANT:** Never test on the cluster with an old indexed version (e.g. 21.3.0). Always release first so the actual updated chart is available in the S3 index.

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

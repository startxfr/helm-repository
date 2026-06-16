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

## Commit convention

No mandatory signature defined for this project (unlike go-libs). Use conventional commits:
```
[chart/<name>] <verb>: <description>
[docs] <description>
```

## Copyright

GPL-3.0-or-later (see `artifacthub.io/license` in Chart.yaml). Maintainer: dev@startx.fr

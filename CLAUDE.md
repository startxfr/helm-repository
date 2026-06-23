# helm-repository - CLAUDE.md

**Language**: English only. Never French in code, comments, commits, or docs.

## Overview

`github.com/startxfr/helm-repository` — Helm chart repository for Openshift/Kubernetes. Three remotes: `origin` (GitHub), `gitlab` (GitLab), `monaco` (AWS CodeCommit).

| Prefix | Role |
|--------|------|
| `chaos-*` | Chaos testing tools (cerberus, kraken, litmus, mesh, monkey) + umbrella `chaos` |
| `cluster-*` | Cluster-level configuration via Openshift operators |
| `example-*` | Demo / tutorial deployments |
| `operator` | Generic operator subscription chart |
| `project` | Base chart: namespace + RBAC + NetworkPolicy + Quotas + LimitRange |
| `sxapi` | Micro-service deployment based on the sxapi nodejs engine |

## Chart structure

```
charts/<name>/
  Chart.yaml · values.yaml · values.schema.json · README.md · .helmignore
  templates/_helpers.tpl · _startx.tpl · NOTES.txt · *.yaml
```

**Chart.yaml rules**: `type: application`; `version` aligned to OCP (`MAJOR.MINOR.PATCH`); `appVersion` = upstream version; `kubeVersion` always set; `annotations.artifacthub.io/changes` updated each release; `prerelease: "true"/"false"`.

**values.yaml rules**: First line `# Default values for <chart>.`; `context:` always first key; every top-level key has a comment; no French words.

**README.md sections (in order)**: title+badge → description → Requirements → Deploy on openshift (Connect/Install repo/Get info/Install) → Default values → Other values → ArgoCD deployment → History.  
All history table rows must end with trailing `|`.

## Recurring misspellings — fix on sight

`theses resources` → `these resources` · `environement` → `environment` · `plateform` → `platform` · `ressource` → `resource` · `functionnal` → `functional` · `organisational` → `organizational` · `recommandations` → `recommendations` · `Others values availables` → `Other available values` · `graphana` → `grafana` · `projet` → `project`

## Tooling

```
sx-helm              ← main entrypoint, bash, routes to .tools/
.tools/config        ← shared config (sourced by cli AND included by Makefile)
.tools/cli           ← chart operations
.tools/cli-s3        ← AWS S3 sync helpers
```

Never edit hardcoded values inside `.tools/cli` or `sx-helm`; all tunables are in `.tools/config`.

### Key .tools/config variables

`STABLE_MAINRELEASE` / `STABLE_SUBRELEASE` · `WORK_BRANCH` / `MASTER_BRANCH` / `STABLE_BRANCH` · `HELM_REPO_AWSBUCKET` / `HELM_REPO_AWSDC` · `HELM_REPO_BASEURL` · `DOC_ADD_HISTORY` · `HELM_REPO_ARCHIVE_RELEASES` / `HELM_REPO_LEGACY_RELEASES`

### S3 sub-repos

| Path | Purpose | Populated by |
|------|---------|-------------|
| `devel` | Pre-release from devel branch | `make publish-devel` / `/release-chart` / `/release-devel` |
| `stable` | Production stable | `make publish` |
| `noschema` | Stable, no schema validation | `make publish` |
| `release-<N>` | Charts for OCP minor release N | `make publish` / `make archive` |

### Makefile usage

```bash
make release   CHART=cluster-nmstate [VERSION=21.3.5] [DESC="fix"]
make release-all                     [VERSION=21.3.5] [DESC="stable update"]
make publish        # regenerates stable/noschema/release-N S3 repos
make publish-chart  CHART=cluster-nmstate
make lint/test/schema/package  CHART=cluster-nmstate
make lint-all / test-all / package-all
make archive / archive-legacy
make sync-pull  # S3 → local .reposync
make sync-push  # local .reposync → S3 (--delete, use with care)
make delete     CHART=cluster-nmstate [FORCE_DELETE=yes]
```

`INTERACTIVE=false` by default in Makefile. `sync-push` deletes remote files not present locally — always `sync-pull` first.

### Release flow (single chart)

1. `make release CHART=<name>` — bumps Chart.yaml, replaces `targetRevision` in README, appends history row, syncs to `docs/charts/`, signs, packages, uploads `.tgz`+`.prov` to `.reposync/stable/` **and** `.reposync/$STABLE_MAINRELEASE/`, uploads to S3.
2. `make publish` — regenerates Helm index for stable/noschema/current repos, syncs to S3.
3. Commit and push (`devel` → `master` → `stable` → tag).

**Dual S3 copy**: every package lands in both `stable/` and `release-N/` immediately after `make release`.

### Environment variables (cli)

| Variable | Default | Purpose |
|----------|---------|---------|
| `INTERACTIVE` | `true` | `false` = skip `read -r` prompts (mandatory in CI) |
| `VERSION` | `""` | Force specific version instead of auto-increment |
| `DESC` | `""` | Force release description |
| `FORCE_DELETE` | `""` | `yes` = skip delete confirmation |

---

## Slash commands (skills)

Defined in `.claude/commands/`. Staged release pipeline:

```
devel → /release-chart <name>  (single chart: bump + S3 + publish-devel)
      → /release-devel         (all charts: bump + S3 + publish-devel)
           → /release-master   (merge devel→master + publish + propagate master-4.x)
                → /release-stable (merge master→stable + publish + propagate stable-4.x + tag)
```

| Skill | Args | What it does |
|-------|------|-------------|
| `/release-chart` | `<name> [ver] [desc]` | Single chart: bump, package, upload S3, publish devel, push devel |
| `/release-devel` | `[ver] [desc]` | All charts on devel: bump, package, publish devel, push devel |
| `/release-master` | — | Merge devel→master, publish stable repos, propagate master-4.x, push |
| `/release-stable` | — | Merge master→stable, publish, propagate stable-4.x, tag, push |
| `/new-major-release` | `<N>` | Init OCP major release N: update config, create docs/repos/N/, merge to master |
| `/new-chart` | `<family>-<name>` | New chart: gather inputs, copy, update Chart.yaml+README, clean templates, adjust values, publish |

- `release-charts` (make target) = bump all versions **without** merging/tagging — safe to run multiple times on devel
- `release-all` (make target) = full flow: bumps + merges devel→master→stable + tags + pushes

---

## ArgoCD deployment pattern (cluster-* charts)

Every `cluster-*` README must have a `## Deploy via ArgoCD` section with **one AppProject + three Applications**.

### Operator namespace naming rules (standardized 2026-06)

| Operator catalog / install mode | Operator namespace | Instance namespace |
|--------------------------------|-------------------|-------------------|
| `redhat-operators` (any mode) | chart-specific (e.g. `openshift-storage`) | chart-specific |
| Community/certified — **AllNamespaces** | `openshift-operators` (no dedicated NS, no OG) | `default-xxx` |
| Community/certified — **OwnNamespace** | `default-xxx` (OG enabled, no `target:`) | `default-xxx` |
| Community/certified — **SingleNamespace** | `openshift-xxx-operator` (OG watching `default-xxx`) | `default-xxx` |

Applied namespaces per chart:
- `cluster-redis` → `default-redis` (OwnNamespace), EE variant → `default-redis-ee`
- `cluster-crunchy` → `default-crunchy` (OwnNamespace)
- `cluster-couchbase` → `default-couchbase` (OwnNamespace, `target:` removed)
- `cluster-mongo` → `default-mongo` (OwnNamespace)
- `cluster-nexus` → `default-nexus` (OwnNamespace)
- `cluster-kubecost` → `default-kubecost` (OwnNamespace)
- `cluster-vault-config` → `default-vault-config` (OwnNamespace, OG enabled)
- `cluster-config/sosreport` → `default-sosreport` (OwnNamespace, `target:` removed)
- `cluster-dvo` → `openshift-operators` (AllNamespaces, OG disabled, project.enabled=false)
- `cluster-mustgather` → `openshift-operators` (AllNamespaces, OG disabled, project.enabled=false)
- `cluster-gpu` → `nvidia-gpu-operator` (AllNamespaces dedicated, OG `all-ns`)

### Application split

| Application | Wave | Enabled flags | Destination |
|-------------|------|--------------|-------------|
| `cluster-xxx-project` | `"1"` | `project.enabled: true`, all others `false` | operator/instance namespace |
| `cluster-xxx-operator` | `"5"` | `operator.enabled: true`, all others `false` | operator namespace |
| `cluster-xxx-app` | `"10"` | `<feature>.enabled: true`, all others `false` | instance namespace |

**Critical**: explicitly set all non-relevant flags to `false` in every Application's `helm.values`. Omitting causes `SharedResourceWarning`.

For AllNamespaces operators in `openshift-operators`: set `project.enabled: false` (no project wave needed), `operator.operatorGroup.enabled: false` (global OG already exists).

### Finalizers

- `-operator` and `-app` Applications: add `resources-finalizer.argocd.argoproj.io`
- `-project` Application: **no finalizer** (deadlock risk when namespace is slow to terminate)

**Deletion order**: `-app` first → CR cleanup → `-operator` → `-project`. Never delete operator before CRs (finalizer handler disappears → namespace stuck Terminating).

### ignoreDifferences — common patterns

```yaml
# CR finalizers (all operators add these post-creation)
ignoreDifferences:
  - group: <operator-api-group>
    kind: <CR-kind>
    jsonPointers:
      - /metadata/finalizers
```

ODF StorageCluster (extended — operator mutates many fields):
```yaml
ignoreDifferences:
  - group: ocs.openshift.io
    kind: StorageCluster
    jqPathExpressions:
      - .metadata.finalizers
      - .metadata.annotations["uninstall.ocs.openshift.io/cleanup-policy"]
      - .metadata.annotations["uninstall.ocs.openshift.io/mode"]
      - .spec.version
      - .spec.encryption.keyRotation
      - .spec.managedResources
      - .spec.storageDeviceSets[].replica
```

ODF OperatorGroup (OLM mutates after install, on `-operator` Application):
```yaml
ignoreDifferences:
  - group: operators.coreos.com
    kind: OperatorGroup
    name: openshift-storage
    namespace: openshift-storage
    jsonPointers:
      - /metadata/annotations/olm.providedAPIs
      - /spec/upgradeStrategy
  - group: console.openshift.io
    kind: ConsolePlugin
    name: odf-console
    jqPathExpressions:
      - .spec
      - .metadata.annotations
      - .metadata.labels
```

| Chart | group | kind |
|-------|-------|------|
| cluster-odf | `ocs.openshift.io` | `StorageCluster` |
| cluster-mtv | `forklift.konveyor.io` | `ForkliftController` |
| cluster-acm | `operator.open-cluster-management.io` | `MultiClusterHub` |
| cluster-kafka | `kafka.strimzi.io` | `Kafka` |
| cluster-istio | `maistra.io` | `ServiceMeshControlPlane` |
| cluster-logging | `logging.openshift.io` | `ClusterLogging` |
| cluster-sso | `keycloak.org` | `Keycloak` |
| cluster-quay | `quay.redhat.com` | `QuayRegistry` |
| cluster-crunchy | `postgres-operator.crunchydata.com` | `PostgresCluster` |
| cluster-mongo | `mongodbcommunity.mongodb.com` | `MongoDBCommunity` |
| cluster-mustgather | `managed.openshift.io` | `MustGather` |
| cluster-3scale | `apps.3scale.net` | `APIManager` |

### CR template sync-waves

| Resource type | Wave |
|--------------|------|
| Namespace / Project | `-10` |
| OperatorGroup | `-6` |
| Subscription / CSV | `-5` |
| Secrets, RBAC, ServiceAccount | `1` |
| Jobs (e.g. node labeler) | `5` |
| ConsolePlugin | `10` |
| Main CR (StorageCluster, Kafka…) | `15` |
| Secondary CRs (topics, realms…) | `30`–`50` |

Do **not** declare `finalizers` in CR templates — operators manage them.

### Known issues / OLM drift

- OperatorGroup gets extra OLM annotations after creation → ArgoCD OutOfSync on OperatorGroup — **expected, do not fix**.
- `additionalLabels` as YAML map causes `wrong type for value; expected string` in namespace templates → override with `additionalLabels: ""` in Application inline values.
- `vault-config-operator` only supports AllNamespaces → use `openshift-operators` with `operator.operatorGroup.enabled: false`; dedicated OG causes `UnsupportedOperatorGroup` CSV failure.
- `cluster-vault` noinfra: `vault.global.enabled: false` disables ALL vault components → must override `vault.global.enabled: true` in vault-app inline values.
- AppProjects can be pruned by app-of-apps. If `InvalidSpecError: project does not exist`, re-apply AppProject and force-refresh the Application.
- OCP injects `imagePullSecrets`/`secrets` into ServiceAccount `default` → add `ignoreDifferences` on jsonPointers `/imagePullSecrets` and `/secrets` for the project wave Application.
- **Secrets leaking across waves**: when `values-startx_noinfra.yaml` sets `externalComponents.*.enabled: true`, the operator wave must explicitly override each sub-key to `false` (not just the parent `enabled: false`).

### ODF prerequisite — node labeling

```bash
oc label node <node-name> cluster.ocs.openshift.io/openshift-storage='' --overwrite
```

### Emergency cleanup — stuck Terminating namespaces

```bash
# Remove finalizer from stuck CR
oc patch <cr-kind> <cr-name> -n <namespace> \
  --type=json -p '[{"op":"remove","path":"/metadata/finalizers"}]'

# Remove resources-finalizer from stuck Applications
oc get applications.argoproj.io -n openshift-gitops -o json | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
for item in d['items']:
    if item['metadata'].get('deletionTimestamp') and item['metadata'].get('finalizers'):
        print(item['metadata']['name'])
" | xargs -I{} oc patch application.argoproj.io {} -n openshift-gitops \
  --type=json -p '[{"op":"remove","path":"/metadata/finalizers"}]'
```

### Charts with ArgoCD examples (done)

`cluster-nexus` · `cluster-nfd` · `cluster-nmstate` · `cluster-3scale` · `cluster-kubecost` · `cluster-mustgather` · `cluster-acm` · `cluster-acs` · `cluster-ansible` · `cluster-argocd` · `cluster-auth` · `cluster-certmanager` · `cluster-compliance` · `cluster-config` · `cluster-console` · `cluster-costs` · `cluster-couchbase` · `cluster-crunchy` · `cluster-descheduler` · `cluster-devworkspaces` · `cluster-dvo` · `cluster-gitlab` · `cluster-gpu` · `cluster-istio` · `cluster-kafka` · `cluster-kargo` · `cluster-kepler` · `cluster-knative` · `cluster-kubevirt` · `cluster-localstorage` · `cluster-logging` · `cluster-machine` · `cluster-maintenance` · `cluster-mongo` · `cluster-mtc` · `cluster-mtr` · `cluster-mtv` · `cluster-oadp` · `cluster-odf` · `cluster-ods` · `cluster-pipeline` · `cluster-ptp` · `cluster-quay` · `cluster-rbac` · `cluster-redis` · `cluster-router` · `cluster-sso` · `cluster-storage` · `cluster-storage-efs` · `cluster-vault` · `cluster-vault-config` · `cluster-vpa`

### Atomic update process per chart

1. Update `appVersion` in `Chart.yaml`
2. Update version, channel, namespace names in `values.yaml` and all `values-startx*.yaml`
3. Add `## ArgoCD deployment` section to `README.md`; `cp README.md docs/charts/<name>.md`
4. `make release CHART=<name>` then `make publish` — publishes to S3
5. Deploy the 3 ArgoCD Applications on test cluster using the newly published `targetRevision`
6. Verify sync; fix values/templates if needed; re-release if needed
7. Update CLAUDE.md charts-done list

**Never test on cluster with old S3-indexed version — release first.**

---

## cluster-argocd values-app pattern (2026-06)

The `cluster-argocd` chart provides a unified deployment model for all other charts via ArgoCD. Each chart with ArgoCD examples now has a corresponding **`values-app-<chart>.yaml`** file.

### Structure of values-app-*.yaml files

```yaml
argocd_project:
  enabled: false
  list:
    - name: 'infra-<short-name>'  # prefix varies: infra- for cluster-*, chaos- for chaos-*, app- for example-*
      namespace: 'openshift-gitops'
      sourceRepos: [...]
      destinations: [...]
      clusterResourceWhitelist: [...]  # optional

application:
  enabled: false
  list:
    - name: 'infra-<short-name>-project'  # Project wave (no finalizer)
      project: '<original-chart-name>'     # e.g., 'cluster-quay'
      source:
        repo: 'https://gitlab.com/startx1/helm.git'
        chart: '<chart-name>'
        rev: '21.3.x'
      helm: |
        valueFiles:
          - values-app-<chart>.yaml
        parameters:
          - name: context.cluster
            value: "example"
          - name: context.environment
            value: "dev"
          - name: argocd_repocreds.enabled
            value: "true"
          - name: argocd_project.enabled
            value: "true"
          - name: application.enabled
            value: "true"
        values: |
          project:
            enabled: true
    - name: 'infra-<short-name>-operator'  # Operator wave (with finalizer)
      # ... similar structure with operator.enabled: true
    - name: 'infra-<short-name>-app'       # Application wave (with finalizer)
      # ... similar structure with feature flags
```

### Naming conventions

- **AppProject name**: Strip `cluster-`/`example-` prefix, apply type prefix:
  - `cluster-*` → `infra-<name>` (e.g., `cluster-quay` → `infra-quay`)
  - `chaos-*` → `chaos-<name>` (e.g., `chaos-cerberus` → `chaos-cerberus`)
  - `example-*` → `app-<name>` (e.g., `example-sxapi` → `app-sxapi`)
- **Application names**: Same prefixing logic + `-project`/`-operator`/`-app` suffix
- **ValueFiles**: Point to `values-app-<chart>.yaml` for each Application (enables nested deployments)

### Process for new charts

1. Chart gets `## ArgoCD deployment` examples section in README.md
2. Examples extracted to `charts/<name>/examples/argocd/` via `process_argocd.py`
3. **Auto-generate** `values-app-<chart>.yaml` in `charts/cluster-argocd/`:
   ```bash
   python3 /tmp/generate_values_app_v3.py
   # or add manually following the pattern above
   ```
4. **Optional variants** (e.g., security, custom values): `values-app-<chart>-<variant>.yaml`
   - Example: `values-app-cluster-quay-sec.yaml` (uses `values-startx_noinfra-secvuln.yaml` instead of `values-startx_noinfra-quay.yaml`)
5. Add entry to `values-aoa-infra-min.yaml` (or other values files) to test/deploy the chart

### Current coverage (60 charts)

**Generated 2026-06-23**: 60 values-app-*.yaml files covering all charts with ArgoCD examples.
- cluster-* (50 charts)
- chaos-* (4 charts)
- other (operator, project, sxapi) (6 files)

Example-* charts (11 total) have no ArgoCD examples — not included.

---

## Chaos chart specifics

| Chart | Tool | Role |
|-------|------|------|
| `chaos-cerberus` | Cerberus | Watchdog — global cluster health check via API |
| `chaos-kraken` | Kraken | Chaos engine — injects scenarios (node stop, pod kill, network partition…) |
| `chaos-litmus` | Litmus | Chaos engineering platform — portal + workflows + scheduler |
| `chaos-mesh` | Chaos Mesh | GUI-driven chaos engine — PodChaos, NetworkChaos, TimeChaos CRs |
| `chaos-monkey` | Kube-monkey | Random pod terminator — opt-in via Deployment labels during business hours |

Every chaos chart README must have `## Usage examples` (after values dictionary, before History) with minimum 3 examples: (1) default/full stack, (2) minimal, (3) advanced.

---

## Commit convention

No mandatory signature for helm-repository (unlike go-libs). Use:

```
[chart/<name>] <verb>: <description>
[docs] <description>
```

## Copyright

GPL-3.0-or-later. Maintainer: dev@startx.fr

## Known issues reference

See [`.claude/KNOWN_ISSUES.md`](.claude/KNOWN_ISSUES.md) for recurring bugs to fix when touching a chart.

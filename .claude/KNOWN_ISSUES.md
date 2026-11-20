# Known issues - fix when touching a chart

## Wrong `context.app` default in README value tables

Must match the chart name, not `sxapi`. Charts affected: `chaos-*`, `cluster-vault`, `cluster-vault-config`, `example-deployment`, `example-chaos`, `example-imagestreams`, `example-catalog`, `example-pod`, `example-fruitapp-*`.

## Stale copy-paste in Chart.yaml descriptions

| Chart              | Wrong description                    | Correct description                                  |
| ------------------ | ------------------------------------ | ---------------------------------------------------- |
| `cluster-acs`      | "configure Advanced Cluster Manager" | "configure Advanced Cluster Security (ACS/Stackrox)" |
| `cluster-kubevirt` | "configure Code Ready Workspace"     | "configure KubeVirt and OpenShift Virtualization"    |
| `cluster-logging`  | "configure Metering"                 | "configure Logging (cluster-logging operator)"       |

## README placeholders not yet filled

- `description` still `"This helm chart must have a description"`: `cluster-acm`, `cluster-acs`
- `## Default values` body still `"xxxx to do xxxxxx"`: `cluster-console`, `cluster-knative`, `cluster-kubevirt`, `cluster-localstorage`, `cluster-logging`, `cluster-mustgather`, `cluster-oadp` *(partial)*, `cluster-odf`, `cluster-ods`, `cluster-storage-efs`

## Duplicate history rows (same release and date twice)

- `cluster-certmanager` (11.7.18), `cluster-nfd` (11.7.18), `cluster-crunchy` (11.28.68)
- `project` (0.3.155, 0.3.189, 0.3.217, 7.22.27)

## cluster-config / cluster-auth : OpenShift-owned fields

- `cluster-config` `monitoring.externalLabels` : `prometheus`, `prometheus_replica` and `cluster` are reserved by OpenShift
  (webhook `monitoringconfigmaps.openshift.io` fails the sync). The chart emits `cluster_name` and rejects those keys in
  `externalLabels.custom` (helper `cluster-config.monitoring.externalLabels`). Never reintroduce a `cluster` label.
- `cluster-auth` with `manageSubresource: true` writes Secrets in `openshift-authentication` that the authentication
  operator rewrites : the ArgoCD Application needs `ignoreDifferences` on them (see `examples/argocd/`). The `OAuth`
  resource is cluster-scoped : never set a namespace on it.

## unifai : files copied from the UnifAI operator, hand-written schema

- `charts/unifai/crds/*.yaml` and `charts/unifai/files/manager-rules.yaml` are copied from `startxfr/UnifAI`
  (`fork/unifai-operator`, one release tag). Never edit them by hand : run `.tools/sync-unifai-operator.sh <tag>`,
  then report the image digests it prints in `values.yaml` and `Chart.yaml` (`appVersion`, `artifacthub.io/images`).
- `charts/unifai/values.schema.json` is hand-written (descriptions, enums). Do **not** run `make schema CHART=unifai` :
  it overwrites the file with an auto-generated one.
- The chart README deliberately does not follow the repository README layout : it is written for readers who
  only care about UnifAI. Keep `## History` last (the release tooling appends rows at the end of the file).
- Helm does not upgrade the CRDs in `crds/`. When the operator version changes, say so in the release notes
  (`helm show crds ... | kubectl apply --server-side -f -`).
- `cluster-unifai` (packages up to 21.3.362) is deprecated and replaced by `unifai` ; its packages stay published.

## Chart.lock and charts/<chart>/charts/ are generated

Never tracked (root `.gitignore`, ADR-0005). Pins in `Chart.yaml` dependencies are exact, so the lock adds nothing; the release and the CI run `helm dependency update` themselves.
Do not `git add -f` a lock; after changing a pin there is nothing else to commit.

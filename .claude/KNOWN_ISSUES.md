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

## chaos-litmus / chaos-mesh / chaos-monkey : wrappers around upstream charts

- The route and SCC templates must name the Services and ServiceAccounts exactly as the upstream chart does: recompute
  the upstream `fullname` (override, else release name when it contains the name, else `<release>-<name>`); with an
  alias the default name is the alias (`monkey`, `litmus`), not the upstream chart name. Never hardcode a release name.
- `chaos-mesh` generates its certificate authority, its webhook and chaosd certificates and a `rollme` annotation at
  every render (no `lookup`): an ArgoCD Application needs the `ignoreDifferences` of `examples/argocd/` and
  `RespectIgnoreDifferences=true`. Its CRDs are in the upstream `crds/` directory: no `skipCrds`, `ServerSideApply=true`.
- No default credentials, no extra rights (maintainer decision, 2026-11-21): `chaos-litmus` ships no password and
  refuses to render without `existingSecret` or explicit passwords (helper `chaos-litmus.validate`); its example Argo
  `Workflow` is behind `litmus.exampleWorkflow`; `chaos-monkey` only has the ClusterRole of the upstream chart, the
  privileged SCC is behind `monkey.privileged`. Never reintroduce a literal password or a cluster-wide binding.
- Open, waiting for a decision of the maintainer (behaviour changes, do not fix on sight):
  - `chaos-litmus` grants its privileged SCC to nine service accounts of the namespace, `default` included;
  - `chaos-monkey` (`monkey.privileged`), `chaos-litmus` and `chaos-mesh` still create their own copy of a privileged
    SCC; the krkn based charts bind the standard `system:openshift:scc:privileged` ClusterRole instead. Align them;
  - the `chaos-mesh` route keeps `insecureEdgeTerminationPolicy: Allow`;
  - neither `chaos-monkey` with the restricted SCC nor the `chaos-mesh` ArgoCD `ignoreDifferences` were run on a cluster.

## krkn / cerberus images expect a fixed user and a writable working directory

`quay.io/krkn-chaos/krkn`, `krkn-hub` and `cerberus` write in their working directory (`/home/krkn/kraken`, `/root/cerberus`).
Under the OpenShift `restricted-v2` SCC (random UID) this fails with `PermissionError`. The chaos charts copy the
directory to `/tmp` and run from there (`cp -r ... /tmp/...`), with `HOME=/tmp`; krkn-hub is redirected with `ROOT_FOLDER`
and `KRAKEN_FOLDER`. Do not reintroduce a privileged SCC to work around it.
Charts affected: `chaos-cerberus`, `chaos-kraken`, `chaos-pipeline`.

## krkn / cerberus local kubeconfig must embed the token

The kubernetes python client used by cerberus (and krkn-lib) does not read `tokenFile` from a kubeconfig: the start
script writes `/tmp/kubeconfig` with the service account token and CA embedded. Custom cerberus checks are imported as
python modules relative to the working directory (`custom/<file>.py`), never by absolute path.

## chaos-kraken ClusterRole is not validated for every scenario type

The chaos ClusterRole of `chaos-kraken` and `chaos-pipeline` is derived from the upstream RBAC documentation and covers
the scenarios shipped with the charts. When a scenario fails with `Forbidden`, add the rule to `rbac.extraRules` in the
values first, then to the template of both charts once confirmed on a cluster.


## project : registry credentials (dockercfg)

- `dockercfg.list[]` accepts `existingSecret` : a Secret provided by the user (type `kubernetes.io/dockerconfigjson`, same
  namespace), for which the chart renders nothing. Prefer it to clear-text credentials, which end in the values of the
  Argo CD Applications and in the Helm release. The chart never links a Secret to a service account : its name goes in
  `serviceAccounts.list[].imagePullSecrets[].name`, for a generated or an existing Secret.
- The generated Secret (clear-text entry) carries the username and the password in clear in its annotations
  (`template.openshift.io/expose-username`, `template.openshift.io/expose-password`), beside the `stringData`. They are
  kept on purpose : every render of the chart must stay byte-identical for the consumers that track it (decision of
  2026-11-21, project commit with `existingSecret`). The `existingSecret` path avoids them. The owner can decide to drop
  them in a breaking release.
- `example-fruitapp-project` copies the `dockercfg` block of the project schema with the five required entry fields, so
  it rejects an `existingSecret` only entry. Known limitation, to fix when its schema is regenerated.
- A dependent chart accepts the `existingSecret` only form once it pins a `project` release that contains it (Helm
  validates the values of a dependency with the schema packaged in the dependency).

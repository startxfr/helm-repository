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

## cluster-unifai : vendored rabbitmq chart has a broken dependency upstream

`charts/cluster-unifai/vendor/shared-resources/rabbitmq/Chart.yaml` (vendored from `startxfr/UnifAI`) ships with its
`common` Bitnami library chart dependency commented out, which breaks `helm template`/`helm install` (its templates
call `common.names.fullname` etc.). `.tools/sync-unifai-vendor.sh` re-applies the fix (un-comments the dependency,
pinned to `oci://registry-1.docker.io/bitnamicharts` `2.41.0`) automatically on every resync, along with a rename of
the vendored `multiagent/temporal-worker` chart (both `multiagent/be` and `multiagent/temporal-worker` declare
`name: multiagent` upstream, which collides when Helm packages dependencies by `<name>-<version>.tgz`). If a future
manual edit to the vendor tree reverts either fix, re-run the sync script instead of hand-patching.

# etcd-backup

Helm chart that deploys a **periodic OpenShift etcd backup CronJob** writing
to an S3-compatible object store. Uses the [adfinis/openshift-etcd-backup](https://github.com/adfinis/openshift-etcd-backup)
container image.

## Resources rendered

| Resource | Sync wave | Purpose |
|---|---|---|
| `Namespace` (via `project` sub-chart) | 0 | Namespace `etcd-backup` |
| `ServiceAccount/etcd-backup` | 10 | Identity for the backup pods |
| `Role/use-privileged-scc` | 10 | Allow `use` on the `privileged` SCC |
| `RoleBinding/etcd-backup-sa-privileged` | 10 | Bind SA → Role |
| `ConfigMap/backup-config` | 11 | Non-sensitive S3 settings |
| `Secret/etcd-backup-s3` | 11 | Sensitive S3 access/secret keys |
| `ConfigMap/s3-ca` (optional) | 11 | Custom CA bundle when `useS3Ca: true` |
| `PrometheusRule/etcd-backup-cronjob-monitor` | 12 | "No recent backup" + "Last job failed" alerts |
| `CronJob/etcd-backup` | 20 | The backup job itself |

## Quick start

```bash
helm upgrade --install etcd-backup . -f values-startx.yaml -n etcd-backup
```

## Trigger a backup manually

```bash
oc -n etcd-backup create job \
  --from=cronjob/etcd-backup etcd-backup-manual-$(date +%s)
oc -n etcd-backup logs -f job/etcd-backup-manual-...
```

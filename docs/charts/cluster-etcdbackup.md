# ![cluster-etcdbackup](https://helm-repository.readthedocs.io/en/latest/img/cluster-etcdbackup.svg "Cluster Chart : Etcd backup") Cluster Chart : Etcd backup

[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--etcdbackup-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+etcdbackup+startx)

This helm chart is used to deploy a periodic **OpenShift etcd backup CronJob** writing snapshots to an S3-compatible object store.
It uses the [adfinis/openshift-etcd-backup](https://github.com/adfinis/openshift-etcd-backup) container image and ships
Prometheus alerts for missing or failed backups.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

- An S3-compatible bucket and an access key / secret key pair with write access
- The backup pods run on a control-plane node with the `privileged` SCC (granted by the chart)

## Deploy this helm chart on openshift

### 1. Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### 2. Install the repository

```bash
helm repo add startx https://helm-repository.readthedocs.io/en/latest/repos/stable/
```

### 3. Get information about this chart

```bash
helm show chart startx/cluster-etcdbackup
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **etcd-backup** without constraints
- 1 **serviceAccount:** named **etcd-backup** allowed to use the **privileged** SCC
- 1 **configMap** and 1 **secret** holding the S3 endpoint, bucket and credentials
- 1 **cronJob:** named **etcd-backup** running every 12 hours (`0 */12 * * *`) with a retention of **30 days** / **10 backups**
- 1 **prometheusRule** raising an alert when no successful backup happened for **24 hours** or when the last job failed

```bash
# Create the project
helm install cluster-etcdbackup-project startx/cluster-etcdbackup --set project.enabled=true,etcdBackup.enabled=false
# Deploy the etcd backup CronJob
helm install cluster-etcdbackup-instance startx/cluster-etcdbackup --set project.enabled=false,etcdBackup.enabled=true,etcdBackup.s3_endpoint=https://s3.example.com,etcdBackup.s3_bucket_name=my-bucket,etcdBackup.s3_secret.s3_access_key=XXX,etcdBackup.s3_secret.s3_secret_key=YYY
```

#### Other available values

- **startx** : etcd backup every 12 hours with alerting (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-etcdbackup/values-startx.yaml))

```bash
helm install cluster-etcdbackup startx/cluster-etcdbackup -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-etcdbackup/values-startx.yaml
```

## Resources rendered

| Resource                                     | Sync wave | Purpose                                         |
| -------------------------------------------- | --------- | ----------------------------------------------- |
| `Namespace` (via `project` sub-chart)        | `-10`     | Namespace `etcd-backup`                         |
| `ServiceAccount/etcd-backup`                 | `1`       | Identity for the backup pods                    |
| `Role/use-privileged-scc`                    | `1`       | Allow `use` on the `privileged` SCC             |
| `RoleBinding/etcd-backup-sa-privileged`      | `1`       | Bind SA to Role                                 |
| `ConfigMap/backup-config`                    | `1`       | Non-sensitive S3 settings                       |
| `Secret/etcd-backup-s3`                      | `1`       | Sensitive S3 access/secret keys                 |
| `ConfigMap/s3-ca` (optional)                 | `1`       | Custom CA bundle when `useS3Ca: true`           |
| `CronJob/etcd-backup`                        | `15`      | The backup job itself                           |
| `PrometheusRule/etcd-backup-cronjob-monitor` | `30`      | "No recent backup" + "Last job failed" alerts   |

S3 credentials can either be rendered by the chart (fill `etcdBackup.s3_secret.s3_access_key` and `s3_secret_key`)
or referenced from an existing secret (set `etcdBackup.s3_secret.secretName`, with keys `OCP_BACKUP_S3_ACCESS_KEY` and `OCP_BACKUP_S3_SECRET_KEY`).

## Trigger a backup manually

```bash
oc -n etcd-backup create job \
  --from=cronjob/etcd-backup etcd-backup-manual-$(date +%s)
oc -n etcd-backup logs -f job/etcd-backup-manual-...
```

## Deploy with ArgoCD

This chart does not deploy any operator, so only two Applications are needed.

### AppProject

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/cluster-etcdbackup/examples/argocd/
oc apply -k .
```

### Applications

| Application                  | Wave   | Enabled flags                                      | Destination   |
| ---------------------------- | ------ | -------------------------------------------------- | ------------- |
| `cluster-etcdbackup-project` | `"1"`  | `project.enabled: true`, `etcdBackup.enabled: false` | `etcd-backup` |
| `cluster-etcdbackup-app`     | `"10"` | `project.enabled: false`, `etcdBackup.enabled: true` | `etcd-backup` |

The S3 credentials must be provided either through an existing secret (`etcdBackup.s3_secret.secretName`)
or by overriding the values of the `cluster-etcdbackup-app` Application.

## History

| Release  | Date       | Description                                                       |
| -------- | ---------- | ----------------------------------------------------------------- |
| 21.3.3   | 2026-06-26 | Initial release of the etcd backup CronJob chart                  |
| 21.3.278 | 2026-10-21 | Align name, icon, metadata, sync-waves and docs to conventions   |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |

# ![cluster-crunchy](https://helm-repository.readthedocs.io/en/latest/img/cluster-crunchy.svg "Cluster Chart : Crunchy") Cluster Chart : Crunchy
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--crunchy-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+crunchy+startx)

This helm chart is used to deploy PostgreSQL clusters managed by the Crunchy Postgres for Kubernetes operator (PGO).
Each entry of `cluster.list` is a `PostgresCluster`, from a single instance for development up to a highly available
cluster for production: several instances with synchronous replication on distinct nodes, pgBackRest backups to an
S3 bucket with point in time restore, PodMonitor and alerts, NetworkPolicy. The chart is used alone, or as the
`crunchy` sub-chart of [cluster-quay](https://helm-repository.readthedocs.io/en/latest/charts/cluster-quay), which
derives the database connection strings of the registry from the clusters listed here.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

| Requirement | Detail |
| --- | --- |
| OpenShift 4.17+ (Kubernetes 1.30+) | `kubeVersion` of the chart |
| Crunchy Postgres for Kubernetes 5.8 | `certified-operators` catalog, package `crunchy-postgres-operator`, channel `v5`, installed by the `operator` sub-chart in the namespace of the clusters (OwnNamespace). A Crunchy Data support subscription is required in production for organizations of 50 employees or more ([terms of use](https://www.crunchydata.com/developers/terms-of-use)) |
| `backup.type: s3` | An S3 compatible bucket reachable from the database pods, described in `s3.list` |
| `monitoring.enabled` | The Prometheus operator CRDs (`PodMonitor`, `PrometheusRule`): user workload monitoring enabled on the cluster |
| Secrets | Passwords and S3 credentials are expected as [Argo CD Vault Plugin](https://argocd-vault-plugin.readthedocs.io/) placeholders (`<path:kv/data/...#key>`) or supplied by a values file kept out of Git; the chart never generates them |

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
helm show chart startx/cluster-crunchy
```

### 4. Install this chart

```bash
helm install cluster-crunchy startx/cluster-crunchy
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **default-crunchy** without constraints
- 1 **operator:** named **crunchy-postgres-operator** configured with
  - The **v5** channel of the certified catalog
  - The **v5.8.9** version
  - Deployed under the **default-crunchy** project
- 1 **cluster:** named **default-db** configured with
  - PostgreSQL **14**, one instance, a **2Gi** data volume
  - a volume based pgBackRest repository with a full backup on Sunday and a differential backup the other days, 14 days of retention
  - pgBouncer, pgAdmin and password-less connections (`pgHbaTrust`), as in the previous releases of this chart

```bash
# Create the project
helm install cluster-crunchy-project startx/cluster-crunchy --set project.enabled=true,operator.enabled=false,cluster.enabled=false
# Deploy the crunchy operator
helm install cluster-crunchy-operator startx/cluster-crunchy --set project.enabled=false,operator.enabled=true,cluster.enabled=false && sleep 10
# Configure default crunchy resources
helm install cluster-crunchy-instance startx/cluster-crunchy --set project.enabled=false,operator.enabled=false,cluster.enabled=true
```

## Other available values

- **startx** : CrunchyDB operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx.yaml))
- **startx-ha** : one highly available cluster, two instances, synchronous replication, S3 backups, monitoring (see [values-startx-ha.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx-ha.yaml))
- **startx-quay** : the two databases of a highly available Quay registry, used by the `crunchy` sub-chart of cluster-quay (see [values-startx-quay.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx-quay.yaml))
- **demo** : demo cluster (see [values-demo.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-demo.yaml))
- `values-startx_noinfra*.yaml` : the same without the infra node placement of the operator

```bash
helm install cluster-crunchy startx/cluster-crunchy -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-crunchy/values-startx.yaml
```

## Values

### Cluster entries (`cluster.list[]`)

Every key below the first entry of `values.yaml` is optional; the defaults keep the behaviour of the previous
releases (one instance, volume based backups, pgBouncer, pgAdmin, pg_hba trust).

| Key | Default | Description |
| --- | --- | --- |
| `name`, `enabled`, `namespace` | `default-db`, `true`, project name | Name of the `PostgresCluster`, switch, namespace |
| `postgresVersion` | `14` | Major version; the operator picks its image unless `image` is set |
| `storageClassName`, `storageInstanceSize`, `storageBackupSize` | `""`, `2Gi`, `2Gi` | Data volume (empty class: default StorageClass of the cluster), volume of the volume based repository |
| `username`, `database` | `default-user`, cluster name | Owner role and its database (`users[0]` of the `PostgresCluster`) |
| `password` | `""` | Owner password (secret). Empty: generated by the operator. Set: the chart renders the Secret `<name>-pguser-<username>` and the operator keeps it |
| `extensions` | `[]` | Extensions created in the database at initialization; ignored when `initScript` is set |
| `initScript` | SQL sample | Full `databaseInitSQL` script (ConfigMap `<name>-initdb`), takes precedence over `extensions` |
| `replicas` | `1` | Instances of the cluster; 2 or more enables the Patroni failover |
| `synchronous` | `false` | Patroni `synchronous_mode`: no committed transaction lost at failover |
| `avoidInfraNodes` | `false` | Required anti-affinity between the instances (one per node) and no scheduling on infra nodes, backup jobs included |
| `image`, `resources`, `parameters` | `""`, `{}`, `{}` | Instance image (empty: operator default), resources of each instance, `postgresql.conf` parameters |
| `pgHbaTrust` | `true` | Password-less connections from any address, as before. `false`: operator defaults (SCRAM, TLS) |
| `pgbouncer.enabled`, `pgadmin.enabled` | `true`, `true` | pgBouncer pooler and pgAdmin interface |
| `istioSidecarEnabled` | `false` | Istio sidecar annotations on the instances and the backup jobs |
| `backup.enabled`, `backup.type` | `true`, `volume` | pgBackRest repository: a volume (`storageBackupSize`) or an entry of `s3.list` (`backup.s3`) |
| `backup.pathPrefix`, `backup.retentionDays`, `backup.schedules` | namespace, `14`, Sunday 1:00 / other days 1:00 | S3 repository path `/<prefix>/<name>/repo1`, retention of the full backups in days, cron of the full and differential backups (`differential: ""` disables it) |
| `backup.image` | `""` | pgBackRest image (empty: operator default) |
| `restore.enabled`, `restore.s3`, `restore.source`, `restore.target` | `false` | Bootstrap the cluster from the repository `source` (a `repo1-path`) of the endpoint `s3` (empty: `backup.s3`), at `target` (empty: end of the archive). Read at cluster creation only |
| `inPlaceRestore.enabled`, `inPlaceRestore.target` | `false`, `""` | Restore in place of the running cluster, triggered by the `pgbackrest-restore` annotation (see Procedures) |
| `monitoring.enabled` and thresholds | `false` | pgMonitor exporter, `PodMonitor <name>-exporter` and `PrometheusRule <name>-alerts` (`CrunchyPostgres*` alerts) |
| `networkPolicy.enabled`, `allowedNamespaces`, `operatorNamespaces`, `monitoringNamespaces` | `false` | Ingress policy on the database pods: same namespace, `allowedNamespaces` on 5432, `operatorNamespaces` on every port, monitoring stacks on 9187 |

### S3 endpoints (`s3.list[]`)

| Key | Description |
| --- | --- |
| `name`, `namespace` | Name referenced by `backup.s3` and `restore.s3`; namespace of the Secret `<name>-pgbackrest-s3` (the namespace of the clusters) |
| `endpoint`, `port`, `region`, `bucket`, `uriStyle` | Endpoint without scheme, port (empty: 443), signature region (required), bucket, `path` or `host` addressing |
| `accessKey`, `secretKey`, `caCert` | Credentials (secret) and PEM of a private CA signing the endpoint certificate |

### Sub-charts

`project` (namespace) and `operator` (OLM subscription and OperatorGroup of the Crunchy operator) are the STARTX basic
charts; see their documentation. The chart objects use Argo CD sync waves: Secrets and ConfigMaps (1), `PostgresCluster`
and `NetworkPolicy` (15), `PodMonitor` and `PrometheusRule` (30), loaders (35).

## Procedures

### Backups

```bash
# status of the repository, per cluster
oc exec -n default-crunchy startx-db-instance1-xxxx-0 -c database -- pgbackrest info
# on demand full backup
oc annotate postgrescluster startx-db -n default-crunchy postgres-operator.crunchydata.com/pgbackrest-backup="$(date +%s)" --overwrite
```

### Restore to a point in time, in place

Set `inPlaceRestore.enabled: true` and `inPlaceRestore.target: "2026-10-15 14:00:00+00"` on the cluster entry, apply
(commit with Argo CD), then trigger the restore. The operator stops the cluster, restores the primary from the repository
and rebuilds the replicas. Set `inPlaceRestore.enabled` back to `false` once done.

```bash
oc annotate postgrescluster startx-db -n default-crunchy postgres-operator.crunchydata.com/pgbackrest-restore="$(date +%s)" --overwrite
```

### Restore into a new cluster

A new cluster entry with `restore.enabled: true`, `restore.source` set to the `repo1-path` of the source cluster
(`/<prefix>/<cluster>/repo1`) and a `backup.pathPrefix` or a cluster name different from the source: the new cluster
must not archive into the repository it restores from (the chart refuses it). The restored cluster gets new passwords
unless `password` is set.

### Certificate authority of a cluster

The operator issues one root CA per operator, shared by its clusters, and one leaf certificate per cluster. Clients
verifying the server certificate (`sslmode=verify-full`) need the CA:

```bash
oc get secret startx-db-cluster-cert -n default-crunchy -o jsonpath='{.data.ca\.crt}' | base64 -d
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-crunchy/examples/argocd/
oc apply -k .
```

### Applications

The `examples/argocd` folder holds the AppProject and the three Applications (project, operator, app) of the standard
pattern, using `values-startx_noinfra.yaml`. For a highly available cluster, replace the values file by
`values-startx_noinfra-ha.yaml` and declare the S3 credentials through the Argo CD Vault Plugin.

## History

| Release  | Date       | Description                                            |
| -------- | ---------- | ------------------------------------------------------ |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.15 | 2026-03-02 | Prepare upgrading dependency to 19.23.11 |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.7 | 2026-03-02 | Update dependencies to version 20.14.0 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.1 | 2026-03-02 | Prepare release 21.3.x with 21.x dependencies |
| 21.3.3 | 2026-03-02 | Upgrade dependencies to v21.3.0 |
| 21.3.4 | 2026-06-17 | 21.3.9 |
| 21.3.11 | 2026-06-17 | publish stable update for the full repository |
| 21.3.12 | 2026-06-18 | Update crunchy-postgres-operator to 5.8.7, add ArgoCD deployment examples |
| 21.3.27 | 2026-06-19 | publish stable update for the full repository |
| 21.3.55 | 2026-06-19 | publish stable update for the full repository |
| 21.3.56 | 2026-06-19 | publish stable update for the full repository |
| 21.3.67 | 2026-06-20 | publish stable update for the full repository |
| 21.3.68 | 2026-06-20 | update basic dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.68 | 2026-06-20 | update all charts dependencies to v21.3.70 |
| 21.3.102 | 2026-06-20 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.103 | 2026-06-21 | publish stable update for the full repository |
| 21.3.104 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.105 | 2026-06-21 | publish stable update for the full repository |
| 21.3.106 | 2026-06-21 | publish stable update for the full repository |
| 21.3.167 | 2026-06-23 | publish stable update for the full repository |
| 21.3.181 | 2026-06-23 | publish stable update for the full repository |
| 21.3.182 | 2026-06-23 | publish stable update for the full repository |
| 21.3.199 | 2026-06-24 | publish stable update for the full repository |
| 21.3.201 | 2026-06-24 | publish stable update for the full repository |
| 21.3.202 | 2026-06-24 | publish stable update for the full repository |
| 21.3.205 | 2026-06-24 | publish stable update for the full repository |
| 21.3.229 | 2026-08-08 | publish stable update for the full repository |
| 21.3.273 | 2026-08-09 | publish stable update for the full repository |
| 21.3.277 | 2026-08-09 | Align all charts to v21.3.277 |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.279 | 2026-10-20 | High availability, S3 backups, restore, monitoring and network policies per cluster; crunchy-postgres-operator 5.8.9 |

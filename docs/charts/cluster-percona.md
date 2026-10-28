# ![cluster-percona](https://helm-repository.readthedocs.io/en/latest/img/cluster-percona.svg "Cluster Chart : Percona") Cluster Chart : Percona
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--percona-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+percona+startx)

This helm chart is used to deploy PostgreSQL clusters managed by the Percona Operator for PostgreSQL (version 3,
built on the Crunchy PGO engine, API `pgv2.percona.com`). Each entry of `cluster.list` is a `PerconaPGCluster`,
from a single instance for development up to a highly available cluster for production: several instances with
synchronous replication on distinct nodes, pgBackRest backups to an S3 bucket with point in time restore, pgBouncer,
PMM monitoring, NetworkPolicy. The chart is used alone, or as the `percona` sub-chart of
[cluster-quay](https://helm-repository.readthedocs.io/en/latest/charts/cluster-quay), which derives the database
connection strings of the registry from the clusters listed here.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

| Requirement | Detail |
| --- | --- |
| OpenShift 4.19+ (Kubernetes 1.30+) | `kubeVersion` of the chart; the operator 3.1.0 is certified for OpenShift 4.19 to 4.22 |
| Percona Operator for PostgreSQL 3.1 | `certified-operators` catalog, package `percona-postgresql-operator-certified`, channel `stable`, installed by the `operator` sub-chart in the namespace of the clusters (OwnNamespace; every install mode is supported). Apache 2.0, free of charge; the support contract is optional |
| Images | The certified operator sets no default image: the chart passes the images of `images` (Percona Distribution for PostgreSQL 14 to 18, pgBackRest, pgBouncer, PMM client, Fluent Bit) to every cluster; mirror them in a disconnected environment |
| `backup.type: s3` | An S3 compatible bucket reachable from the database pods, described in `s3.list` |
| `monitoring.enabled` | A PMM 3 server reachable from the database pods and a service account token |
| Secrets | Passwords, S3 credentials and PMM tokens are expected as [Argo CD Vault Plugin](https://argocd-vault-plugin.readthedocs.io/) placeholders (`<path:kv/data/...#key>`) or supplied by a values file kept out of Git; the chart never generates them |

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
helm show chart startx/cluster-percona
```

### 4. Install this chart

```bash
helm install cluster-percona startx/cluster-percona
```

## Deploy this helm chart with ArgoCD

### 1. Create the project

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: percona-project
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "default-percona"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-percona/
    repoURL: 'https://gitlab.com/startx1/helm.git'
    targetRevision: 21.3.309
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: project.enabled
      value: "true"
EOF
```

### 2. Deploy the operator

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: percona-operator
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "default-percona"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-percona/
    repoURL: 'https://gitlab.com/startx1/helm.git'
    targetRevision: 21.3.309
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: operator.enabled
      value: "true"
EOF
```

### 3. Deploy a percona instance

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: percona-instance
namespace: "openshift-gitops"
spec:
  destination:
    namespace: "default-percona"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/cluster-percona/
    repoURL: 'https://gitlab.com/startx1/helm.git'
    targetRevision: 21.3.309
    helm:
    valueFiles:
    - values-demo.yaml
    parameters:
    - name: cluster.enabled
      value: "true"
    - name: loader.enabled
      value: "true"
EOF
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **default-percona** without constraints
- 1 **operator:** named **percona-postgresql-operator-certified** configured with
  - The **stable** channel of the certified catalog
  - The **v3.1.0** version
  - Deployed under the **default-percona** project
- 1 **cluster:** named **default-db** configured with
  - PostgreSQL **18** (Percona Distribution image), one instance, a **2Gi** data volume
  - a volume based pgBackRest repository with a full backup on Sunday and a differential backup the other days, 14 days of retention
  - one pgBouncer pod (Service `default-db-pgbouncer`), SCRAM authentication and TLS (operator defaults)
  - no monitoring, no log collector, no network policy

```bash
# Create the project
helm install cluster-percona-project startx/cluster-percona --set project.enabled=true,operator.enabled=false,cluster.enabled=false
# Deploy the percona operator
helm install cluster-percona-operator startx/cluster-percona --set project.enabled=false,operator.enabled=true,cluster.enabled=false && sleep 10
# Configure default percona resources
helm install cluster-percona-instance startx/cluster-percona --set project.enabled=false,operator.enabled=false,cluster.enabled=true
```

## Other available values

- **startx** : Percona operator and a demo cluster (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-percona/values-startx.yaml))
- **startx-ha** : one highly available cluster, two instances, synchronous replication, S3 backups, network policy (see [values-startx-ha.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-percona/values-startx-ha.yaml))
- **startx-quay** : the two databases of a highly available Quay registry, used by the `percona` sub-chart of cluster-quay (see [values-startx-quay.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-percona/values-startx-quay.yaml))
- **demo** : demo cluster (see [values-demo.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-percona/values-demo.yaml))
- `values-startx_noinfra*.yaml` : the same without the infra node placement of the operator

```bash
helm install cluster-percona startx/cluster-percona -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-percona/values-startx.yaml
```

## Values

### Chart level

| Key | Default | Description |
| --- | --- | --- |
| `crVersion` | `""` | `spec.crVersion` of every cluster (empty: the `appVersion` of the chart). Keep it equal to the installed operator version: the operator enables the features of that version, and writes its own version into an object that has none, which Argo CD reports as a drift |
| `images.postgres.<major>` | Percona Distribution for PostgreSQL 14 to 18 | PostgreSQL image of the clusters whose entry sets no `image` |
| `images.pgbackrest`, `images.pgbouncer`, `images.pmm`, `images.logcollector` | Percona images of the operator 3.1.0 | Images of the components, unless the entry sets its own |

### Cluster entries (`cluster.list[]`)

Every key below the first entry of `values.yaml` is optional.

| Key | Default | Description |
| --- | --- | --- |
| `name`, `enabled`, `namespace` | `default-db`, `true`, project name | Name of the `PerconaPGCluster`, switch, namespace |
| `postgresVersion`, `image` | `18`, `""` | Major version; the image is `images.postgres.<postgresVersion>` unless `image` is set |
| `storageClassName`, `storageInstanceSize`, `storageBackupSize` | `""`, `2Gi`, `2Gi` | Data volume (empty class: default StorageClass of the cluster), volume of the volume based repository |
| `username`, `database` | `default-user`, cluster name | Owner role and its database (`users[0]` of the cluster) |
| `password` | `""` | Owner password (secret). Empty: generated by the operator in the Secret `<name>-pguser-<username>`. Set: the chart renders that Secret and the operator computes the SCRAM verifier |
| `extensions` | `[]` | Extensions created in the database at initialization; ignored when `initScript` is set |
| `initScript` | `""` | Full `databaseInitSQL` script (ConfigMap `<name>-initdb`), takes precedence over `extensions` |
| `replicas` | `1` | Instances of the instance set `instance1`; 2 or more enables the Patroni failover |
| `synchronous` | `false` | Patroni `synchronous_mode`: no committed transaction lost at failover |
| `avoidInfraNodes` | `false` | Required anti-affinity between the instances (one per node) and no scheduling on infra nodes, pgBouncer and backup jobs included |
| `resources`, `parameters` | `{}`, `{}` | Resources of each instance, `postgresql.conf` parameters (`patroni.dynamicConfiguration`) |
| `pgHbaTrust` | `false` | Password-less connections from any address. `false`: operator defaults (SCRAM, TLS) |
| `autoCreateUserSchema` | `false` | Percona option creating a schema named after the owner in its database |
| `pgbouncer.enabled`, `pgbouncer.replicas`, `pgbouncer.image` | `true`, `1`, `""` | pgBouncer pooler (Service `<name>-pgbouncer`) |
| `builtinExtensions` | `{}` | `spec.extensions` of the cluster as is: switches of the Percona built-in extensions (`pg_stat_monitor`, `pg_stat_statements`, `pg_audit`, `pgvector`, `pg_repack`, `pg_cron`, `set_user`, `pg_tde`) and `custom` extensions |
| `istioSidecarEnabled` | `false` | Istio sidecar annotations on the instances and the backup jobs |
| `backup.enabled`, `backup.type` | `true`, `volume` | pgBackRest repository: a volume (`storageBackupSize`) or an entry of `s3.list` (`backup.s3`). `enabled: false` removes pgBackRest from the cluster |
| `backup.pathPrefix`, `backup.retentionDays`, `backup.schedules` | namespace, `14`, Sunday 1:00 / other days 1:00 | S3 repository path `/<prefix>/<name>/repo1`, retention of the full backups in days, cron of the full and differential backups (`differential: ""` disables it) |
| `backup.image` | `""` | pgBackRest image (empty: `images.pgbackrest`) |
| `restore.enabled`, `restore.s3`, `restore.source`, `restore.target` | `false` | Bootstrap the cluster from the repository `source` (a `repo1-path`) of the endpoint `s3` (empty: `backup.s3`), at `target` (empty: end of the archive). Read at cluster creation only |
| `inPlaceRestore.enabled`, `inPlaceRestore.restoreName`, `inPlaceRestore.target` | `false`, `""`, `""` | Restore in place of the running cluster: renders the `PerconaPGRestore <name>-restore-<restoreName>` (see Procedures) |
| `monitoring.enabled`, `serverHost`, `token`, `existingSecret`, `querySource`, `image` | `false`, `monitoring-service`, `""`, `""`, `pgstatmonitor`, `""` | PMM client sidecar on every instance: address of the PMM 3 server, service account token (secret, rendered in the Secret `<name>-pmm-secret`) or an existing Secret holding `PMM_SERVER_TOKEN`, query analytics source |
| `logCollector.enabled`, `logCollector.image` | `false`, `""` | Fluent Bit sidecar persisting the PostgreSQL and pgBackRest logs |
| `networkPolicy.enabled`, `allowedNamespaces`, `operatorNamespaces` | `false` | Ingress policy on the database pods: same namespace, `allowedNamespaces` on 5432, `operatorNamespaces` on every port |

### S3 endpoints (`s3.list[]`)

| Key | Description |
| --- | --- |
| `name`, `namespace` | Name referenced by `backup.s3` and `restore.s3`; namespace of the Secret `<name>-pgbackrest-s3` (the namespace of the clusters) |
| `endpoint`, `port`, `region`, `bucket`, `uriStyle` | Endpoint without scheme, port (empty: 443), signature region (required), bucket, `path` or `host` addressing |
| `accessKey`, `secretKey`, `caCert` | Credentials (secret) and PEM of a private CA signing the endpoint certificate |

### Sub-charts

`project` (namespace) and `operator` (OLM subscription and OperatorGroup of the Percona operator) are the STARTX basic
charts; see their documentation. The chart objects use Argo CD sync waves: Secrets and ConfigMaps (1),
`PerconaPGCluster` and `NetworkPolicy` (15), `PerconaPGRestore` (30), loaders (35).

Differences with [cluster-crunchy](https://helm-repository.readthedocs.io/en/latest/charts/cluster-crunchy), which
drives the same engine: the images are mandatory (`images`), monitoring goes through PMM instead of a PodMonitor and
Prometheus alerts, on demand backups and in place restores are objects (`PerconaPGBackup`, `PerconaPGRestore`)
instead of annotations, no pgAdmin, SCRAM and TLS by default, built-in extensions of the Percona distribution.

## Procedures

### Backups

```bash
# status of the cluster and of its backups
oc get pg startx-db -n default-percona
oc get pg-backup -n default-percona
# on demand full backup
cat <<EOF | oc apply -f -
apiVersion: pgv2.percona.com/v2
kind: PerconaPGBackup
metadata:
  name: startx-db-$(date +%Y%m%d%H%M)
  namespace: default-percona
spec:
  pgCluster: startx-db
  repoName: repo1
  options:
    - --type=full
EOF
```

### Restore to a point in time, in place

Set `inPlaceRestore.enabled: true`, `inPlaceRestore.restoreName: r1` and `inPlaceRestore.target: "2026-10-15 14:00:00+00"`
on the cluster entry, apply (commit with Argo CD). The operator stops the cluster, restores the primary from the
repository and rebuilds the replicas; `oc get pg-restore -n default-percona` shows the state (`Succeeded`). A
finished `PerconaPGRestore` is never re-run: the next restore needs a new `restoreName`. Set `inPlaceRestore.enabled`
back to `false` once done (the object is pruned).

### Restore into a new cluster

A new cluster entry with `restore.enabled: true`, `restore.source` set to the `repo1-path` of the source cluster
(`/<prefix>/<cluster>/repo1`) and a `backup.pathPrefix` or a cluster name different from the source: the new cluster
must not archive into the repository it restores from (the chart refuses it). The restored cluster gets new passwords
unless `password` is set.

### Certificate authority of a cluster

The operator issues one root CA per cluster (Secret `<name>-cluster-ca-cert`) and the server certificate of the
cluster (Secret `<name>-cluster-cert`, whose `ca.crt` is that CA). Clients verifying the server certificate
(`sslmode=verify-full`) need it:

```bash
oc get secret startx-db-cluster-cert -n default-percona -o jsonpath='{.data.ca\.crt}' | base64 -d
```

### Operator update

The `PerconaPGCluster` carries `spec.crVersion`: after an operator update, set `crVersion` (or the `appVersion` of the
chart) to the new version so that the operator applies the changes of that version to the Kubernetes objects.

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-percona/examples/argocd/
oc apply -k .
```

### Applications

The `examples/argocd` folder holds the AppProject and the three Applications (project, operator, app) of the standard
pattern, using `values-startx_noinfra.yaml`. For a highly available cluster, replace the values file by
`values-startx_noinfra-ha.yaml` and declare the S3 credentials through the Argo CD Vault Plugin.

## History

| Release  | Date       | Description                                            |
| -------- | ---------- | ------------------------------------------------------ |
| 21.3.279 | 2026-10-22 | Initial chart creation |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |

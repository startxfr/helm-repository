# ![cluster-quay-ha](https://helm-repository.readthedocs.io/en/latest/img/cluster-quay.svg "Cluster Chart : Quay HA") Cluster Chart : Quay HA
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--quay--ha-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster-quay-ha+startx)

This helm chart deploys a highly available Red Hat Quay registry on OpenShift with the Quay operator, and lets you
choose, from `values.yaml` only:

- the object storage of the registry: an **external S3 compatible endpoint** (Ceph RGW, MinIO, a cloud S3...) or the
  **object storage managed by the Quay operator** (OpenShift Data Foundation);
- the PostgreSQL databases of Quay and Clair: **managed by this chart** with **Crunchy Postgres for Kubernetes** or
  **CloudNativePG** (two instances, synchronous replication, anti-affinity), **external** servers, or the single pod
  databases of the Quay operator (tests only);
- **OIDC login** (Keycloak or any OpenID Connect provider), on or off;
- **backup** of the databases to an S3 bucket (pgBackRest or Barman Cloud) and **restore** (new cluster, point in
  time, in place), on or off;
- monitoring (PodMonitor, PrometheusRule alerts), NetworkPolicy and PodDisruptionBudgets.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts)
that represents a cluster configuration state orchestrated by gitops tools like ArgoCD. It is written for Argo CD
(sync waves, server side apply of the secrets, Argo CD Vault Plugin placeholders) and also works with `helm install`.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for more information on how to use
theses resources.

| Requirement | Detail |
| --- | --- |
| OpenShift 4.17+ (Kubernetes 1.30+) | `kubeVersion` of the chart. OpenShift Routes, SCC and the monitoring stack are assumed |
| Quay operator 3.18 (`redhat-operators`, channel `stable-3.18`) | Installed cluster wide (`openshift-operators`): the `monitoring` component of the operator requires the AllNamespaces mode. The `operator` sub-chart can install it |
| `database.mode: crunchy` | Crunchy Postgres for Kubernetes 5.8 (`certified-operators`, `crunchy-postgres-operator`, channel `v5`). The `dbOperator` sub-chart can install it in the database namespace. Subscription required above 50 employees (Crunchy Data licensing) |
| `database.mode: cloudnativepg`, flavor `community` | CloudNativePG 1.26+ (`community-operators` catalog, or its release manifest; not in the Red Hat or certified catalogs), `cnpg-system` namespace. The `plugin` backup method also needs the [Barman Cloud Plugin](https://cloudnative-pg.io/plugin-barman-cloud/) and cert-manager |
| `database.mode: cloudnativepg`, flavor `edb` | EDB Postgres for Kubernetes (`certified-operators`, API group `postgresql.k8s.enterprisedb.io`), the `dbOperator` sub-chart can install it |
| `storage.mode: operator` | OpenShift Data Foundation (NooBaa): the operator creates an ObjectBucketClaim |
| `backup.enabled` | An S3 compatible bucket reachable from the database pods, with its own credentials |
| `monitoring.enabled` | The Prometheus operator CRDs (`PodMonitor`, `PrometheusRule`): user workload monitoring enabled (`enableUserWorkload: true` in `cluster-monitoring-config`) |
| Argo CD | OpenShift GitOps 1.12+ / Argo CD 2.10+. Secrets through a values file kept out of Git or the [Argo CD Vault Plugin](https://argocd-vault-plugin.readthedocs.io/) |

## What the chart renders

| Object | Namespace | Condition |
| --- | --- | --- |
| `Namespace` (sub-chart `project`) | | `project.enabled` |
| `Subscription` of the Quay operator (sub-chart `operator`) | `openshift-operators` | `operator.enabled` |
| `OperatorGroup` + `Subscription` of the database operator (sub-chart `dbOperator`) | `dbOperator.subscription.namespace` | `dbOperator.enabled` |
| `Namespace` of the databases | | `database.namespace` set and `database.createNamespace` (even when `enabled: false`) |
| `Secret <quay.name>-config-bundle` (`config.yaml`, `clair-config.yaml`, `extra_ca_cert_*`, `ssl.cert/key`) | registry | `enabled` and no `quay.existingConfigBundleSecret` |
| `Secret postgresql-client-certs` (`ca.crt`, projected by the operator in `/run/secrets/postgresql`) | registry | `database.tls.mode: verify-full` (also with an existing config bundle) |
| `QuayRegistry <quay.name>` | registry | `enabled` |
| `PodDisruptionBudget` quay-app, clair-app, quay-mirror (`maxUnavailable: 1`) | registry | `quay.podDisruptionBudgets.enabled` |
| `PostgresCluster quay-db` and `clair-db`, pguser Secrets, init ConfigMaps, pgBackRest S3 Secret | databases | `database.mode: crunchy` |
| `Cluster quay-db` and `clair-db`, owner Secrets, `ScheduledBackup`, Barman S3 Secret, `ObjectStore` (plugin method) | databases | `database.mode: cloudnativepg` |
| `PodMonitor` and `PrometheusRule` with the `QuayPostgres*` alerts | databases | `monitoring.enabled` and a chart managed database |
| `NetworkPolicy` on the database pods | databases | `networkPolicy.enabled` and a chart managed database |

"registry" is `namespace` (empty: `project.project.name` when the `project` sub-chart is enabled, else the release
namespace); "databases" is `database.namespace` (empty: the registry namespace).

Argo CD sync waves order the objects: database namespace (-10), secrets and config maps (10), object stores (15),
database clusters and network policy (20), scheduled backups (25), `QuayRegistry` (30), budgets and alerts (40).

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
helm show chart startx/cluster-quay-ha
helm show values startx/cluster-quay-ha
```

### 4. Install this chart

Minimal values for an external S3 endpoint, Crunchy databases and backups (secrets in a file kept out of Git):

```yaml
# my-values.yaml
quay:
  hostname: quay.apps.ocp.example.com
  secretKey: <64 random characters>
  databaseSecretKey: <64 random characters>
storage:
  mode: external
  external:
    driver: RadosGWStorage        # any S3 compatible endpoint; S3Storage for Amazon S3
    host: s3.example.com
    bucket: quay-registry
    accessKey: <access key>
    secretKey: <secret key>
database:
  mode: crunchy                   # or cloudnativepg, external, quayOperator
  quay:  {password: <alphanumeric password>}
  clair: {password: <alphanumeric password>}
backup:
  enabled: true
  s3:
    endpoint: s3.example.com
    region: us-east-1             # signature region, required by pgBackRest
    bucket: quay-pgbackrest
    accessKey: <access key>
    secretKey: <secret key>
```

```bash
# operators first (namespace quay, Quay operator in openshift-operators, Crunchy operator in quay), approve the InstallPlans
helm install cluster-quay-ha-operators startx/cluster-quay-ha -n openshift-operators \
  --set enabled=false --set project.enabled=true --set operator.enabled=true --set dbOperator.enabled=true
oc get installplan -A | grep -E 'quay-operator|postgresoperator'
# then the registry and its databases
helm install cluster-quay-ha startx/cluster-quay-ha -n quay -f my-values.yaml
```

With `helm install` every object is created at once: the Quay operator retries until the databases accept
connections (a few minutes). Argo CD orders the waves and waits for the databases (see below). Rendering fails with an
explicit message when a required value is missing or when two values contradict each other: `helm template cluster-quay-ha
startx/cluster-quay-ha --kube-version 1.33.0 -f my-values.yaml` shows it without a cluster (`--kube-version`: the chart and the
STARTX sub-charts require Kubernetes 1.30+, which older Helm releases do not assume; a Helm based Argo CD plugin must
pass `--kube-version "$KUBE_VERSION"` for the same reason).

Passwords and keys are written verbatim in `DB_URI` and in the Clair connection strings: use alphanumeric values
(`openssl rand -hex 32`, `openssl rand -base64 24 | tr -d '/+='`), never URL reserved characters.

## Deploy with ArgoCD

Two Applications of the same chart, whatever the pattern (examples in [examples/argocd](examples/argocd/)):

1. `cluster-quay-ha-operators`, `enabled: false`: only the sub-charts are rendered (namespace of the registry, Quay operator
   Subscription, database operator OperatorGroup and Subscription) plus the database namespace when
   `database.namespace` and `database.createNamespace` are set. `prune: false`: Argo CD never removes an operator.
2. `cluster-quay-ha`, `enabled: true`: databases, config bundle, `QuayRegistry`, budgets, alerts.

```bash
# health checks of PostgresCluster, CloudNativePG and EDB Cluster, QuayRegistry and Application:
# Argo CD waits for the databases (wave 20) before creating the QuayRegistry (wave 30)
oc patch argocd openshift-gitops -n openshift-gitops --type merge --patch-file examples/argocd/argocd-health.yaml
```

`--patch-file` replaces `spec.resourceHealthChecks`: merge the lists if the ArgoCD resource already has some. On a
vanilla Argo CD, put the same Lua in `argocd-cm` (`resource.customizations.health.<group>_<kind>`). The rules only
read what the operators publish in `.status`: a durable failure (restore failed, volume resize refused, reconciliation
refused by the operator, `RolloutBlocked`, failed migrations) is `Degraded`, so the sync fails and is retried instead of
waiting forever; a status older than the spec (`observedGeneration` behind `metadata.generation`) stays `Progressing`.
Crash-looping database instances are reported by the operators as "not ready", that is `Progressing`: the
`QuayPostgres*` alerts of the chart cover that case. The `postgresql.cnpg.io` rule replaces the one built into Argo CD,
which classifies switchovers and configuration changes as `Degraded`. Check the rules are live once the patch is applied:
`argocd app get cluster-quay-ha` shows messages such as `2/2 instances ready` next to the `PostgresCluster` resources
(the controller reloads `argocd-cm` without a restart; `--refresh` forces the evaluation). `test/health_lua.py` runs the
rules against status samples of the three operators.

### Pattern A: Applications with inline values

`examples/argocd/application-operators.yaml` and `application-registry.yaml` pull the chart from the STARTX Helm
repository and carry their values inline (`spec.source.helm.values`); secrets come from a values file kept out of
Git or are typed in the Application. `oc apply -k examples/argocd/` creates the AppProject and both Applications;
approve the InstallPlans (`installPlanApproval: Manual`), then the second Application synchronizes.

### Pattern B: chart from the STARTX repository, values in Git, secrets in Vault (recommended)

`examples/argocd/applicationset.yaml` is one ApplicationSet that generates both Applications:

- the chart comes from the STARTX Helm repository (`spec.source.chart`, `targetRevision` = chart version);
- the values file lives in a Git repository of the environment (`examples/argocd/values-example.yaml` is a complete
  one): the git files generator reads it, the template hands it to the plugin as `HELM_VALUES`, and a commit on the
  file regenerates the Applications. A matrix with a list generator adds, for the operators Application, the
  `--set` flags of `HELM_ARGS` (`enabled=false`, sub-charts enabled, `database.createNamespace=true`);
- secrets are Argo CD Vault Plugin placeholders (`secretKey: <path:kv/data/quay/prod#secret_key>`) that
  `helm template` leaves untouched and that the plugin substitutes after rendering; the chart never encodes a
  value, so the placeholders also work inside `DB_URI` and the Clair connection strings. Documentation placeholders
  (`<value>`) left in a non secret value make the rendering fail on purpose;
- `templatePatch` gives the registry Application `prune: true`, `retry` and the `ignoreDifferences` on the
  finalizers added by the operators. Requires Argo CD 2.10+ (OpenShift GitOps 1.12+).

The plugin (`examples/argocd/avp-plugin.yaml`, a Config Management Plugin named `argocd-vault-plugin-helm`) runs
`helm template --kube-version $KUBE_VERSION $HELM_ARGS -f <HELM_VALUES> . | argocd-vault-plugin generate -` in the
chart directory extracted by the repo-server. The sidecar authenticates to Vault with the Kubernetes method
(`AVP_AUTH_TYPE=k8s`): the service account token of the repo-server pod is presented to a Vault role bound to that
service account, with a policy reading the KV path of the placeholders:

```bash
vault auth enable kubernetes      # once; then configure it with the API server address, its CA and a token reviewer
vault policy write quay-prod - <<'EOF'
path "kv/data/quay/prod" { capabilities = ["read"] }
EOF
vault write auth/kubernetes/role/argocd \
  bound_service_account_names=openshift-gitops-repo-server bound_service_account_namespaces=openshift-gitops \
  policies=quay-prod ttl=1h
```

Register the Git repository of the values in Argo CD (repository Secret with a read-only deploy token), add it and
the Helm repository to the AppProject `sourceRepos` (`examples/argocd/appproject.yaml`), apply the ApplicationSet,
approve the InstallPlans. A value changed in Vault is not seen by the manifest cache:
`argocd app get cluster-quay-ha --hard-refresh` then sync. `argocd app rollback` is refused while automated sync is
on: every change, including a restore, goes through Git.

Rules both patterns follow: `database.createNamespace: true` in exactly one Application (the operators one) and an
AppProject that allows cluster scoped `Namespace` objects; the Secrets carry
`argocd.argoproj.io/sync-options: ServerSideApply=true`, so that no clear text copy lands in a
`last-applied-configuration` annotation.

## Values

Everything is in [values.yaml](values.yaml), with the same comments. Values marked *secret* are expected from the
Argo CD Vault Plugin or from a values file kept out of Git.

### Chart and sub-charts

| Value | Default | Description |
| --- | --- | --- |
| `context.*` | `myscope`, `default`, `myenv`, `registry`, `quay`, `3.18.0` | STARTX labels (scope, cluster, environment, component, app, version) |
| `enabled` | `true` | `false`: only the enabled sub-charts (and the database namespace) are rendered |
| `namespace` | `""` | Namespace of the registry; empty: `project.project.name` if the `project` sub-chart is enabled, else the release namespace |
| `project.enabled`, `project.project.name` | `false`, `quay` | STARTX `project` sub-chart: the namespace of the registry (labeled `openshift.io/cluster-monitoring=true` by that chart) |
| `operator.enabled`, `operator.subscription.*` | `false`, Quay operator `stable-3.18` in `openshift-operators`, Manual | STARTX `operator` sub-chart. Set `subscription.operator.csv: quay-operator` and `subscription.version: v3.18.<z>` to pin `startingCSV` |
| `dbOperator.enabled`, `dbOperator.subscription.*`, `dbOperator.operatorGroup.*` | `false`, `crunchy-postgres-operator` `v5` `postgresoperator.v5.8.9` in `quay`, OperatorGroup `quay-db-operator` | STARTX `operator` sub-chart for Crunchy (or EDB). Put `subscription.namespace` and `operatorGroup.namespace` in the database namespace |

### Registry (`quay.*`)

| Value | Default | Description |
| --- | --- | --- |
| `name` | `registry` | Name of the `QuayRegistry`; every object of the operator is prefixed with it |
| `hostname` | `""` | `SERVER_HOSTNAME`; empty: default route `<name>-quay-<namespace>.apps...` |
| `superUsers` | `[quayadmin]` | `SUPER_USERS` |
| `userInitialize` | `true` | `FEATURE_USER_INITIALIZE`: `POST /api/v1/user/initialize` creates the first super user, then set it to `false` |
| `userCreation` | `false` | `FEATURE_USER_CREATION` (forced to `true` with OIDC) |
| `secretKey`, `databaseSecretKey` | `""` | `SECRET_KEY`, `DATABASE_SECRET_KEY`, 64 random characters each (*secret*, required). Never change `DATABASE_SECRET_KEY` once Quay runs: it encrypts the robot tokens and credentials stored in the database |
| `registryTitle`, `registryTitleShort` | `Red Hat Quay`, `Quay` | UI titles |
| `defaultTagExpiration`, `tagExpirationOptions` | `2w`, `[0s,1d,1w,2w,4w]` | Tag expiration |
| `extraConfig` | `{}` | Any other `config.yaml` key, merged last (overrides the keys rendered by the chart) |
| `extraCaCerts` | `{}` | `name: PEM` map, added as `extra_ca_cert_<name>` (Quay and Clair trust them) |
| `existingConfigBundleSecret` | `""` | Use your own config bundle Secret: nothing of `config.yaml`, `clair-config.yaml` or `extra_ca_cert_*` is rendered |
| `tls.managed`, `tls.cert`, `tls.key` | `true` | `true`: route with the cluster wildcard certificate. `false`: your PEM pair (`ssl.cert`, `ssl.key` in the bundle, *secret*) |
| `components.clair`, `mirror`, `hpa`, `route`, `monitoring` | all `true` | Managed components. `monitoring` needs the operator in AllNamespaces mode |
| `overrides.quay`, `overrides.clair`, `overrides.mirror` | quay 2 CPU / 8Gi requests, 4 CPU / 12Gi limits; clair `volumeSize: 50Gi` | `QuayRegistry` overrides (`resources`, `env`, `affinity`, `volumeSize` of the Clair layer storage...). `replicas` is refused by the operator while `hpa` is managed |
| `stopped` | `false` | Scales quay-app, clair-app and quay-mirror to zero and unmanages the HPA (maintenance, restore) |
| `podDisruptionBudgets.enabled` | `true` | One PDB per component (`maxUnavailable: 1`): a node drain evicts one pod of each at a time |

### Object storage (`storage.*`)

| Value | Default | Description |
| --- | --- | --- |
| `mode` | `external` | `external`: `DISTRIBUTED_STORAGE_CONFIG` below. `operator`: `objectstorage` managed (ObjectBucketClaim, ODF/NooBaa) |
| `external.driver` | `RadosGWStorage` | `RadosGWStorage` for any S3 compatible endpoint (signature v4), `S3Storage` for Amazon S3 only (Quay derives the endpoint from `region`; `host`, `port`, `isSecure` are ignored) |
| `external.host`, `port`, `isSecure` | `""`, `""`, `true` | RadosGWStorage: endpoint without scheme (required), port (empty: 443/80) |
| `external.bucket`, `storagePath` | `""`, `/datastorage/registry` | Bucket and prefix |
| `external.accessKey`, `secretKey` | `""` | Credentials (*secret*, required) |
| `external.region` | `""` | Signature region: required with `S3Storage`, `region_name` of `RadosGWStorage` when set |
| `external.caCert` | `""` | PEM of a private CA signing the endpoint (`extra_ca_cert_storage.crt`) |
| `external.custom` | `{}` | Full `DISTRIBUTED_STORAGE_CONFIG` passthrough for other drivers (`IBMCloudStorage`, `GoogleCloudStorage`, `AzureStorage`...) |

### Databases (`database.*`)

| Value | Default | Description |
| --- | --- | --- |
| `mode` | `crunchy` | `crunchy`, `cloudnativepg`: two clusters rendered by the chart. `external`: your servers. `quayOperator`: single pod databases of the operator (not HA, no backup) |
| `namespace`, `createNamespace` | `""`, `false` | Dedicated namespace of the databases (recommended, see Monitoring) and its `Namespace` object |
| `replicas` | `2` | Instances per cluster |
| `synchronous` | `true` | Crunchy: Patroni `synchronous_mode`. CloudNativePG: quorum `any 1`, `dataDurability: preferred` |
| `avoidInfraNodes` | `true` | Required node affinity off `node-role.kubernetes.io/infra`, required anti-affinity between instances |
| `tls.mode`, `tls.caCert` | `require`, `""` | `require`: encrypted, server not verified (first sync). `verify-full`: `caCert` (PEM) required: Crunchy secret `<cluster>-cluster-cert` key `ca.crt`, CloudNativePG secret `<cluster>-ca` key `ca.crt`, external: your CA |
| `quay.name`, `clair.name` | `quay-db`, `clair-db` | Cluster names. Services: `<name>-primary` (crunchy), `<name>-rw` (cloudnativepg) |
| `quay.host`, `quay.port` (and `clair.*`) | `""`, `5432` | `external` mode only |
| `quay.database`, `quay.user`, `quay.password` (and `clair.*`) | `quay`/`quay`, `clair`/`clair`, `""` | Database, owner and password (*secret*, required unless `quayOperator`) |
| `quay.postgresVersion`, `clair.postgresVersion` | `17`, `15` | Crunchy major version (CloudNativePG: `cloudnativepg.imageName`) |
| `quay.extensions`, `clair.extensions` | `[pg_trgm]`, `[uuid-ossp]` | Extensions created in the database (Quay requires `pg_trgm`) |
| `quay.storage.size`, `storageClass` (and `clair.*`) | `100Gi`/`50Gi`, `""` | Data volume |
| `quay.resources`, `clair.resources` | 2 CPU / 8Gi–16Gi, 1 CPU / 4Gi–8Gi | Instance resources |
| `quay.parameters`, `clair.parameters` | `max_connections 2000`, `shared_buffers`, `effective_cache_size` | `postgresql.conf` |
| `quay.cloudnativepg.imageName`, `clair.cloudnativepg.imageName` | `""` | Empty: `ghcr.io/cloudnative-pg/postgresql:<postgresVersion>-system-trixie` with the community flavor (`system` images carry barman-cloud for the native backup method; pin a minor version in production), the operator default image with the edb flavor |
| `quay.cloudnativepg.serverName`, `clair.cloudnativepg.serverName` | `""` | Folder of the cluster in the backup bucket; empty: the cluster name. See Restore |
| `cloudnativepg.flavor` | `community` | `community` (`postgresql.cnpg.io`) or `edb` (`postgresql.k8s.enterprisedb.io`) |
| `cloudnativepg.topologyKey` | `kubernetes.io/hostname` | Anti-affinity topology key |

### Backup (`backup.*`)

| Value | Default | Description |
| --- | --- | --- |
| `enabled` | `true` | Continuous WAL archiving and scheduled backups of the chart managed databases |
| `s3.endpoint`, `port`, `region` | `""` | Endpoint without scheme (required), port (empty: 443), signature region (required with crunchy) |
| `s3.bucket` | `""` | Bucket (required), distinct from the registry bucket |
| `s3.accessKey`, `secretKey` | `""` | Credentials (*secret*, required) |
| `s3.caCert` | `""` | PEM of a private CA signing the endpoint |
| `s3.pathPrefix` | `""` | Prefix in the bucket, empty: the database namespace. Crunchy: `repo1-path /<prefix>/<cluster>/repo1`; CloudNativePG: `s3://<bucket>/<prefix>/<serverName>` |
| `retentionDays` | `14` | Crunchy `repo1-retention-full` (time); CloudNativePG `retentionPolicy` |
| `schedules.full`, `schedules.differential` | `0 1 * * 0`, `0 1 * * 1-6` | Cron (5 fields). Differential: crunchy only. CloudNativePG: one `ScheduledBackup` per cluster from `full`, `immediate: true` |
| `cloudnativepg.method` | `barmanObjectStore` | `barmanObjectStore`: native integration (deprecated since 1.26, functional, needs a `system` image). `plugin`: Barman Cloud Plugin (`ObjectStore` objects, plugin and cert-manager installed); the plugin does not feed `cnpg_collector_last_available_backup_timestamp`, so the backup age alerts are not rendered with it |
| `cloudnativepg.compression` | `gzip` | WAL and base backup compression: `gzip`, `bzip2`, `lz4` or `snappy` |

### Restore (`restore.*`)

| Value | Default | Description |
| --- | --- | --- |
| `enabled` | `false` | Bootstrap the clusters from a backup instead of initializing them (read at cluster creation only) |
| `pathPrefix` | `""` | CloudNativePG: prefix of the backups to restore from, empty: `backup.s3.pathPrefix` |
| `quay.source`, `clair.source` | `""` | Crunchy: `repo1-path` of the source (`/<prefix>/<cluster>/repo1`). CloudNativePG: Barman server name of the source (its cluster name by default) |
| `quay.target`, `clair.target` | `""` | Point in time `2026-10-15 14:00:00+00`; empty: end of the archive |
| `inPlace.enabled`, `inPlace.quay.target`, `inPlace.clair.target` | `false` | Crunchy only: in place restore of the running clusters, triggered by an annotation (see Restore) |

### OIDC (`oidc.*`)

| Value | Default | Description |
| --- | --- | --- |
| `enabled` | `false` | Renders `<SERVICENAME>_LOGIN_CONFIG` and `FEATURE_USER_CREATION: true` (accounts created at the first login of a provider user) |
| `internalAuthentication` | `true` | `true`: `AUTHENTICATION_TYPE: OIDC`, the provider is the internal authentication (team synchronization, `podman login` checked by the provider through the password grant, database accounts no longer log in with their password). `false`: `AUTHENTICATION_TYPE` stays `Database`, the provider is an additional login button (database accounts keep their password, no team synchronization, self registration possible) |
| `serviceName` | `SSO` | Prefix of the config block and label of the login button; the callback URL uses it in lower case: `https://<hostname>/oauth2/sso/callback` |
| `server` | `""` | Issuer URL with a trailing slash: `https://sso.example.com/realms/<realm>/` (required) |
| `clientId`, `clientSecret` | `quay`, `""` | Confidential client (*secret*, required) |
| `loginScopes` | `[openid, email, profile]` | `LOGIN_SCOPES` |
| `usernameClaim`, `emailClaim`, `groupClaim` | `preferred_username`, `email`, `groups` | `PREFERRED_USERNAME_CLAIM_NAME`, `VERIFIED_EMAIL_CLAIM_NAME`, `PREFERRED_GROUP_CLAIM_NAME` (empty: no group claim) |
| `teamSyncing`, `nonSuperuserTeamSyncingSetup` | `true`, `false` | `FEATURE_TEAM_SYNCING`, `FEATURE_NONSUPERUSER_TEAM_SYNCING_SETUP` (with `internalAuthentication` only) |
| `pkce` | `true` | `USE_PKCE` with `PKCE_METHOD: S256` |
| `caCert` | `""` | PEM of a private CA signing the provider (`extra_ca_cert_oidc.crt`) |

### Monitoring and network

| Value | Default | Description |
| --- | --- | --- |
| `monitoring.enabled` | `true` | `PodMonitor` of the instances (port `exporter` with crunchy, `metrics` with cloudnativepg) and the `PrometheusRule` |
| `monitoring.replicationLagBytes`, `replicationLagSeconds` | `104857600`, `60` | Thresholds of `QuayPostgresReplicationLag` (crunchy bytes, cloudnativepg seconds) |
| `monitoring.backupMaxAgeHours`, `fullBackupMaxAgeDays` | `36`, `8` | Thresholds of `QuayPostgresBackupTooOld`, `QuayPostgresFullBackupTooOld` (crunchy) |
| `monitoring.volumeUsagePercent` | `80` | Threshold of `QuayPostgresVolumeFull` |
| `networkPolicy.enabled` | `true` | Ingress policy on the database pods: pods of the namespace, the registry namespace on 5432, the operator namespaces, the monitoring namespaces on 9187 |
| `networkPolicy.monitoringNamespaces` | `[openshift-monitoring, openshift-user-workload-monitoring]` | Prometheus namespaces |
| `networkPolicy.operatorNamespaces` | `[]` | Database operator namespaces (CloudNativePG reaches every instance on 8000 and 5432); empty: `cnpg-system` (community), `openshift-operators` (edb), `dbOperator.subscription.namespace` (crunchy) |

## Procedures

### First super user

With `quay.userInitialize: true` the API creates the first account once (`quay.superUsers` must contain it):

```bash
curl -s -X POST https://quay.apps.ocp.example.com/api/v1/user/initialize -H 'Content-Type: application/json' \
  -d '{"username":"quayadmin","password":"<password>","email":"quayadmin@example.com","access_token":true}'
```

Keep the returned `access_token` (API). Then set `quay.userInitialize: false` and sync.

### Enable OIDC (Keycloak)

1. Keycloak: confidential client `quay`, standard flow, PKCE S256, *Direct access grants* enabled (password grant
   used by `podman login` with `internalAuthentication`), redirect URIs `https://<hostname>/oauth2/sso/callback`,
   `.../callback/attach`, `.../callback/cli`; a *Group Membership* mapper to the `groups` claim (without full path)
   for team synchronization, with *Add to userinfo* enabled (Quay reads the claims from the userinfo endpoint);
   client scopes `openid`, `email`, `profile`.
2. Add the Keycloak usernames of the administrators to `quay.superUsers`, as Quay normalizes them (lower case,
   characters outside `a-z0-9_` replaced by `_`, and a suffix such as `1` when the name is already taken by a
   database account: the bootstrap super user must not share its name with a Keycloak account). With
   `internalAuthentication` the database super user of the previous step no longer logs in with its password (its
   API token keeps working, keep it as the break glass access).
3. `oidc.enabled: true`, `oidc.server: https://sso.example.com/realms/<realm>/` (trailing slash, checked by the
   chart), `oidc.clientSecret` (*secret*), `oidc.caCert` when the provider certificate comes from a private CA. Sync:
   `quay-app` pods roll. A wrong issuer or client secret is caught by `config-tool validate` when the new pods start:
   they crash loop (`oc logs deploy/<name>-quay-app`), the previous pods keep serving, the `QuayRegistry` turns
   `Available=False` and Argo CD stays `Progressing`; fix the values and sync again.
4. Any user of the realm allowed on the client gets a Quay account at first login (`FEATURE_USER_CREATION`): restrict
   the client in Keycloak when needed. Team synchronization is set per team in the UI or the API
   (`POST /api/v1/organization/<org>/team/<team>/syncing` with `{"group_name": "<group as sent in the claim>"}`);
   members are synchronized at each login of a user.
5. `internalAuthentication: false` keeps the database accounts and their passwords (external login button only), at
   the price of team synchronization and of password self registration being open.

### Verify the database certificates (`verify-full`)

The first sync uses `require` because the CA of the clusters does not exist before they are created. Then:

```bash
# crunchy (one root CA per operator, shared by the clusters)      | cloudnativepg (one CA per cluster)
oc get secret quay-db-cluster-cert -n <db ns> -o jsonpath='{.data.ca\.crt}' | base64 -d   # cnpg: secret quay-db-ca
```

Put the PEM in `database.tls.caCert` (Vault + placeholder or values file), `database.tls.mode: verify-full`, sync.
The chart adds `sslrootcert` to `DB_URI` and `DB_CONNECTION_ARGS` (`/.postgresql/root.crt`, filled by the Quay image
from the `postgresql-client-certs` Secret), `extra_ca_cert_postgres-ca.crt` for Clair (`/var/run/certs/postgres-ca.crt`
in its connection strings). The `DB_URI` change makes the operator scale `quay-app` to zero while the upgrade job
runs (a few minutes): plan a maintenance window.

CA lifetimes: Crunchy signs with one root CA per operator (10 years, renewed in the last third of its validity:
refresh `caCert` then; the leaf certificates are renewed every year without any action). CloudNativePG generates one
CA per cluster, valid `CERTIFICATE_DURATION` days (90 by default) and renewed 7 days before expiry: with
`verify-full` either raise `CERTIFICATE_DURATION` in the operator configuration, or refresh `caCert` after each
renewal; concatenate the PEMs of the two clusters in `caCert`. Otherwise keep `require` (traffic is encrypted, the
server is not authenticated).

### Backups

Crunchy: pgBackRest archives WAL continuously, full backup on `schedules.full`, differential on
`schedules.differential`, retention `retentionDays` of full backups (older differential and WAL expire with them).

```bash
# status, per cluster
oc exec -n <db ns> -c database $(oc get pod -n <db ns> -l postgres-operator.crunchydata.com/cluster=quay-db,postgres-operator.crunchydata.com/role=master -o name) -- pgbackrest info --stanza=db
# on demand full backup
oc annotate postgrescluster quay-db -n <db ns> postgres-operator.crunchydata.com/pgbackrest-backup="$(date -u +%FT%TZ)"
```

CloudNativePG: continuous WAL archiving, one `ScheduledBackup` per cluster (`immediate: true`: a first backup at
creation), `retentionPolicy` in days.

```bash
oc get backup -n <db ns>                              # or: kubectl cnpg status quay-db -n <db ns>
oc create -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Backup
metadata: {name: quay-db-manual, namespace: <db ns>}
spec: {cluster: {name: quay-db}, method: barmanObjectStore}   # method: plugin with the plugin method
EOF
```

The registry bucket (layers) is not backed up by the chart: replicate or copy it (`aws s3 sync` without `--delete`)
at the rhythm of the database backups; Red Hat asks for the database and the bucket to be backed up together.
Alerts `QuayPostgresWalArchiveFailing`, `QuayPostgresBackupTooOld`, `QuayPostgresBackupsNotVisible` watch the chain.

Disabling backups on a running Crunchy cluster (`backup.enabled: false`) removes the `backups` section at once
(the `postgres-operator.crunchydata.com/authorizeBackupRemoval` annotation is only required for volume based
repositories, the chart uses an S3 repository); the content of the bucket is kept.

### Restore

Stop the registry first: `quay.stopped: true`, sync (quay-app, clair-app, quay-mirror at zero).

**Crunchy, in place (point in time, same clusters)**: `restore.inPlace.enabled: true` with the targets, sync, then
trigger each cluster:

```bash
oc annotate postgrescluster quay-db -n <db ns> postgres-operator.crunchydata.com/pgbackrest-restore="$(date -u +%FT%TZ)"
oc annotate postgrescluster clair-db -n <db ns> postgres-operator.crunchydata.com/pgbackrest-restore="$(date -u +%FT%TZ)"
```

Wait for the restore jobs, check the data, set `restore.inPlace.enabled: false`, then `quay.stopped: false`.

**Crunchy, new cluster** (disaster recovery, another namespace or another cluster): `restore.enabled: true`,
`restore.quay.source: /<old prefix>/quay-db/repo1`, `restore.clair.source: /<old prefix>/clair-db/repo1`, optional
targets, and a **new** `backup.s3.pathPrefix`: a new cluster must not write into the repository it restores from
(the chart refuses it). `dataSource.pgbackrest` is read at creation only: for an existing cluster, delete it (and its
PVCs) before the sync, or restore in place.

**CloudNativePG**: `restore.enabled: true`, `restore.quay.source: <server name of the source>` (its cluster name by
default), `restore.clair.source`, optional `restore.pathPrefix` when the backups live under another prefix, optional
targets. The new cluster must archive to an empty location: either a new cluster name, or the same name with
`database.quay.cloudnativepg.serverName: quay-db-r1` (and `clair-db-r1`); the chart refuses a source equal to the
cluster's own server name. `bootstrap.recovery` is read at creation only (delete the `Cluster` first to recreate it).

After a restore under a new cluster name, `DB_URI` and the Clair connection strings follow `database.*.name`
automatically. End with `quay.stopped: false`.

### Maintenance

| Need | How |
| --- | --- |
| Rotate a database password | Crunchy: change the value (Vault, hard refresh, sync: the pguser Secret and `DB_URI` change together), then at once `oc patch secret quay-db-pguser-quay -n <db ns> --type json -p '[{"op":"remove","path":"/data/verifier"}]'` so that the operator recomputes the SCRAM verifier; the upgrade job started by the `DB_URI` change fails on authentication until then and is recreated by the operator. CloudNativePG: the `<cluster>-owner` Secret is reloaded and the role updated by `managed.roles`. In both cases the new `DB_URI` scales `quay-app` to zero during the upgrade job |
| Rotate `SECRET_KEY` | Allowed (sessions and tokens of the UI are invalidated). Never rotate `DATABASE_SECRET_KEY` |
| Quay update | Approve the InstallPlan in a maintenance window: the operator scales `quay-app` to zero while the database migrations run. Then pin `operator.subscription.version` / `csv` to the CSV that took your backups |
| Database operator update | Approve the InstallPlan: rolling restart, replicas first, then switchover |
| Resize a data volume | Increase `database.*.storage.size` (StorageClass with volume expansion) |
| Stop the registry | `quay.stopped: true` |
| Change `database.*.parameters` | Applied by the operator (Patroni / CloudNativePG reload, restart when the parameter needs it) |

### Monitoring

Alerts (`PrometheusRule <quay.name>-postgres`, labels `severity` and `app: quay`): `QuayPostgresNoPrimary`,
`QuayPostgresNoReplica`, `QuayPostgresReplicationLag`, `QuayPostgresWalArchiveFailing`, `QuayPostgresBackupTooOld`,
`QuayPostgresFullBackupTooOld` (crunchy), `QuayPostgresBackupsNotVisible`, `QuayPostgresConnections` (crunchy),
`QuayPostgresInstanceDown` (cloudnativepg), `QuayPostgresVolumeFull`. Route them with an `AlertmanagerConfig` or the
cluster Alertmanager. The Quay operator adds its own `ServiceMonitor` and rules (`QuayPodFrequentlyRestarting`) in the
registry namespace. `QuayPostgresNoReplica` is rendered when `database.replicas` is above 1, the backup age alerts
when the backups do not go through the Barman Cloud Plugin.

The Quay operator labels the registry namespace `openshift.io/cluster-monitoring=true` (so does the STARTX `project`
chart): the platform Prometheus scrapes it, and Red Hat lists user objects in such namespaces as unsupported. Give the
databases their own namespace (`database.namespace`, `database.createNamespace`): their `PodMonitor` and alerts stay
with the user workload monitoring stack. Metrics are on port `9187` of every instance (`pg_cluster` and `role` labels
added by the relabelings).

## Tests

`test/run.sh` (in the repository, next to the chart) lints the chart, renders 38 combinations of modes, applies every
rendering to a local kube-apiserver loaded with the CRDs of the Quay, Crunchy, CloudNativePG, EDB, Barman and Argo CD
operators (client side and server side dry run), checks the generated content (`DB_URI`, bundles, restore and TLS
objects, network policies, placeholders left verbatim), the Argo CD examples (AppProject, Applications, ApplicationSet
and its `HELM_VALUES` round trip, plugin, health patch) and 30 invalid combinations that must be refused with an
explicit message.
The EDB flavor and the Barman Cloud Plugin method are validated against their CRDs but were not exercised against the
running operators.

## Default values

Default values deploy a registry named `registry` with external S3 storage, two Crunchy clusters (two instances
each), backups to S3, Clair, mirroring, HPA, monitoring and network policies, OIDC disabled; the required secrets
and endpoints must be supplied (the rendering says which one is missing).

```bash
helm install cluster-quay-ha startx/cluster-quay-ha -n quay -f my-values.yaml
```

## Others values availables

- **examples/argocd/values-example.yaml** : complete values file of an environment (external S3, Crunchy in a
  dedicated namespace, pgBackRest backups, OIDC ready to switch on, Argo CD Vault Plugin placeholders), the file a Git
  repository of the environment holds for `examples/argocd/applicationset.yaml`

## History

| Release  | Date       | Description                                                                                            |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| 21.3.0   | 2026-10-19 | First release: HA Quay with external/managed S3, Crunchy or CloudNativePG databases, OIDC, backup and restore |

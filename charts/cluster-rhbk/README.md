# ![cluster-rhbk](https://helm-repository.readthedocs.io/en/latest/img/cluster-rhbk.svg "Cluster Chart : RHBK") Cluster Chart : RHBK
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--rhbk-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+rhbk+startx)

This helm chart is used to deploy the Red Hat build of Keycloak (RHBK), the successor of Red Hat Single Sign-On, managed by
the `rhbk-operator`. It installs the operator, a `Keycloak` instance (API `k8s.keycloak.org/v2beta1`) with its database
and bootstrap admin secrets, an OpenShift `Route` in front of it, and `KeycloakRealmImport` objects for the realms.

For demo environments the chart can also deploy a single pod PostgreSQL database. In production, Keycloak connects to an
external database or to a PostgreSQL cluster managed by
[cluster-percona](https://helm-repository.readthedocs.io/en/latest/charts/cluster-percona). Secrets are rendered from
the values, or sourced from an external store with the External Secrets Operator.

This chart replaces [cluster-sso](https://helm-repository.readthedocs.io/en/latest/charts/cluster-sso), which is based on
the Red Hat Single Sign-On 7.6 operator (API `keycloak.org/v1alpha1`), no longer developed.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

| Requirement | Detail |
| --- | --- |
| OpenShift 4.17+ (Kubernetes 1.30+) | `kubeVersion` of the chart, tested on OpenShift 4.22 |
| Red Hat build of Keycloak operator 26.6 | `redhat-operators` catalog, package `rhbk-operator`, channel `stable-v26.6`. Installed by the `operator` sub-chart in the namespace of the instances (OwnNamespace, the operator cannot watch all namespaces) |
| API version | `k8s.keycloak.org/v2beta1` is the storage version of the 26.6 operator. With an older channel such as `stable-v26.4`, set `rhbk.apiVersion: k8s.keycloak.org/v2alpha1` and the matching `providedAPIs` |
| Network policy | The 26.6 operator creates the NetworkPolicy `<rhbk.name>-network-policy` on the Keycloak pods. HTTP(S) and management ports are open to every source, the router included, unless rules are set. Cluster (JGroups) ports are restricted to the Keycloak pods. Restrict it with `spec.networkPolicy.httpRules` / `httpsRules` / `managementRules`, or disable it with `spec.networkPolicy.enabled: false` |
| Database | PostgreSQL reachable from the Keycloak pods. `database.enabled` deploys a development instance (image `registry.redhat.io/rhel9/postgresql-16`, pulled with the cluster pull secret) |
| FIPS | The operator CSV declares `features.operators.openshift.io/fips-compliant: "false"`. Keycloak runs on a FIPS enabled cluster (tested on OpenShift 4.22), but the RHBK image does not ship the BouncyCastle FIPS providers. A FIPS compliant deployment needs a custom image with these providers (`spec.image`), the `fips` feature and `fips-mode: strict` (see the [FIPS guide](https://www.keycloak.org/server/fips)) |
| Secrets | Database and admin passwords are expected as [Argo CD Vault Plugin](https://argocd-vault-plugin.readthedocs.io/) placeholders (`<path:kv/data/...#key>`), from a values file kept out of Git, or from the External Secrets Operator (`externalSecret.enabled`). The `startx` values files only carry demo secrets (database password, and the grafana client secret of `values-startx_noinfra-grafana.yaml`) |

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
helm show chart startx/cluster-rhbk
```

### 4. Install this chart

```bash
helm install cluster-rhbk startx/cluster-rhbk
```

## Default values

Complete deployment of a project with the following characteristics, using the `values-startx.yaml` values :

- 1 **namespace:** named **default-rhbk** without constraints
- 1 **operator:** named **rhbk-operator** configured with
  - The **stable-v26.6** channel of the redhat catalog, manual install plan approval
  - The **v26.6.9-opr.1** version
  - Deployed under the **default-rhbk** project (OwnNamespace OperatorGroup)
- 1 **database:** named **startx-postgresql** (development only), PostgreSQL 16, a **2Gi** data volume
- 1 **keycloak:** named **startx** configured with
  - one instance, database credentials read from the Secret **startx-db-secret**
  - HTTP enabled behind the route, `X-Forwarded-*` headers trusted, hostname taken from the request
  - the operator ingress disabled
- 1 **route:** named **startx** with edge TLS termination and a generated host
- 1 **realm import:** named **startx** with a public OpenID Connect client **startx-demo**

```bash
# Create the project
helm install cluster-rhbk-project startx/cluster-rhbk -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml --set project.enabled=true
# Deploy the rhbk operator
helm install cluster-rhbk-operator startx/cluster-rhbk -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml --set operator.enabled=true && sleep 30
# Approve the first install plan (manual approval)
oc patch installplan $(oc get installplan -n default-rhbk -o jsonpath='{.items[0].metadata.name}') -n default-rhbk --type merge -p '{"spec":{"approved":true}}'
# Deploy the database, the keycloak instance, its route and the startx realm
helm install cluster-rhbk-instance startx/cluster-rhbk -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml --set database.enabled=true,rhbk.enabled=true,route.enabled=true,rhbk_realms.enabled=true
```

## Values files

- **startx** : rhbk operator on infra nodes, demo instance, development database and startx realm (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml))
- **startx_noinfra** : the same without the infra node placement of the operator (see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx_noinfra.yaml))
- **startx_noinfra-grafana** : the same, plus a confidential `grafana` client in the startx realm, used by the `values-startx_noinfra-rhbk.yaml` values of [cluster-grafana](https://helm-repository.readthedocs.io/en/latest/charts/cluster-grafana) (see [values-startx_noinfra-grafana.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx_noinfra-grafana.yaml))

```bash
helm install cluster-rhbk startx/cluster-rhbk -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml
```

## Values

### Chart level

| Key | Default | Description |
| --- | --- | --- |
| `context.*` | `default-rhbk` app | STARTX deployment context (labels of every object) |
| `externalSecretDefaults` | `external-secrets.io/v1`, `1h`, `ClusterSecretStore` | Defaults for every secret sourced from an external store. `secretStoreRef.name` is required as soon as a secret uses `externalSecret` |

### Development database (`database`)

| Key | Default | Description |
| --- | --- | --- |
| `enabled` | `false` | Deploy a single pod PostgreSQL StatefulSet and its Service (no replication, no backup) |
| `name` | `<rhbk.name>-postgresql` | Name of the StatefulSet and of the Service, used as `spec.db.host` |
| `image` | `registry.redhat.io/rhel9/postgresql-16:latest` | PostgreSQL image |
| `database` | `keycloak` | Database created at initialization, used as `spec.db.database` |
| `storageClassName`, `size` | `""`, `2Gi` | Data volume (empty class: default StorageClass of the cluster) |
| `resources` | 100m / 256Mi, limit 512Mi | Resources of the database container |

The database reads its credentials from the database Secret of the Keycloak instance (`rhbk.dbSecret`).

### Keycloak instance (`rhbk`)

| Key | Default | Description |
| --- | --- | --- |
| `enabled`, `hooked` | `false`, `false` | Render the `Keycloak` and its secrets. `hooked` renders the `Keycloak` as a post-install hook |
| `apiVersion` | `k8s.keycloak.org/v2beta1` | API version of the `Keycloak` and `KeycloakRealmImport` objects |
| `name` | `default` | Name of the `Keycloak`. The operator names its objects after it (`<name>-service`, `<name>-initial-admin`...) |
| `dbSecret.enabled`, `name`, `username`, `password` | `false`, `<name>-db-secret`, `keycloak`, `""` | Database Secret (keys `username` and `password`) referenced by `spec.db`. `password` is required unless `externalSecret` is used |
| `adminSecret.enabled`, `name`, `username`, `password` | `false`, `<name>-bootstrap-admin`, `admin`, `""` | Temporary admin Secret referenced by `spec.bootstrapAdmin.user.secret`. When disabled, the operator generates `<name>-initial-admin` (user `temp-admin`) |
| `*.externalSecret.enabled`, `remoteRefs` | `false`, `{}` | Produce the Secret with an `ExternalSecret` instead (keys `username` and `password` required in `remoteRefs`. `data`, `dataFrom` and `template` are also accepted) |
| `spec` | one instance, HTTP, non strict hostname, `xforwarded` proxy headers | `Keycloak` spec merged over a base generated by the chart (see below) |

The chart builds part of the `Keycloak` spec from the other values, then merges `rhbk.spec` over it. Keys set in
`rhbk.spec` win.

| Generated key | When |
| --- | --- |
| `db.vendor: postgres`, `db.usernameSecret`, `db.passwordSecret` | `rhbk.dbSecret.enabled` or `database.enabled` |
| `db.host`, `db.port`, `db.database` | `database.enabled` |
| `bootstrapAdmin.user.secret` | `rhbk.adminSecret.enabled` |
| `ingress.enabled: false` | `route.enabled` |

### Route (`route`)

| Key | Default | Description |
| --- | --- | --- |
| `enabled` | `false` | Expose the instance with a Route to the `<rhbk.name>-service` Service, and disable the operator ingress |
| `name`, `host` | `rhbk.name`, `""` | Name of the route, and its host (empty: generated by OpenShift) |
| `termination` | `edge` | `edge` (to the `http` port, needs `http.httpEnabled: true`), `reencrypt` or `passthrough` (to the `https` port, needs `http.tlsSecret`) |
| `insecureEdgeTerminationPolicy`, `targetPort`, `annotations` | `Redirect`, `""`, `{}` | Plain HTTP policy, explicit target port, extra annotations |

### Realm imports (`rhbk_realms`)

| Key | Default | Description |
| --- | --- | --- |
| `enabled` | `false` | Render the `KeycloakRealmImport` objects |
| `list[].name`, `enabled` | `myrealm`, `true` | Name of the import, and its switch |
| `list[].keycloakCRName` | `rhbk.name` | Target `Keycloak` in the same namespace |
| `list[].placeholders` | `{}` | `${KEY}` placeholders of the realm resolved from Secrets (`KEY: {secret: {name, key}}`) |
| `list[].realm` | minimal realm | Full `RealmRepresentation` (YAML) |
| `secrets[].name`, `enabled`, `data` | `[]` | Secrets read by the placeholders (client secrets...), rendered at wave 1 before the imports |
| `secrets[].externalSecret.enabled`, `remoteRefs` | `false`, `{}` | Produce the Secret with an `ExternalSecret` instead |

A `KeycloakRealmImport` only creates a realm. It never updates or overwrites an existing one, so changing a realm in the
values after its first import has no effect. Apply later changes with the admin console or the admin API, or delete the
realm before a new import.

### Sub-charts

`project` (namespace) and `operator` (OLM subscription and OperatorGroup of the rhbk operator) are the STARTX basic
charts, see their own documentation. The chart objects use Argo CD sync waves: Secrets and ExternalSecrets (1),
development database (10), `Keycloak` (15), `Route` (20), `KeycloakRealmImport` (30).

## Procedures

### Admin console access

```bash
# URL of the admin console
echo "https://$(oc get route startx -n default-rhbk -o jsonpath='{.spec.host}')/admin/"
# temporary admin credentials generated by the operator (rhbk.adminSecret disabled)
oc get secret startx-initial-admin -n default-rhbk -o jsonpath='{.data.username}' | base64 -d; echo
oc get secret startx-initial-admin -n default-rhbk -o jsonpath='{.data.password}' | base64 -d; echo
```

The bootstrap admin is temporary. Create a permanent administrator in the master realm (or federate an identity
provider), then remove the temporary user.

### Production database with cluster-percona

Deploy the database with [cluster-percona](https://helm-repository.readthedocs.io/en/latest/charts/cluster-percona) in
the `default-rhbk` namespace and keep `database.enabled: false`. Then point the `Keycloak` to the Secret generated by
the Percona operator (`<cluster>-pguser-<user>`, keys `user` and `password`):

```yaml
rhbk:
  dbSecret:
    enabled: false
  spec: |
    instances: 2
    db:
      vendor: postgres
      host: keycloak-db-pgbouncer
      database: keycloak
      usernameSecret:
        name: keycloak-db-pguser-keycloak
        key: user
      passwordSecret:
        name: keycloak-db-pguser-keycloak
        key: password
    http:
      httpEnabled: true
    hostname:
      hostname: https://sso.apps.example.com
    proxy:
      headers: xforwarded
```

### End to end TLS (reencrypt)

Let the OpenShift service CA issue the certificate of the Keycloak Service and serve HTTPS only, behind a `reencrypt`
route (the router trusts the service CA):

```yaml
rhbk:
  spec: |
    http:
      httpEnabled: false
      tlsSecret: startx-tls
      annotations:
        service.beta.openshift.io/serving-cert-secret-name: startx-tls
    hostname:
      hostname: https://sso.apps.example.com
    proxy:
      headers: xforwarded
route:
  host: sso.apps.example.com
  termination: reencrypt
```

### Connect Grafana (cluster-grafana)

`values-startx_noinfra-grafana.yaml` adds a confidential `grafana` client to the startx realm. It goes with the
`values-startx_noinfra-rhbk.yaml` values of [cluster-grafana](https://helm-repository.readthedocs.io/en/latest/charts/cluster-grafana):

- client secret read from the Secret `startx-grafana-client` (`rhbk_realms.secrets`, placeholder `${GRAFANA_CLIENT_SECRET}`),
  identical to the `oidc.clientSecret` of cluster-grafana
- redirect URI `https://<grafana host>/login/generic_oauth`, post logout redirect URI `https://<grafana host>/login`, PKCE
- client roles `grafanaadmin`, `admin`, `editor` and `viewer`, copied by a client role mapper into a top-level `roles`
  claim of the ID token, the access token and the userinfo, read by the Grafana `role_attribute_path`

Replace `apps.example.com` with the apps domain of the cluster in both values files, then assign the client roles to the
users (Users > Role mapping > Assign role > Filter by clients). A user without any role logs in as Grafana `Viewer`.

To check the claims of a client without an application, use Clients > `<client>` > Client scopes > Evaluate. Don't use
the `admin-cli` client for this check: since Keycloak 26.0 it uses lightweight access tokens (no `sub`, no
`preferred_username`).

### Operator update

The subscription uses a manual install plan approval and a `startingCSV` (`operator.subscription.version`). The
`startingCSV` only pins the first installation. Right after it, OLM creates a new install plan for the next release of
the channel and leaves it unapproved (the operator `skipRange` usually points it to the latest z-stream, skipping the
ones in between). Leave it unapproved to stay on the pinned release.

To upgrade, approve that pending install plan. Changing `operator.subscription.version` alone does not trigger any
upgrade. Afterwards, set `operator.subscription.version` to the installed release so that a fresh installation gets the
same version. For a new minor stream, change `operator.subscription.operator.channel` first. If the `Keycloak` uses the
default image, the operator upgrade also upgrades Keycloak, so back up the database first.

```bash
oc get installplan -n default-rhbk
oc patch installplan <name> -n default-rhbk --type merge -p '{"spec":{"approved":true}}'
```

### Uninstall

Remove the waves in reverse order (tested on OpenShift 4.22 with the 26.6 operator):

```bash
helm uninstall cluster-rhbk-instance
helm uninstall cluster-rhbk-operator
helm uninstall cluster-rhbk-project
oc wait --for=delete namespace/default-rhbk --timeout=300s
```

1. Instance: the `Keycloak` and `KeycloakRealmImport` objects have no finalizer. The operator deletes the objects it
   generated (StatefulSet, Services, NetworkPolicy, `<name>-initial-admin` and realm Secrets), and the service CA
   certificate Secret goes away with its Service. The PVC of the development database (`data-<database name>-0`)
   is kept. Its database still holds the realms, and the import of an existing realm is ignored on a new installation,
   so delete the PVC (or the namespace) to start from scratch.
2. Operator: the Subscription, the OperatorGroup and the install plans are deleted, but the CSV stays (phase `Failed`,
   reason `NoOperatorGroup`) and its operator pod keeps running. If the namespace is kept, delete the CSV with
   `oc delete csv <csv> -n default-rhbk`.
3. Project: the namespace is deleted with everything left in it (CSV, operator pod, PVC).

The `keycloaks.k8s.keycloak.org` and `keycloakrealmimports.k8s.keycloak.org` CRDs stay on the cluster, since OLM never
removes the CRDs of an operator.

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-rhbk/examples/argocd/
oc apply -k .
```

### Applications

The `examples/argocd` folder holds the AppProject and the three Applications (project, operator, app) of the standard
pattern, using `values-startx_noinfra.yaml`.

| Application             | Wave   | Enabled flags                                                                    | Destination    |
| ----------------------- | ------ | -------------------------------------------------------------------------------- | -------------- |
| `cluster-rhbk-project`  | `"1"`  | `project.enabled: true`, all others `false`                                      | `default-rhbk` |
| `cluster-rhbk-operator` | `"5"`  | `operator.enabled: true`, all others `false`                                     | `default-rhbk` |
| `cluster-rhbk-app`      | `"10"` | `database`, `rhbk`, `route`, `rhbk_realms` enabled, `project`/`operator` `false` | `default-rhbk` |

The `-operator` and `-app` Applications carry the `resources-finalizer.argocd.argoproj.io` finalizer, the `-project`
Application has none. The first install plan of the operator has to be approved (see Operator update) before
`cluster-rhbk-app` can sync. Delete the Applications in reverse order (`-app`, then `-operator`, then `-project`) so
that the operator deletes the objects it generated before it is removed.

## History

| Release  | Date       | Description                                            |
| -------- | ---------- | ------------------------------------------------------ |
| 21.3.361 | 2026-11-16 | Initial chart creation |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |
| 21.3.398 | 2026-11-21 | project: dockercfg existingSecret; chaos-pipeline: empty default for scenarios, optional ClusterOperator final check; chaos schemas regenerated |
| 21.3.410 | 2026-11-22 | full repository release: README conventions (Values files, Deploy with ArgoCD), conventions page |
| 21.3.412 | 2026-11-22 | full repository release: internal pins on the previous published version (ADR-0006) |

# ![cluster-rhbk](https://helm-repository.readthedocs.io/en/latest/img/cluster-rhbk.svg "Cluster Chart : RHBK") Cluster Chart : RHBK
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--rhbk-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+rhbk+startx)

This helm chart is used to deploy the Red Hat build of Keycloak (RHBK), the successor of Red Hat Single Sign-On, managed by
the `rhbk-operator`. It installs the operator, a `Keycloak` instance (API `k8s.keycloak.org/v2beta1`) wired to its
database and bootstrap admin secrets, an OpenShift `Route` exposing it, and `KeycloakRealmImport` objects describing the
realms. A single pod development PostgreSQL database can be deployed by the chart for demo environments; production
instances connect to an external database or to a PostgreSQL cluster managed by
[cluster-percona](https://helm-repository.readthedocs.io/en/latest/charts/cluster-percona). The secrets are rendered from
the values, or sourced from an external store with the External Secrets Operator.

This chart replaces [cluster-sso](https://helm-repository.readthedocs.io/en/latest/charts/cluster-sso), based on the
Red Hat Single Sign-On 7.6 operator (API `keycloak.org/v1alpha1`) which is no longer developed.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

| Requirement | Detail |
| --- | --- |
| OpenShift 4.19+ (Kubernetes 1.30+) | `kubeVersion` of the chart |
| Red Hat build of Keycloak operator 26.6 | `redhat-operators` catalog, package `rhbk-operator`, channel `stable-v26.6`, installed by the `operator` sub-chart in the namespace of the instances (OwnNamespace: the operator does not support watching all namespaces) |
| API version | `k8s.keycloak.org/v2beta1` is the storage version of the 26.6 operator; set `rhbk.apiVersion: k8s.keycloak.org/v2alpha1` (and the matching `providedAPIs`) with an older channel such as `stable-v26.4` |
| Network policy | The 26.6 operator creates the NetworkPolicy `<rhbk.name>-network-policy` on the Keycloak pods: HTTP(S) and management ports open to every source (the router included) unless rules are set, cluster (JGroups) ports restricted to the Keycloak pods. Restrict it with `spec.networkPolicy.httpRules` / `httpsRules` / `managementRules`, or disable it with `spec.networkPolicy.enabled: false` |
| Database | PostgreSQL reachable from the Keycloak pods. `database.enabled` deploys a development instance (image `registry.redhat.io/rhel9/postgresql-16`, pulled with the cluster pull secret) |
| Secrets | Database and admin passwords are expected as [Argo CD Vault Plugin](https://argocd-vault-plugin.readthedocs.io/) placeholders (`<path:kv/data/...#key>`), supplied by a values file kept out of Git, or sourced with the External Secrets Operator (`externalSecret.enabled`). The `startx` values files carry a demo database password only |

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

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **default-rhbk** without constraints
- 1 **operator:** named **rhbk-operator** configured with
  - The **stable-v26.6** channel of the redhat catalog, manual install plan approval
  - The **v26.6.9-opr.1** version
  - Deployed under the **default-rhbk** project (OwnNamespace OperatorGroup)
- 1 **database:** named **startx-postgresql** (development only), PostgreSQL 16, a **2Gi** data volume
- 1 **keycloak:** named **startx** configured with
  - one instance, database credentials read from the Secret **startx-db-secret**
  - HTTP enabled behind the route, `X-Forwarded-*` headers trusted, hostname derived from the request
  - the operator ingress disabled
- 1 **route:** named **startx** with edge TLS termination and a generated host
- 1 **realm import:** named **startx** with a public OpenID Connect client **startx-demo**

```bash
# Create the project
helm install cluster-rhbk-project startx/cluster-rhbk -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml --set project.enabled=true
# Deploy the rhbk operator
helm install cluster-rhbk-operator startx/cluster-rhbk -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml --set operator.enabled=true
# Approve the first install plan (manual approval)
oc patch installplan $(oc get installplan -n default-rhbk -o jsonpath='{.items[0].metadata.name}') -n default-rhbk --type merge -p '{"spec":{"approved":true}}'
# Deploy the database, the keycloak instance, its route and the startx realm
helm install cluster-rhbk-instance startx/cluster-rhbk -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml --set database.enabled=true,rhbk.enabled=true,route.enabled=true,rhbk_realms.enabled=true
```

## Other available values

- **startx** : rhbk operator on infra nodes, demo instance, development database and startx realm (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml))
- **startx_noinfra** : the same without the infra node placement of the operator (see [values-startx_noinfra.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx_noinfra.yaml))

```bash
helm install cluster-rhbk startx/cluster-rhbk -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-rhbk/values-startx.yaml
```

## Values

### Chart level

| Key | Default | Description |
| --- | --- | --- |
| `context.*` | `default-rhbk` app | STARTX deployment context (labels of every object) |
| `externalSecretDefaults` | `external-secrets.io/v1`, `1h`, `ClusterSecretStore` | Defaults of every secret sourced from an external store; `secretStoreRef.name` is required as soon as a secret uses `externalSecret` |

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
| `enabled`, `hooked` | `false`, `false` | Render the `Keycloak` and its secrets; render the `Keycloak` as a post-install hook |
| `apiVersion` | `k8s.keycloak.org/v2beta1` | API version of the `Keycloak` and `KeycloakRealmImport` objects |
| `name` | `default` | Name of the `Keycloak`; the operator names its objects after it (`<name>-service`, `<name>-initial-admin`...) |
| `dbSecret.enabled`, `name`, `username`, `password` | `false`, `<name>-db-secret`, `keycloak`, `""` | Database Secret (keys `username` and `password`) referenced by `spec.db`; `password` is required unless `externalSecret` is used |
| `adminSecret.enabled`, `name`, `username`, `password` | `false`, `<name>-bootstrap-admin`, `admin`, `""` | Temporary admin Secret referenced by `spec.bootstrapAdmin.user.secret`. Disabled: the operator generates `<name>-initial-admin` (user `temp-admin`) |
| `*.externalSecret.enabled`, `remoteRefs` | `false`, `{}` | Produce the Secret with an `ExternalSecret` instead (keys `username` and `password` required in `remoteRefs`; `data`, `dataFrom` and `template` are also accepted) |
| `spec` | one instance, HTTP, non strict hostname, `xforwarded` proxy headers | `Keycloak` spec merged over a base generated by the chart (see below) |

The chart generates part of the `Keycloak` spec from the other values, and merges `rhbk.spec` over it (keys of
`rhbk.spec` win):

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
| `name`, `host` | `rhbk.name`, `""` | Name of the route; host (empty: generated by OpenShift) |
| `termination` | `edge` | `edge` (to the `http` port, needs `http.httpEnabled: true`), `reencrypt` or `passthrough` (to the `https` port, needs `http.tlsSecret`) |
| `insecureEdgeTerminationPolicy`, `targetPort`, `annotations` | `Redirect`, `""`, `{}` | Plain HTTP policy, explicit target port, extra annotations |

### Realm imports (`rhbk_realms`)

| Key | Default | Description |
| --- | --- | --- |
| `enabled` | `false` | Render the `KeycloakRealmImport` objects |
| `list[].name`, `enabled` | `myrealm`, `true` | Name of the import, switch |
| `list[].keycloakCRName` | `rhbk.name` | Target `Keycloak` in the same namespace |
| `list[].placeholders` | `{}` | `${KEY}` placeholders of the realm resolved from Secrets (`KEY: {secret: {name, key}}`) |
| `list[].realm` | minimal realm | Full `RealmRepresentation` (YAML) |

### Sub-charts

`project` (namespace) and `operator` (OLM subscription and OperatorGroup of the rhbk operator) are the STARTX basic
charts; see their documentation. The chart objects use Argo CD sync waves: Secrets and ExternalSecrets (1), development
database (10), `Keycloak` (15), `Route` (20), `KeycloakRealmImport` (30).

## Procedures

### Admin console access

```bash
# URL of the admin console
echo "https://$(oc get route startx -n default-rhbk -o jsonpath='{.spec.host}')/admin/"
# temporary admin credentials generated by the operator (rhbk.adminSecret disabled)
oc get secret startx-initial-admin -n default-rhbk -o jsonpath='{.data.username}' | base64 -d; echo
oc get secret startx-initial-admin -n default-rhbk -o jsonpath='{.data.password}' | base64 -d; echo
```

The bootstrap admin is temporary: create a permanent administrator in the master realm (or federate an identity
provider), then remove the temporary user.

### Production database with cluster-percona

Deploy the database with [cluster-percona](https://helm-repository.readthedocs.io/en/latest/charts/cluster-percona) in
the `default-rhbk` namespace, keep `database.enabled: false`, and point the `Keycloak` to the Secret generated by the
Percona operator (`<cluster>-pguser-<user>`, keys `user` and `password`):

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

Let the OpenShift service CA issue the certificate of the Keycloak Service, serve HTTPS only, and use a `reencrypt`
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

### Operator update

The subscription uses a manual install plan approval and a `startingCSV` (`operator.subscription.version`). The
`startingCSV` only pins the first installation: right after it, OLM creates a new install plan, left unapproved, for
the next release of the channel (the operator `skipRange` usually points it to the latest z-stream, skipping the
intermediate ones). Leave it unapproved to stay on the pinned release.

To upgrade, approve that pending install plan; changing `operator.subscription.version` alone does not trigger any
upgrade. Then set `operator.subscription.version` to the installed release, so that a fresh installation gets the same
version. For a new minor stream, change `operator.subscription.operator.channel` first. When the `Keycloak` uses the
default image, the operator upgrade also upgrades Keycloak: back up the database first.

```bash
oc get installplan -n default-rhbk
oc patch installplan <name> -n default-rhbk --type merge -p '{"spec":{"approved":true}}'
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-rhbk/examples/argocd/
oc apply -k .
```

### Applications

The `examples/argocd` folder holds the AppProject and the three Applications of the standard pattern, using
`values-startx_noinfra.yaml`:

| Application | Wave | Enabled flags | Finalizer |
| --- | --- | --- | --- |
| `cluster-rhbk-project` | `1` | `project` | no |
| `cluster-rhbk-operator` | `5` | `operator` | yes |
| `cluster-rhbk-app` | `10` | `database`, `rhbk`, `route`, `rhbk_realms` | yes |

Every Application explicitly disables the flags of the other waves. The first install plan of the operator must be
approved (see Operator update) before the `cluster-rhbk-app` Application can sync. Delete the Applications in reverse
order (`-app`, then `-operator`, then `-project`) so that the operator removes the finalizers of its objects.

## History

| Release  | Date       | Description                                            |
| -------- | ---------- | ------------------------------------------------------ |
| 21.3.361 | 2026-11-16 | Initial chart creation |

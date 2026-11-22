# ![cluster-auth](https://helm-repository.readthedocs.io/en/latest/img/cluster-auth.svg "Cluster Chart : Auth") Cluster Chart : Auth
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--auth-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+auth+startx)

This helm chart is used to configure Auth at the cluster level.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like auth.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://helm-repository.readthedocs.io) for
more information on how to use these resources.

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
helm show chart startx/cluster-auth
```

### 4. Install this chart

```bash
helm install cluster-auth startx/cluster-auth
```

## Default values

Complete configuration of the OCP authentification with the following characteristics :

- 3 auth templates in **openshift-config**
  - 1 template login set to **default-login**
  - 1 template errors set to **default-errors**
  - 1 template providers set to **default-providers**
- 1 auth backend set to **htpasswd** named **default-htpasswd** with
  - 1 user **dev**

```bash
# base configuration running default configuration
helm install cluster-auth startx/cluster-auth
```

## Values files

- **startx** : Startx auth cluster wide service configuration using startx group (dev, devops and ops) (see [values-startx.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-auth/values-startx.yaml))
  - 3 auth templates in **openshift-config**
    - 1 template login set to **startx-login**
    - 1 template errors set to **startx-errors**
    - 1 template providers set to **startx-providers**
  - 1 auth backend set to **htpasswd** named **default-htpasswd** with
    - 1 user **dev**
    - 1 user **devops**
    - 1 user **ops**
    - 1 user **admin**

```bash
helm install cluster-auth startx/cluster-auth -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-auth/values-startx.yaml
```

- **startx-mg** : Startx gitops cluster wide service configuration using startx group (dev, devops and ops) (see [values-mg.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-auth/values-mg.yaml))

```bash
helm install cluster-auth startx/cluster-auth -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-auth/values-mg.yaml
```

## Deploy with ArgoCD

### Deploy via ArgoCD Application

`cluster-auth` is a configuration-only chart (no operator, no dedicated namespace). It configures the cluster `OAuth` CR and related secrets in `openshift-config`. `auth.namespace` sets the namespace of those Secrets and ConfigMaps; it does not apply to the `OAuth` resource, which is cluster scoped and rendered without a namespace. A single Application is sufficient:

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-auth/examples/argocd/
oc apply -k .
```

The automated sync policy keeps the `OAuth` configuration aligned with the chart values.

With `manageSubresource: true` (used by `values-startx_noinfra.yaml`) the chart also writes the Secrets the
OpenShift authentication operator copies into `openshift-authentication` (`v4-0-config-user-idp-N-file-data`,
`v4-0-config-user-template-*`). The operator rewrites them after each sync, so the example Application declares
an `ignoreDifferences` on those Secrets : without it they show as permanently OutOfSync.

### Let another owner manage OAuth/cluster

A cluster has exactly one `OAuth/cluster` resource. When another chart or tool owns it (the consumer only references the
htpasswd and template Secrets of this chart), set `auth.oauth.enabled: false` in the values of the Application: the
`OAuth` resource is not rendered, while the Secrets and ConfigMaps of `auth.authBackend` and `auth.templates` still are.
The default is `true`, which keeps the current behaviour.

## External secrets

The secret of each identity provider can come from an external store (Vault,
AWS Secrets Manager...) through the [External Secrets Operator](https://external-secrets.io)
instead of the chart values. With `externalSecret.enabled: true` on a backend,
the chart renders an `ExternalSecret` producing the very same Secret (name,
namespace, key), so the `OAuth` configuration that references it is unchanged.
Without `externalSecret`, the chart keeps rendering the Secret from the values.

| Backend type | Secret produced (openshift-config) | Required key |
| ------------ | ---------------------------------- | ------------ |
| `htpasswd`   | `<name>-htpasswd-auth`             | `htpasswd`   |
| `ldap`       | `<name>-ldap-auth`                 | `bindPassword` |
| `oidc`       | `<name>-oidc-auth`                 | `clientSecret` |

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
auth:
  enabled: true
  authBackend:
    - name: corp-ldap
      type: ldap
      ldapURL: "ldaps://ldap.example.com/ou=users,dc=example,dc=com?uid"
      ldapBindDN: "cn=svc-ocp,ou=services,dc=example,dc=com"
      externalSecret:
        enabled: true
        remoteRefs:
          bindPassword:
            key: ocp/auth/corp-ldap
            property: bindPassword
```

An `externalSecret` block accepts `secretStoreRef` and `refreshInterval`
(defaults: `externalSecretDefaults`), `remoteRefs` (map of secret key to ESO
`remoteRef`) and the raw ESO fields `data`, `dataFrom` and `template`. Rendering
fails when no store is set or when the required key is not provided.
`manageSubresource` cannot be combined with `externalSecret`.

## History

| Release  | Date       | Description                                                                                                                                             |
| -------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.72 | 2025-11-27 | improve with devoteam logo |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.12 | 2026-06-18 | Improve cluster-auth options |
| 21.3.278 | 2026-08-14 | add centigpu |
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.371 | 2026-11-19 | Add Sail, oauthProxy, DSCInitialization, spot machines and annotations support |
| 21.3.377 | 2026-11-19 | full repository release: aligned pins, ArgoCD source fix, schemas and docs |
| 21.3.379 | 2026-11-19 | conventions wave: spelling, READMEs, ArgoCD examples and values-app, oauth switch |
| 21.3.389 | 2026-11-19 | full repository release: HTTPS dependency URLs, dependency-ordered release, schema guard, docs and examples |
| 21.3.390 | 2026-11-20 | full repository release: test fix, keepalived README, aligned pins |
| 21.3.392 | 2026-11-21 | full repository release: chaos-pipeline run parameters and authenticated health check, aligned pins |
| 21.3.397 | 2026-11-21 | stable repository release 21.3.397: all charts aligned, unifai delegation cap documentation |

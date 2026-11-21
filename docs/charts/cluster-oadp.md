# ![cluster-oadp](https://helm-repository.readthedocs.io/en/latest/img/cluster-oadp.svg "Cluster Chart : OADP") Cluster Chart : OADP
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--oadp-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+oadp+startx)

This helm chart is used to deploy Openshift Application Data Protection handled by an operator to configure application and cluster backup strategies.

This chart is part of the [cluster-xxx startx helm chart series](https://helm-repository.readthedocs.io#cluster-helm-charts) that doesn't necessarily deploy pods but rather represent a cluster configuration state orchestrated by gitops tools like ArgoCD.

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
helm show chart startx/cluster-oadp
```

### 4. Install this chart

#### Default values

Complete deployment of a project with the following characteristics :

- 1 **namespace:** named **openshift-adp** without constraints
- 1 **operator:** named **redhat-oadp-operator** configured with
  - The **stable-1.1** channel
  - The **v1.1.1** version
  - Deployed under the **openshift-adp** project
- 1 **DataProtectionApplication:** named **default** configured with default values for AWS backend
- 1 **schedule:** named **daily-app** configured with default values for demo backup

```bash
# Create the project
helm install cluster-oadp-project startx/cluster-oadp --set project.enabled=true,operator.enabled=false,oadp.enabled=false
# Deploy the OADP operator
helm install cluster-oadp-operator startx/cluster-oadp --set project.enabled=false,operator.enabled=true,oadp.enabled=false && sleep 10
# Configure default OADP resources
helm install cluster-oadp-instance startx/cluster-oadp --set project.enabled=false,operator.enabled=false,oadp.enabled=true
```

#### Other available values

- **startx** : OADP operator (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-oadp/values-startx.yaml))

```bash
helm install cluster-oadp startx/cluster-oadp -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-oadp/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-oadp/examples/argocd/
oc apply -k .
```

### Applications



## External secrets

The backup storage credentials (`cloudcreds`) can come from an external store
(Vault, AWS Secrets Manager...) through the
[External Secrets Operator](https://external-secrets.io) instead of `cloudcreds.spec`.
With `cloudcreds.externalSecret.enabled: true`, the chart renders an
`ExternalSecret` producing the Secret `cloudcreds.name` (key `cloud`) in the OADP
namespace, so the `DataProtectionApplication` referencing it is unchanged.
Without `externalSecret`, the chart keeps rendering the Secret from the values.

When `remoteRefs` provides `aws_access_key_id` and `aws_secret_access_key`, the
chart builds the AWS-style credentials file (section `[profile]`, default
`default`) with an ESO template:

```yaml
externalSecretDefaults:
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
cloudcreds:
  enabled: true
  name: cloud-credentials
  externalSecret:
    enabled: true
    profile: default
    remoteRefs:
      aws_access_key_id:
        key: ocp/oadp/s3
        property: access_key
      aws_secret_access_key:
        key: ocp/oadp/s3
        property: secret_key
```

A complete credentials file can also be fetched as the `cloud` key
(`remoteRefs.cloud`). An `externalSecret` block accepts `secretStoreRef` and
`refreshInterval` (defaults: `externalSecretDefaults`), `remoteRefs` and the raw
ESO fields `data`, `dataFrom` and `template`. Rendering fails when no store is
set or when the `cloud` key is not provided.

## History

| Release  | Date       | Description                                                                                    |
| -------- | ---------- | ---------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.71 | 2025-11-27 | Align all charts to the same releas |
| 18.23.0 | 2026-02-28 | Start 4.19 branch |
| 19.23.17 | 2026-03-02 | Align all dependencies to chart v19.23.11 |
| 20.14.15 | 2026-03-02 | Update all chrat to OCP version 4.20.14 |
| 21.3.0 | 2026-03-02 | Update all chart to OCP version 4.21.3 |
| 21.3.13 | 2026-06-19 | Improve cluster-oadp options |
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

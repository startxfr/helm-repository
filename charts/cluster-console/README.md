# ![cluster-console](https://helm-repository.readthedocs.io/en/latest/img/cluster-console.svg "Cluster Chart : Console") Cluster Chart : Console
[![Artifacthub](https://img.shields.io/badge/ArtifactHub-STARTX_cluster--console-8A2BE2.svg)](https://artifacthub.io/packages/search?ts_query_web=cluster+console+startx)

This helm chart is used to configure openshift console at the cluster level.

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
helm show chart startx/cluster-console
```

### 4. Install this chart

```bash
helm install cluster-console startx/cluster-console
```

## Default values

Complete deployment of a project with the following characteristics :

Complete deployment of a cluster console configuration with the following characteristics :

- 1 **console** configuration with custom links, notifications and logo
- 1 **webTerminal** operator for in-browser terminal accesss

```bash
# base configuration running default configuration
helm install cluster-console startx/cluster-console
```

## Console customization (OpenShift 4.19+)

The masthead of the console follows the theme chosen by each user (light or dark) since OpenShift 4.19,
and a single logo is rarely readable in both themes. The `console.customize.logos` block declares one
logo per theme for the masthead and for the favicon through the `logos` API of the Console operator;
the legacy `console.customize.logo` block (`customLogoFile`, deprecated) is kept for existing deployments
and is not rendered when `logos.enabled` is true (OpenShift refuses both settings together).

Every logo is a file of the chart (`file: webtpl/...`, SVG or binary image such as PNG), an inline SVG
text (`content`) or an inline base64 image (`base64`). When several sources are set, `content` wins over
`base64` which wins over `file`, so an inline logo can be set without clearing the default file. The
ConfigMap key is the file name, `<type>-<theme>.svg` for an inline SVG, `<type>-<theme>.png` for a base64
image, or the explicit `key` (use it to carry another extension such as `.jpg` or `.webp`). The files are
published in a single ConfigMap of `openshift-config` (`console.customize.logos.configMap`).

```yaml
console:
  enabled: true
  customize:
    name: Magellium OpenShift
    logos:
      enabled: true
      masthead:
        light:
          file: webtpl/magellium-logo.png
        dark:
          file: webtpl/magellium-logo-dark.png
      favicon:
        light:
          content: |
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">...</svg>
    # Console UI elements, Enabled or Disabled
    capabilities:
      GettingStartedBanner: Disabled
      GuidedTour: Disabled
      LightspeedButton: Disabled
    # Any other spec.customization setting (perspectives, developerCatalog, projectAccess, quickStarts...)
    extraCustomization:
      perspectives:
        - id: dev
          visibility:
            state: Disabled
```

`console.plugins` enables console plugins (`spec.plugins` of the Console operator). The list replaces the
plugins enabled by hand or by other operators (OpenShift Virtualization, NMState, GitOps...), so it must
contain every plugin of the cluster; leave it empty to keep the list untouched. With ArgoCD self-healing,
a plugin enabled later by an operator is reverted at the next sync unless the Application ignores the
field:

```yaml
  ignoreDifferences:
    - group: operator.openshift.io
      kind: Console
      jsonPointers:
        - /spec/plugins
```

If a logo was previously set with `customLogoFile`, remove it from the cluster before switching to
`logos`: `oc patch consoles.operator.openshift.io cluster --type=json -p '[{"op":"remove","path":"/spec/customization/customLogoFile"}]'`.

### console.customize values dictionary

| Key                                                 | Default                   | Description                                                                                  |
| --------------------------------------------------- | ------------------------- | -------------------------------------------------------------------------------------------- |
| console.customize.name                              | `Example Console`         | Product name displayed by the console                                                        |
| console.customize.logo                              |                           | Legacy single logo (`customLogoFile`), ignored when `logos.enabled` is true                  |
| console.customize.logos.enabled                     | `false`                   | Enable the per-theme logos (OpenShift 4.19+)                                                 |
| console.customize.logos.configMap                   | `console-logos`           | Name of the ConfigMap (openshift-config) holding the logo files                              |
| console.customize.logos.masthead.light              | `webtpl/default-logo.svg` | Masthead logo of the light theme (`file`, `content` or `base64`, optional `key`)             |
| console.customize.logos.masthead.dark               | `webtpl/default-logo.svg` | Masthead logo of the dark theme                                                              |
| console.customize.logos.favicon.light               | empty                     | Favicon of the light theme (empty keeps the OpenShift favicon)                               |
| console.customize.logos.favicon.dark                | empty                     | Favicon of the dark theme                                                                    |
| console.customize.capabilities                      | `{}`                      | Console capabilities set to Enabled or Disabled (LightspeedButton, GettingStartedBanner, GuidedTour) |
| console.customize.documentationBaseURL              | `""`                      | Base URL of the documentation links (empty keeps the OpenShift documentation)                |
| console.customize.extraCustomization                | `{}`                      | Additional spec.customization settings added as-is                                           |
| console.plugins                                     | `[]`                      | Console plugins to enable (replaces the whole list, empty leaves it untouched)               |

## Other available values

- **startx** : Startx Openshift Console customization (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-console/values-startx.yaml))
- **magellium** : Magellium console with per-theme logos, clean home page, banner and links (see [values-magellium.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-console/values-magellium.yaml))

```bash
helm install cluster-console startx/cluster-console -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-console/values-startx.yaml
```

## Deploy with ArgoCD

### AppProject

```bash
git clone https://gitlab.com/startx1/helm.git
cd helm-repository/charts/cluster-console/examples/argocd/
oc apply -k .
```

### Applications



## History

| Release  | Date       | Description                                                                                                      |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------- |
| 16.19.59 | 2024-12-09 | Align all chart to the 16.19.59 release |
| 17.14.19 | 2025-03-12 | Align all chart to the 17.14.19 release |
| 17.14.90 | 2025-04-30 | Publish stable release for 4.17 version |
| 18.11.73 | 2026-01-21 | Change in devo logo |
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
| 21.3.12 | 2026-06-18 | Update context version to 4.21.3, web-terminal operator to v1.13.0, add ArgoCD deployment examples |
| 21.3.13 | 2026-06-18 | Improve cluster-console options |
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
| 21.3.300 | 2026-10-21 | Add new charts and align all to this release |
| 21.3.309 | 2026-10-27 | Adding new charts perconna and align all to v21.3.309 |
| 21.3.321 | 2026-11-05 | Adding external secret management |
| 21.3.321 | 2026-11-08 | Per-theme logos and favicon (OpenShift 4.19+ logos API, PNG support), capabilities, documentation URL, extra customization and plugins; Magellium values |

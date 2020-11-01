# STARTX helm : cluster-config

This helm chart is used to create a personnalized cluster configuration with various cluster level components configured as required.
This chart is part of the cluster-xxx startx helm chart that doesn't create application deployment but rather represent a cluster configuration
state orchestrated by gitops tools like ArgoCD.

## Requirements and guidelines

Read the [startx helm-repository homepage](https://startxfr.github.io/helm-repository) for
more information on how to use theses resources.

## Deploy this helm chart on openshift

### Connect to your Openshift cluster

```bash
oc login -t <token> <cluster-url>
```

### Install the repository

```bash
helm repo add startx https://startxfr.github.io/helm-repository/packages/
```

### Get information about this chart

```bash
helm show chart startx/cluster-config
```

### Install this chart

```bash
helm install startx/cluster-config
```

## Default values

Complete deployment of a project with the following characteristics :

- 1 **ClusterAutoscaler:** named **default** that is disabled by default but could enable autoscaling with the following limits
  - No lest than **4 cores**
  - No lest than **16Gi RAM**
  - No lest than **2 nodes**
  - No more than **40 cores**
  - No more than **160Gi RAM**
  - No more than **20 nodes**
  - Cluster could **scale down**
- 1 **ClusterVersion:** named **version** that is disabled by default but could enable and is related to
  - The **candidate** channel
  - The **4.5** version
- 1 **Secret:** named **alertmanager-main** that configure
  - The **PagerDutyStartx** receiver as default alert receiver using the startx pagerDutty key (fake ;)
  - An api endpoint pointing to the **_api_endpoint_** endpoint
- 1 **ImagePruner:** named **cluster** that define an image prunner that will
  - Run every **15min** but is **suspended**
  - Preserve **5 failed** history
  - Preserve **5 successful** history
- 1 **namespace:** named **openshift-operators-redhat** to host redhat operators

```bash
# base configuration running default configuration
helm install startx/cluster-config
```

## Others values availables

- **startx** : Startx cluster default configuration with 30min enabled image prunnning scheduling, pagerdutty alert enabled and cluster auto-scaling topped to 64 core and 400Gi RAM consumed (see [values.yaml](https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-config/values-startx.yaml))

```bash
helm install startx/cluster-config -f https://raw.githubusercontent.com/startxfr/helm-repository/master/charts/cluster-config/values-startx.yaml
```

## History

| Release | Date       | Description
| ------- | ---------- | -----------------------------------------------------
| 0.1.16  | 2020-10-23 | Initial commit for this helm chart with default value example (removed)
| 0.2.0   | 2020-10-24 | Adding example value for start
| 0.2.11  | 2020-10-25 | publish stable update for the full repository
| 0.2.12  | 2020-10-26 | Improve cluster-config options
| 0.2.22  | 2020-10-26 | Align all releases to 0.2.22
| 0.2.31  | 2020-10-26 | unstable common release for all startx helm-repository charts
| 0.2.33  | 2020-10-26 | Align all startx helm chart to 0.2.33 release
| 0.2.51  | 2020-10-31 | Common release for all chart
| 0.2.93  | 2020-10-31 | Align all startx charts version to 0.2.93. Preparing stable 0.3 release
| 0.2.94  | 2020-10-31 | Aligned stable release of all startx charts
| 0.2.94  | 2020-10-31 | Aligned stable release of all startx charts
| 0.2.96  | 2020-10-31 | Stable version 0.2.96 preparing the 0.3 release
| 0.3.0   | 2020-10-31 | Stable 0.3 release
| 0.3.5  | 2020-11-01 | Update dependency to 0.3.3 release and improve Note display
| 0.3.7  | 2020-11-01 | publish stable update for the full repository

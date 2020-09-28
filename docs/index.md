# This repository

This helm repository hold various helm-chart configuring Openshift cluster components

## Usage

In order to use this helm-chart repository content, you can perform the following actions :

1. install helm
    ```bash
    yum install helm -y
    ```

2. Install this repository
    ```bash
    helm repo add startx https://startxfr.github.io/helm-charts-ocp-infra/
    ```

3. Search chart in this repository
    ```bash
    helm search startx
    ```

## Release

Release naming and convention is described in the [release documentation](./releases.md).

### History

You can get a detailed list of this helm-chart releases in the [history documentation](./history.md). 
The current release is for theses helm-charts is 0.0.5. More information are available in [version 0.0 releases history](./history.md#version-00x-chanteix).

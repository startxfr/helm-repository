# install via Git

In order to get the full developement environment, you must stick to the following procedure

## 0. Requirements

- Having a RedHat like (Fedora, CentOS, RHEL, ...) operating system
- Install git with `sudo yum install git`
- Install helm with `sudo yum install helm`
- Install openshift client with `sudo yum install openshift-client`

## 1. Get a copy of the repository

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository
```

## 2. Install your helm chart

Install a new helm chart based on the local installation. Move to the targeted chart directory.

```bash
cd charts/example-pod
```

Adjust the value of your chart and prepare the chart deployment

```bash
vi values.yaml
```

Install the chart into your cluster

```bash
helm install mypod  .
```

## 3. Delete the helm chart

Uninstall the chart in your cluster.

```bash
helm uninstall mypod
```

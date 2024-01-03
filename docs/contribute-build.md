# Building environment

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

## 2. Create your first chart

Create a new helm chart based on the sx-helm template.

```bash
./sx-helm myhelm create
```

## 3. Test your chart

Execute `helm template` and `helm lint` on the given chart

```bash
./sx-helm myhelm test
```

## 4. Package your chart

Record all code change into the git repository. Afterwork, execute `helm dependency update` and `helm package` on this updated content. Produce a chart archive (tgz).

```bash
./sx-helm myhelm package
```

## 5. Release your chart

Upgrade release version and update history log under the git repository. Execute the _package step_ and move chart package into index directory.

```bash
./sx-helm myhelm release
```

## 5. Publish your chart

Execute the _release step_ and move chart package into index directory. Update the repository index and merge to the master branch for publication. Push all change to remote repository.

```bash
./sx-helm myhelm release
```

## 5. Delete a helm

Remove local directory, commit locally and push to remote repository this deletion. Keep .

```bash
./sx-helm myhelm delete
```

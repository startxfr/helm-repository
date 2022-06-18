# ArgoCD deployment

To leverage the gitops feature of ArgoCD to deploy your targeted  chart, you should follow the following procedure.

## 0. Requirements

- Having an running openshift cluster with appropriate permissions
- Install openshift client with `sudo yum install openshift-client`
- Been connected to your cluster with `oc login <mycluster_api_url>`

## 0.1. Deploy ArgoCD project

If gitops is not enabled in your cluster, you could perform it with :

```bash
echo "begin deploying argocd project"
oc process -f https://gitlab.com/sxcm/cli/-/raw/main/src/resources/argocd-project.yml \
    -p ARGOCD_NS=openshift-gitops \
    -p DOCKERHUB_LOGIN=my_dockerhub_login \
    -p DOCKERHUB_PWD=my_dockerhub_password \
    -p QUAYIO_LOGIN=my_quayio_login \
    -p QUAYIO_PWD=my_quayio_password | \
oc apply -f -
echo "switching to openshift-gitops namespace"
oc project openshift-gitops
echo "deploying secrets links for gitops deployments"
oc secrets link argocd-application-controller startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link argocd-dex-server startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link argocd-operator startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link argocd-redis-ha startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link argocd-server startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link default startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link deployer startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link openshift-gitops-application-controller startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link openshift-gitops-dex-server startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link openshift-gitops-redis-ha startx-registrycreds-docker --for=pull -n openshift-gitops
oc secrets link openshift-gitops-server startx-registrycreds-docker --for=pull -n openshift-gitops
echo "pause deploying argocd project"
sleep 60
echo "end deploying argocd project"
```

## 0.2. Deploy ArgoCD control-plane

If gitops is not enabled in your cluster, you must perform the following procedure ater the previous deployment (project) :

```bash
echo "begin deploying argocd control-plane"
oc process -f https://gitlab.com/sxcm/cli/-/raw/main/src/resources/argocd-deploy-small.yml \
    -p CLUSTER_PROFILE=default \
    -p AWS_ZONE=eu-west-3 \
    -p AWS_ACCESS_ID=AKIAXXXXXXXXXXXXXXXX \
    -p AWS_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \
    -p AWS_SMTP_ZONE=eu-west-3 \
    -p AWS_SMTP_USER=AKIAXXXXXXXXXXXXXXXX \
    -p AWS_SMTP_PASSWORD=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \
    -p AWS_SMTP_FROM=mymail@example.com \
    -p DOCKERHUB_LOGIN=my_dockerhub_login \
    -p DOCKERHUB_PWD=my_dockerhub_password \
    -p QUAYIO_LOGIN=my_quayio_login \
    -p QUAYIO_PWD=my_quayio_password \
    -p HELM_RELEASE=devel | \
oc apply -f -
echo "pause deploying argocd control-plane"
sleep 120
echo "end deploying argocd control-plane"
```

## 0.3. Check ArgoCD deployments

If gitops is not enabled in your cluster, you must perform the following procedure ater the previous deployment (instance) :

```bash
echo "begin getting gitops deployments"
echo "get status for gitops deployments"
oc get pod -n openshift-gitops
sleep 20
echo "second status for gitops deployments"
oc get pod -n openshift-gitops
echo "end getting gitops deployments"
```

## 1. Create an application

In order to use your helm chart instance using ArgoCD, you should create an `Application` resource.

## 1. Create an application

```bash
cat <<EOF | oc apply -f -
kind: Application
apiVersion: argoproj.io/v1alpha1
metadata:
name: startx-gitops-example
namespace: "openshift-gitops"
labels:  &basic_labels
    app.startx.fr/component: "example"
    app.kubernetes.io/name: "startx-sxapi-example-application"
    app.kubernetes.io/component: "sxapi-example"
spec:
destination:
    namespace: "openshift-gitops"
    server: 'https://kubernetes.default.svc'
project: default
source:
    path: charts/sxapi/
    repoURL: 'https://github.com/startxfr/helm-repository.git'
    targetRevision: "devel"
    helm:
    valueFiles:
        - values-test.yaml
    parameters:
    - name: sxapi.service.enabled
      value: "true"
    - name: sxapi.service.expose
      value: "true"
ignoreDifferences:
    - kind: Secret
    jsonPointers: [ "/" ]
EOF
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

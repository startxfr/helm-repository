#!/usr/bin/env bash
# Contract tests of the charts that zuno-demo consumes: project, cluster-ods, cluster-certmanager, cluster-gpu, cluster-nfd,
# cluster-machine, cluster-prometheus, cluster-istio and operator, plus the krkn based chaos charts (chaos-cerberus,
# chaos-kraken, chaos-pipeline). Each check renders a chart with helm template and
# asserts a few expected facts with yq. Plain bash, helm, yq (mikefarah v4): no other dependency.
#
# Usage: tests/contract/run.sh [chart ...]     (default: every chart above)
# The charts are copied to a temporary directory and their dependencies are resolved (public HTTPS endpoint of the S3
# bucket, declared in Chart.yaml), so the working tree stays untouched. A chart whose dependencies cannot be resolved is skipped.
set -uo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$ROOT" || exit 2
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
PASS=0 FAIL=0 SKIP=0
CURRENT=""

ok()   { PASS=$((PASS + 1)); printf 'ok   %s\n' "$*"; }
bad()  { FAIL=$((FAIL + 1)); printf 'FAIL %s\n' "$*"; }

# prepare <chart>: copy the chart and resolve its dependencies; sets CHART_DIR, returns 1 when it cannot be resolved
prepare() {
    local c=$1
    CHART_DIR=$WORK/$c
    rm -rf "$CHART_DIR"; cp -r "charts/$c" "$CHART_DIR"
    rm -rf "$CHART_DIR/charts" "$CHART_DIR/Chart.lock"
    grep -q '^dependencies:' "$CHART_DIR/Chart.yaml" || return 0
    helm dependency update "$CHART_DIR" >"$WORK/dep.log" 2>&1 || { sleep 3; helm dependency update "$CHART_DIR" >"$WORK/dep.log" 2>&1; }
}

# render <name> [helm template args]: renders the current chart into $OUT (also kept as $WORK/<name>.yaml)
render() {
    local name=$1; shift
    OUT=$WORK/$CURRENT.$name.yaml
    if ! helm template contract "$CHART_DIR" "$@" >"$OUT" 2>"$WORK/err.log"; then
        bad "$CURRENT/$name: helm template failed: $(tail -1 "$WORK/err.log")"
        : >"$OUT"; return 1
    fi
}

# kinds <file> <kind>: number of documents of that kind
# (yq prints a --- line between documents and null for a document without kind: both are ignored)
kinds() { yq e "select(.kind == \"$2\") | .kind" "$1" 2>/dev/null | grep -cvE '^(---|null|)$' || true; }

# assert_count <label> <kind> <expected>   (on $OUT)
assert_count() {
    local n; n=$(kinds "$OUT" "$2")
    [[ $n -eq $3 ]] && ok "$CURRENT: $1" || bad "$CURRENT: $1 (kind $2: expected $3, got $n)"
}
# assert_yq <label> <kind> <yq expression on the document> <expected value>   (on $OUT)
assert_yq() {
    local got; got=$(yq e "select(.kind == \"$2\") | $3" "$OUT" 2>/dev/null | head -1)
    [[ "$got" == "$4" ]] && ok "$CURRENT: $1" || bad "$CURRENT: $1 ($2 $3: expected '$4', got '$got')"
}
# assert_sel <label> <yq expression starting with select(...)> <expected first output line>   (on $OUT)
# The output is captured in a variable (never `yq | grep -q` under pipefail: grep exits at the first match, yq may then
# get SIGPIPE and the pipeline fails randomly). On failure the selected document is printed.
assert_sel() {
    local got sel="${2%% | *}"; got=$(yq e "$2" "$OUT" 2>/dev/null | head -1)
    if [[ "$got" == "$3" ]]; then ok "$CURRENT: $1"; else
        bad "$CURRENT: $1 (expected '$3', got '$got')"; printf -- '--- rendered document(s) for %s:\n' "$sel"; yq e "$sel" "$OUT" 2>&1 | head -40; fi
}
# assert_empty <label>   (nothing at all rendered)
assert_empty() {
    local n; n=$(yq e '.kind' "$OUT" 2>/dev/null | grep -cvE '^(---|null|)$' || true)
    [[ $n -eq 0 ]] && ok "$CURRENT: $1" || bad "$CURRENT: $1 (expected no resource, got $n)"
}

values() { cat >"$WORK/values.yaml"; }

# ---------------------------------------------------------------------------------------------------------------
test_operator() {
    # WP-099: spec.config.resources of the Subscription is rendered when set, and absent otherwise
    values <<'YAML'
enabled: true
subscription:
  enabled: true
  name: demo-operator
  namespace: demo-ns
  operator:
    channel: stable
    name: demo-operator
    source: {name: redhat-operators, namespace: openshift-marketplace}
    config:
      resources:
        limits: {memory: 1Gi}
        requests: {cpu: 100m}
YAML
    render resources -f "$WORK/values.yaml" && {
        assert_count "renders one Subscription" Subscription 1
        assert_yq "spec.config.resources.limits.memory is rendered" Subscription '.spec.config.resources.limits.memory' 1Gi
        assert_yq "spec.config.resources.requests.cpu is rendered" Subscription '.spec.config.resources.requests.cpu' 100m
        assert_yq "installPlanApproval defaults to Manual" Subscription '.spec.installPlanApproval' Manual
    }
    values <<'YAML'
enabled: true
subscription:
  enabled: true
  name: demo-operator
  namespace: demo-ns
  operator: {channel: stable, name: demo-operator}
YAML
    render noresources -f "$WORK/values.yaml" && assert_yq "no spec.config without config" Subscription '.spec.config' null
    render disabled && assert_empty "nothing is rendered by default"
}

test_cluster-ods() {
    render default && {
        assert_count "renders a DataScienceCluster by default" DataScienceCluster 1
        assert_yq "DataScienceCluster apiVersion defaults to v2" DataScienceCluster '.apiVersion' datasciencecluster.opendatahub.io/v2
        assert_yq "DataScienceCluster sync-wave is 15" DataScienceCluster '.metadata.annotations["argocd.argoproj.io/sync-wave"]' 15
        assert_count "no DSCInitialization by default" DSCInitialization 0
    }
    render startx -f "$CHART_DIR/values-startx_noinfra.yaml" && assert_count "values-startx_noinfra.yaml renders no DataScienceCluster" DataScienceCluster 0
    render startx-on -f "$CHART_DIR/values-startx_noinfra.yaml" --set DataScienceCluster.enabled=true && assert_count "DataScienceCluster.enabled=true renders one" DataScienceCluster 1
    render scoped --set DataScienceCluster.clusterScoped=true && assert_yq "clusterScoped omits metadata.namespace" DataScienceCluster '.metadata.namespace' null
    render dsci --set DSCInitialization.enabled=true --set DSCInitialization.applicationsNamespace=redhat-ods-applications && {
        assert_count "DSCInitialization.enabled=true renders one" DSCInitialization 1
        assert_yq "DSCInitialization is cluster scoped (no namespace)" DSCInitialization '.metadata.namespace' null
        assert_yq "applicationsNamespace overrides the spec" DSCInitialization '.spec.applicationsNamespace' redhat-ods-applications
        assert_yq "DSCInitialization sync-wave is 14" DSCInitialization '.metadata.annotations["argocd.argoproj.io/sync-wave"]' 14
    }
    render noops --set operator.enabled=false --set project.enabled=false && assert_count "operator and project flags false render no Subscription" Subscription 0
}

test_cluster-certmanager() {
    values <<'YAML'
clusterIssuer:
  enabled: true
  list:
    - name: ci-map
      annotations: {argocd.argoproj.io/sync-wave: "19", argocd.argoproj.io/sync-options: Prune=false}
      spec: {selfSigned: {}}
    - name: ci-str
      clusterScoped: true
      spec: |-
        selfSigned: {}
YAML
    render issuers -f "$WORK/values.yaml" && {
        assert_count "renders two ClusterIssuer" ClusterIssuer 2
        assert_sel "annotations override the default sync-wave" 'select(.kind == "ClusterIssuer" and .metadata.name == "ci-map") | .metadata.annotations["argocd.argoproj.io/sync-wave"]' 19
        assert_sel "Prune=false annotation is rendered" 'select(.kind == "ClusterIssuer" and .metadata.name == "ci-map") | .metadata.annotations["argocd.argoproj.io/sync-options"]' Prune=false
        assert_sel "clusterScoped omits metadata.namespace" 'select(.kind == "ClusterIssuer" and .metadata.name == "ci-str") | .metadata | has("namespace")' false
        assert_sel "namespace is kept by default" 'select(.kind == "ClusterIssuer" and .metadata.name == "ci-map") | .metadata | has("namespace")' true
    }
    render empty && assert_count "no ClusterIssuer by default" ClusterIssuer 0
}

test_cluster-gpu() {
    render default && assert_empty "nothing is rendered by default (gpu.enabled false)"
    render on --set gpu.enabled=true --set operator.enabled=false --set project.enabled=false && {
        assert_count "gpu.enabled=true renders one ClusterPolicy" ClusterPolicy 1
        assert_yq "ClusterPolicy is the nvidia.com/v1 API" ClusterPolicy '.apiVersion' nvidia.com/v1
    }
}

test_cluster-nfd() {
    render default && assert_count "no NodeFeatureDiscovery by default" NodeFeatureDiscovery 0
    render on --set nfd.enabled=true --set operator.enabled=false --set project.enabled=false && assert_count "nfd.enabled=true renders the list" NodeFeatureDiscovery 1
    render rule --set nfr.enabled=true --set operator.enabled=false --set project.enabled=false && assert_count "nfr.enabled=true renders the list" NodeFeatureRule 1
}

test_cluster-machine() {
    render default && assert_empty "all toggles false render nothing"
    values <<'YAML'
cluster: {id: c1, region: eu-west-3}
machineSet:
  enabled: true
  list:
    - {name: spot-a, provider: aws, az: a, type: worker, ami: ami-1, instanceType: m6i.large, replicas: 1, spotMarketOptions: {maxPrice: "0.3"}}
    - {name: spot-b, provider: aws, az: b, type: worker, ami: ami-1, instanceType: m6i.large, replicas: 1, spotMarketOptions: {}}
    - {name: od-c, provider: aws, az: c, type: worker, ami: ami-1, instanceType: m6i.large, replicas: 1}
YAML
    render sets -f "$WORK/values.yaml" && {
        assert_count "renders three MachineSet" MachineSet 3
        assert_sel "spotMarketOptions.maxPrice is rendered" 'select(.metadata.name == "spot-a") | .spec.template.spec.providerSpec.value.spotMarketOptions.maxPrice' 0.3
        assert_sel "an empty spotMarketOptions requests spot" 'select(.metadata.name == "spot-b") | .spec.template.spec.providerSpec.value | has("spotMarketOptions")' true
        assert_sel "no spotMarketOptions without the key" 'select(.metadata.name == "od-c") | .spec.template.spec.providerSpec.value | has("spotMarketOptions")' false
    }
}

test_cluster-prometheus() {
    render default && assert_empty "nothing is rendered by default"
    values <<'YAML'
monitoringStacks:
  enabled: true
  list:
    - name: mesh
      annotations: {argocd.argoproj.io/sync-wave: "16"}
      spec:
        resourceSelector: {matchLabels: {zuno.io/mesh-monitoring: "true"}}
    - name: apps
      spec: {retention: 24h}
serviceMonitors:
  enabled: true
  list:
    - name: m1
      labels: {zuno.io/mesh-monitoring: "true"}
      annotations: {argocd.argoproj.io/sync-wave: "31"}
      spec: {selector: {matchLabels: {a: b}}, endpoints: [{port: metrics}]}
YAML
    render stacks -f "$WORK/values.yaml" && {
        assert_count "renders two MonitoringStack" MonitoringStack 2
        assert_sel "an explicit resourceSelector is kept" 'select(.kind == "MonitoringStack" and .metadata.name == "mesh") | .spec.resourceSelector.matchLabels["zuno.io/mesh-monitoring"]' true
        assert_sel "the default resourceSelector selects the stack label" 'select(.kind == "MonitoringStack" and .metadata.name == "apps") | .spec.resourceSelector.matchLabels["monitoring.rhobs/stack"]' apps
        assert_sel "annotations override the stack sync-wave" 'select(.kind == "MonitoringStack" and .metadata.name == "mesh") | .metadata.annotations["argocd.argoproj.io/sync-wave"]' 16
        assert_sel "the default stack sync-wave is 15" 'select(.kind == "MonitoringStack" and .metadata.name == "apps") | .metadata.annotations["argocd.argoproj.io/sync-wave"]' 15
        assert_yq "ServiceMonitor keeps its custom label" ServiceMonitor '.metadata.labels["zuno.io/mesh-monitoring"]' 'true'
        assert_yq "ServiceMonitor sync-wave is overridable" ServiceMonitor '.metadata.annotations["argocd.argoproj.io/sync-wave"]' 31
    }
}

test_cluster-istio() {
    render default && assert_empty "nothing is rendered by default"
    values <<'YAML'
sail:
  enabled: true
  istioCNI: {enabled: true, list: [{name: default}]}
  istio:
    enabled: true
    list:
      - name: default
        version: v1.30.3
        annotations: {argocd.argoproj.io/sync-wave: "21"}
  telemetry: {enabled: true, list: [{name: default, namespace: istio-system}]}
YAML
    render sail -f "$WORK/values.yaml" && {
        assert_count "renders an Istio" Istio 1
        assert_count "renders an IstioCNI" IstioCNI 1
        assert_count "renders a Telemetry" Telemetry 1
        assert_yq "Istio uses the sailoperator.io/v1 API" Istio '.apiVersion' sailoperator.io/v1
        assert_yq "Istio version is set in the spec" Istio '.spec.version' v1.30.3
        assert_yq "Istio sync-wave is overridable" Istio '.metadata.annotations["argocd.argoproj.io/sync-wave"]' 21
        assert_yq "IstioCNI default sync-wave is 20" IstioCNI '.metadata.annotations["argocd.argoproj.io/sync-wave"]' 20
        assert_yq "Istio is cluster scoped (no namespace)" Istio '.metadata.namespace' null
    }
    render operator --set operatorSail.enabled=true && {
        assert_yq "operatorSail subscribes to servicemeshoperator3" Subscription '.spec.name' servicemeshoperator3
        assert_yq "operatorSail installs in openshift-operators" Subscription '.metadata.namespace' openshift-operators
        assert_count "operatorSail creates no OperatorGroup" OperatorGroup 0
    }
}

# The three krkn based chaos charts: nothing runs by default, no privileged SCC, images pinned
test_chaos-cerberus() {
    render default && assert_count "nothing is rendered by default" Deployment 0
    render enabled --set cerberus.enabled=true && {
        assert_count "cerberus creates one Deployment" Deployment 1
        assert_count "no custom SecurityContextConstraints" SecurityContextConstraints 0
        assert_count "local mode creates no kubeconfig Secret" Secret 0
        assert_sel "the image is pinned by digest" 'select(.kind == "Deployment") | .spec.template.spec.containers[0].image | test("^quay.io/krkn-chaos/cerberus@sha256:")' true
        assert_sel "the container is not privileged" 'select(.kind == "Deployment") | .spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation' false
        assert_sel "the signal is closed to other namespaces" 'select(.kind == "NetworkPolicy") | .spec.ingress[0].ports[0].port' 8080
    }
    render watchoff --set cerberus.enabled=true --set cerberus.watch_nodes=false && \
        assert_sel "watch_nodes can be disabled" 'select(.kind == "ConfigMap") | .data."config.yaml" | test("watch_nodes: False")' true
    render token --set cerberus.enabled=true --set cerberus.kubeconfig.mode=token --set cerberus.kubeconfig.token.token=sha256~contract-test-token && {
        assert_count "token mode stores the kubeconfig in a Secret" Secret 1
        assert_count "token mode creates no ClusterRole" ClusterRole 0
    }
}

test_chaos-kraken() {
    render default && assert_count "nothing is rendered by default" Job 0
    render enabled --set kraken.enabled=true && {
        assert_count "the core engine creates one Job" Job 1
        assert_count "no custom SecurityContextConstraints" SecurityContextConstraints 0
        assert_count "no Tekton Pipeline in this chart" Pipeline 0
        assert_sel "the image is pinned by digest" 'select(.kind == "Job") | .spec.template.spec.containers[0].image | test("^quay.io/krkn-chaos/krkn@sha256:")' true
        assert_sel "no scenario is enabled by default" 'select(.kind == "ConfigMap" and .metadata.name == "kraken-config") | .data."config.yaml" | test("chaos_scenarios: \\[\\]")' true
        assert_sel "the service account is not cluster-admin" 'select(.kind == "ClusterRoleBinding") | .roleRef.name' kraken-chaos-chaos-kraken
    }
    render scenario --set kraken.enabled=true --set kraken.scenarios.pods-monitoring.enabled=true && \
        assert_sel "an enabled scenario is added to the scenarios ConfigMap" 'select(.kind == "ConfigMap" and .metadata.name == "kraken-scenarios") | .data | has("pods-monitoring.yaml")' true
    if helm template contract "$CHART_DIR" --set kraken.enabled=true --set kraken.cerberus.enabled=true \
        --set kraken.cerberus.url=http://cerberus:8080 --set kraken.config.exitOnFailure=true >"$WORK/eof.yaml" 2>"$WORK/err.log"; then
        bad "$CURRENT: exitOnFailure with cerberus must fail the render"
    else
        grep -q "must stay false" "$WORK/err.log" && ok "$CURRENT: exitOnFailure with cerberus fails with a clear message" || bad "$CURRENT: wrong failure message: $(tail -1 "$WORK/err.log")"
    fi
    render hub --set kraken.enabled=true --set kraken.engine=hub --set kraken.hub.scenarios.pod-scenarios.enabled=true && \
        assert_sel "the hub engine runs a krkn-hub image" 'select(.kind == "Job") | .spec.template.spec.containers[0].image' quay.io/krkn-chaos/krkn-hub:pod-scenarios
}

test_chaos-pipeline() {
    render default && assert_count "nothing is rendered by default" Task 0
    render enabled --set pipeline.enabled=true && {
        assert_count "four tasks" Task 4
        assert_count "two pipelines" Pipeline 2
        assert_count "no PipelineRun: nothing runs at install time" PipelineRun 0
        assert_count "no custom SecurityContextConstraints" SecurityContextConstraints 0
        assert_sel "tasks use the tekton.dev/v1 API" 'select(.kind == "Task" and .metadata.name == "krkn-run") | .apiVersion' tekton.dev/v1
        assert_sel "the infra pipeline starts with the cerberus gate" 'select(.kind == "Pipeline" and .metadata.name == "chaos-infra") | .spec.tasks[0].name' cerberus-gate
        assert_sel "the infra pipeline ends with a final cerberus check" 'select(.kind == "Pipeline" and .metadata.name == "chaos-infra") | .spec.finally[0].name' cerberus-final-check
        assert_sel "node scenarios are disabled by default" 'select(.kind == "ConfigMap") | .data | has("30-node-reboot-worker.yaml")' false
        assert_sel "a run can choose its scenarios" 'select(.kind == "Pipeline" and .metadata.name == "chaos-infra") | .spec.params[] | select(.name == "scenarios") | .type' array
        assert_sel "every scenario task is guarded by the scenarios parameter" 'select(.kind == "Pipeline" and .metadata.name == "chaos-infra") | .spec.tasks[1].when[0].values[0]' '$(params.scenarios[*])'
        assert_sel "a run that names no scenario runs none" 'select(.kind == "Pipeline" and .metadata.name == "chaos-infra") | .spec.params[] | select(.name == "scenarios") | .default | length' 0
        assert_sel "the application pipeline has the same empty default" 'select(.kind == "Pipeline" and .metadata.name == "chaos-application") | .spec.params[] | select(.name == "scenarios") | .default | length' 0
        assert_sel "the ClusterOperator check is the last finally task" 'select(.kind == "Pipeline" and .metadata.name == "chaos-infra") | .spec.finally[1].taskRef.name' clusteroperator-check
        assert_sel "the ClusterOperator check is off by default" 'select(.kind == "Pipeline" and .metadata.name == "chaos-infra") | .spec.params[] | select(.name == "clusteroperator-check") | .default' false
        assert_sel "krkn does not exit after a healthy cerberus signal" 'select(.kind == "Task" and .metadata.name == "krkn-run") | .spec.steps[].script | capture("(?s)\\nkraken:\\n(?<block>.*?)\\nresiliency:") | .block | [test("exit_on_failure: False"), (test("exit_on_failure: True") | not)] | all' true
        assert_sel "the application target is a pipeline parameter" 'select(.kind == "Pipeline" and .metadata.name == "chaos-application") | .spec.params[] | select(.name == "target-namespace") | .name' target-namespace
    }
    render postcheck --set pipeline.enabled=true --set pipeline.postCheck.clusterOperators.enabled=true \
        --set 'pipeline.postCheck.clusterOperators.ignore={one,two}' --set 'pipeline.infra.defaultScenarios={10-pods-monitoring}' && {
        assert_sel "the ClusterOperator check can be enabled by values" 'select(.kind == "Pipeline" and .metadata.name == "chaos-application") | .spec.params[] | select(.name == "clusteroperator-check") | .default' true
        assert_sel "ignored operators are passed as a comma separated list" 'select(.kind == "Pipeline" and .metadata.name == "chaos-infra") | .spec.params[] | select(.name == "clusteroperator-ignore") | .default' one,two
        assert_sel "defaultScenarios restores a default list" 'select(.kind == "Pipeline" and .metadata.name == "chaos-infra") | .spec.params[] | select(.name == "scenarios") | .default[0]' 10-pods-monitoring
    }
}

test_project() {
    # dockercfg: an entry with existingSecret renders no Secret (the user provides it), the pull secret reference stays
    values <<'YAML'
enabled: true
project: {name: demo-ns}
dockercfg:
  enabled: true
  list:
    - existingSecret: demo-pull-secret
serviceAccounts:
  enabled: true
  list:
    - name: default
      imagePullSecrets:
        - name: demo-pull-secret
YAML
    render existing -f "$WORK/values.yaml" && {
        assert_count "an existingSecret entry renders no Secret" Secret 0
        assert_sel "the service account references the existing Secret" 'select(.kind == "ServiceAccount") | .imagePullSecrets[0].name' demo-pull-secret
    }
    values <<'YAML'
enabled: true
project: {name: demo-ns}
dockercfg:
  enabled: true
  list:
    - existingSecret: demo-pull-secret
    - {name: demo-generated, registry: quay.io, username: u, password: p, email: u@example.com}
YAML
    render mixed -f "$WORK/values.yaml" && {
        assert_count "only the clear-text entry renders a Secret" Secret 1
        assert_sel "the generated Secret keeps its name" 'select(.kind == "Secret") | .metadata.name' demo-generated
        assert_sel "the generated Secret is a dockerconfigjson" 'select(.kind == "Secret") | .type' kubernetes.io/dockerconfigjson
    }
    values <<'YAML'
enabled: true
project: {name: demo-ns}
dockercfg:
  enabled: true
  list:
    - {existingSecret: demo-pull-secret, password: p}
YAML
    if helm template contract "$CHART_DIR" -f "$WORK/values.yaml" >"$WORK/both.yaml" 2>"$WORK/err.log"; then
        bad "$CURRENT: existingSecret with a clear-text password must fail the render"
    else
        grep -q "use one or the other" "$WORK/err.log" && ok "$CURRENT: existingSecret with a clear-text password fails with a clear message" || bad "$CURRENT: wrong failure message: $(tail -1 "$WORK/err.log")"
    fi
}

# ---------------------------------------------------------------------------------------------------------------
ALL=(operator project cluster-ods cluster-certmanager cluster-gpu cluster-nfd cluster-machine cluster-prometheus cluster-istio chaos-cerberus chaos-kraken chaos-pipeline)
SELECTED=("$@"); [[ ${#SELECTED[@]} -eq 0 ]] && SELECTED=("${ALL[@]}")
command -v yq >/dev/null || { echo "yq (mikefarah v4) is required"; exit 2; }
for c in "${SELECTED[@]}"; do
    declare -F "test_$c" >/dev/null || { echo "unknown chart: $c (known: ${ALL[*]})"; exit 2; }
    CURRENT=$c
    if ! prepare "$c"; then SKIP=$((SKIP + 1)); echo "SKIP $c: dependencies not resolvable ($(tail -1 "$WORK/dep.log"))"; continue; fi
    "test_$c"
done
echo "summary: $PASS passed, $FAIL failed, $SKIP chart(s) skipped"
[[ $FAIL -eq 0 ]]

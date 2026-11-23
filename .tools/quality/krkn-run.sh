#!/bin/bash
set -eu
# The image expects a fixed user owning /home/krkn/kraken: work on a writable copy instead
cp -r /home/krkn/kraken /tmp/kraken
cd /tmp/kraken
mkdir -p scenarios/custom
"${PYTHON_CMD:-python3.11}" - <<'PYEOF'
import os, string, sys
source = "/etc/chaos/scenarios/%s.yaml" % os.environ["SCENARIO"]
if not os.path.isfile(source):
    sys.exit("scenario %s not found in the chaos-pipeline-scenarios ConfigMap" % os.environ["SCENARIO"])
import re
values = {k: os.environ.get(k, "") for k in ("TARGET_NAMESPACE", "LABEL_SELECTOR", "RECOVERY_TIME",
                                             "NODE_SELECTOR", "WORKLOAD_NAMESPACE")}
with open(source) as f:
    content = f.read()
# A placeholder with an empty value, alone as a YAML value, must stay an empty string and not become null
for key, value in values.items():
    if value == "":
        content = re.sub(r'(:[ \t]*)\$\{%s\}[ \t]*$' % key, r'\1""', content, flags=re.M)
content = string.Template(content).safe_substitute(values)
with open("scenarios/custom/scenario.yaml", "w") as f:
    f.write(content)
print(content)
PYEOF
# The kubernetes python client does not support tokenFile: embed the service account token
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CA_DATA=$(base64 -w0 /var/run/secrets/kubernetes.io/serviceaccount/ca.crt)
cat > /tmp/kubeconfig <<KUBECONFIGEOF
kind: Config
apiVersion: v1
current-context: default
clusters:
- name: default
  cluster:
    certificate-authority-data: ${CA_DATA}
    server: https://kubernetes.default.svc
users:
- name: default
  user:
    token: ${TOKEN}
contexts:
- name: default
  context:
    cluster: default
    namespace: default
    user: default
preferences: {}
KUBECONFIGEOF
cerberus=False
if [ "${CERBERUS_ENABLED}" = "true" ] && [ -n "${CERBERUS_URL}" ]; then cerberus=True; fi
health_during="[]"
if [ -n "${HEALTH_CHECK_URL}" ]; then health_during="[pre, post]"; fi
cat > /tmp/config.yaml <<CONFIGEOF
kraken:
    kubeconfig_path: /tmp/kubeconfig
    image_signature_verification_enabled: True
    image_signature_public_key: cosign.pub
    exit_on_failure: True
    auto_rollback: True
    rollback_versions_directory:
    publish_kraken_status: False
    signal_state: RUN
    signal_address: 0.0.0.0
    port: 8081
    report_formats: []
    chaos_scenarios:
        - ${SCENARIO_TYPE}:
            - scenarios/custom/scenario.yaml
resiliency:
    resiliency_run_mode: disabled
    resiliency_file: config/alerts.yaml
cerberus:
    cerberus_enabled: ${cerberus}
    cerberus_url: ${CERBERUS_URL}
    check_application_routes: False
elastic:
    enable_elastic: False
tunings:
    wait_duration: ${WAIT_DURATION}
    iterations: ${ITERATIONS}
    daemon_mode: False
telemetry:
    enabled: False
    events_backup: False
    logs_backup: False
    prometheus_backup: False
performance_monitoring:
    prometheus_url: ''
    prometheus_bearer_token:
    uuid:
    enable_alerts: False
    alert_profile: config/alerts.yaml
    run_during: during
    exit_on_failure: True
    only_failures: True
    enable_metrics: False
    metrics_profile: config/metrics-report.yaml
    check_critical_alerts: False
health_checks:
    interval: 2
    run_during: ${health_during}
    exit_on_failure: True
    only_failures: False
    config:
        - url: ${HEALTH_CHECK_URL}
          bearer_token: "${HEALTH_CHECK_BEARER_TOKEN:-}"
          auth: "${HEALTH_CHECK_AUTH:-}"
          exit_on_failure: True
          verify_url: True
kubevirt_checks:
    interval: 2
    run_during: []
    exit_on_failure: False
    namespace:
    name:
    only_failures: False
    disconnected: False
    ssh_node: ""
    node_names: ""
object_state_checks:
    interval: 2
    run_during: []
    exit_on_failure: False
    only_failures: False
    config: []
CONFIGEOF
rc=0
"${PYTHON_CMD:-python3.11}" run_kraken.py --config=/tmp/config.yaml || rc=$?
if [ "${rc}" -eq 0 ]; then printf 'passed' > "${RESULT_PATH}"; else printf 'failed' > "${RESULT_PATH}"; fi
exit "${rc}"


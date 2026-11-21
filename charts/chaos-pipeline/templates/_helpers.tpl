{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos-pipeline helpers */}}

{{/* Common labels */}}
{{- define "chaos-pipeline.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos-pipeline annotations */}}
{{- define "chaos-pipeline.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}

{{/* Image reference: (dict "repository" .. "tag" .. "digest" ..), digest takes precedence over the tag */}}
{{- define "chaos-pipeline.image" -}}
{{- if .digest -}}{{ .repository }}@{{ .digest }}{{- else -}}{{ .repository }}:{{ .tag | default "latest" }}{{- end -}}
{{- end -}}

{{/* Shell lines writing /tmp/kubeconfig from the pod service account */}}
{{- define "chaos-pipeline.localKubeconfig" -}}
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
{{- end -}}

{{/* Security context of the chaos steps */}}
{{- define "chaos-pipeline.securityContext" -}}
{{- if .Values.pipeline.privileged -}}
privileged: true
{{- else -}}
allowPrivilegeEscalation: false
runAsNonRoot: true
capabilities:
  drop: ["ALL"]
seccompProfile:
  type: RuntimeDefault
{{- end -}}
{{- end -}}

{{/* Tekton task name of a scenario key: lowercase, dashes */}}
{{- define "chaos-pipeline.taskName" -}}
{{- . | lower | replace "_" "-" | trunc 50 | trimSuffix "-" -}}
{{- end -}}

{{/*
Pipeline tasks of a scenario map, run one after the other.
(dict "scenarios" <map> "first" <name of the task to run after, or ""> "application" <bool> "hubRepository" <string>)
*/}}
{{- define "chaos-pipeline.scenarioTasks" -}}
{{- $previous := .first -}}
{{- $application := .application -}}
{{- $scenarios := .scenarios | default dict -}}
{{- range $name := keys $scenarios | sortAlpha }}
{{- $s := index $scenarios $name }}
{{- if $s.enabled }}
{{- $task := include "chaos-pipeline.taskName" $name }}
- name: {{ $task }}
  {{- if $previous }}
  runAfter:
    - {{ $previous }}
  {{- end }}
  when:
    - input: {{ $name | quote }}
      operator: in
      values: ["$(params.scenarios[*])"]
  timeout: {{ $s.timeout | default "1h0m0s" | quote }}
  {{- if eq ($s.engine | default "core") "hub" }}
  taskRef:
    kind: Task
    name: krkn-hub-scenario
  params:
    - name: image
      value: {{ include "chaos-pipeline.image" (dict "repository" $.hubRepository "tag" ($s.tag | default $name) "digest" $s.digest) | quote }}
    - name: env
      value: |
        {{- range $key := keys ($s.env | default dict) | sortAlpha }}
        {{ $key }}={{ index $s.env $key | toString | squote }}
        {{- end }}
  {{- else }}
  taskRef:
    kind: Task
    name: krkn-run
  params:
    - name: scenario
      value: {{ $name | quote }}
    - name: scenario-type
      value: {{ required (printf "chaos-pipeline: the scenario %s needs a type" $name) $s.type | quote }}
    - name: wait-duration
      value: {{ $s.waitDuration | default 30 | quote }}
    - name: recovery-time
      value: {{ if $s.recoveryTime }}{{ $s.recoveryTime | quote }}{{ else }}"$(params.recovery-time)"{{ end }}
    - name: node-selector
      value: "$(params.node-selector)"
    - name: workload-namespace
      value: "$(params.workload-namespace)"
    - name: health-check-url
      value: "$(params.health-check-url)"
    {{- if $application }}
    - name: target-namespace
      value: "$(params.target-namespace)"
    - name: label-selector
      value: "$(params.label-selector)"
    {{- end }}
  {{- end }}
    - name: cerberus-enabled
      value: "$(params.cerberus-enabled)"
    - name: cerberus-url
      value: "$(params.cerberus-url)"
{{- $previous = $task }}
{{- end }}
{{- end }}
{{- end -}}


{{/*
"true" when helper pods started by krkn need the privileged SCC: forced by pipeline.privilegedWorkloads (true or
false), or, when it is "auto", as soon as an enabled scenario has a node level type (hog, network chaos, time...)
*/}}
{{- define "chaos-pipeline.needsPrivilegedWorkloads" -}}
{{- $p := .Values.pipeline -}}
{{- $mode := $p.privilegedWorkloads | toString -}}
{{- if eq $mode "true" -}}true
{{- else if eq $mode "false" -}}
{{- else -}}
{{- $found := false -}}
{{- range $group := list ($p.infra | default dict) ($p.application | default dict) -}}
{{- if $group.enabled -}}
{{- range $name, $s := ($group.scenarios | default dict) -}}
{{- if $s.enabled -}}
{{- if eq ($s.engine | default "core") "hub" -}}
{{- if regexMatch "hog|network|time|flood|filter|interface|throttle" ($s.tag | default $name) -}}{{- $found = true -}}{{- end -}}
{{- else if has $s.type (list "hog_scenarios" "network_chaos_scenarios" "network_chaos_ng_scenarios" "pod_network_scenarios" "time_scenarios" "syn_flood_scenarios" "storage_throttle_scenarios") -}}{{- $found = true -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if $found -}}true{{- end -}}
{{- end -}}
{{- end -}}


{{/* JSON list of the enabled scenario names of a scenario map, in alphabetical order */}}
{{- define "chaos-pipeline.scenarioNames" -}}
{{- $names := list -}}
{{- range $name := keys (. | default dict) | sortAlpha -}}
{{- if (index $ $name).enabled -}}{{- $names = append $names $name -}}{{- end -}}
{{- end -}}
{{- toJson $names -}}
{{- end -}}

{{/* Namespaces where the service account gets the privileged SCC: privilegedNamespaces plus workloadNamespace */}}
{{- define "chaos-pipeline.privilegedNamespaces" -}}
{{- $p := .Values.pipeline -}}
{{- $ns := $p.privilegedNamespaces | default (list "default") -}}
{{- if $p.workloadNamespace }}{{- $ns = append $ns $p.workloadNamespace -}}{{- end -}}
{{- toJson ($ns | uniq) -}}
{{- end -}}

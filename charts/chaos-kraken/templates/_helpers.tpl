{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos-kraken helpers */}}

{{/* Common labels */}}
{{- define "chaos-kraken.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos-kraken annotations */}}
{{- define "chaos-kraken.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}

{{/* Render a boolean as a YAML/Python friendly True or False: (list <value> <default when unset>) */}}
{{- define "chaos-kraken.bool" -}}
{{- $v := index . 0 -}}
{{- if kindIs "invalid" $v -}}{{- $v = index . 1 -}}{{- end -}}
{{- if $v -}}True{{- else -}}False{{- end -}}
{{- end -}}

{{/* Image reference: (dict "repository" .. "tag" .. "digest" ..), digest takes precedence over the tag */}}
{{- define "chaos-kraken.image" -}}
{{- if .digest -}}{{ .repository }}@{{ .digest }}{{- else -}}{{ .repository }}:{{ .tag | default "latest" }}{{- end -}}
{{- end -}}

{{/* Shell lines writing /tmp/kubeconfig from the pod service account (local mode) */}}
{{- define "chaos-kraken.localKubeconfig" -}}
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

{{/* Security context of the krkn containers */}}
{{- define "chaos-kraken.securityContext" -}}
{{- if .Values.kraken.privileged -}}
privileged: true
{{- else -}}
allowPrivilegeEscalation: false
{{- if .Values.kraken.runAsUser }}
runAsUser: {{ .Values.kraken.runAsUser }}
{{- end }}
runAsNonRoot: true
capabilities:
  drop: ["ALL"]
seccompProfile:
  type: RuntimeDefault
{{- end -}}
{{- end -}}

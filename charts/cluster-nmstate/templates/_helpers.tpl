{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-nmstate.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-nmstate annotations */}}
{{- define "cluster-nmstate.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-nmstate.notes" -}}
-- NMState Network Operator ----------
{{- if .nmstate }}{{- if .nmstate.enabled }}
       nmstate : enabled
{{- end }}{{- end }}
{{- if .nncp }}{{- if .nncp.enabled }}
          nncp : {{ .nncp.name | default "default-network-policy" }}
{{- end }}{{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-costs.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-costs annotations */}}
{{- define "cluster-costs.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-costs.notes" -}}
-- KubeDescheduler ------------------
{{- if .costs }}{{- if .costs.enabled }}
         costs : enabled
{{- end }}{{- end }}
{{- end -}}

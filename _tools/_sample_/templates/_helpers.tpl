{{/* vim: set filetype=mustache: */}}
{{/* STARTX example helpers */}}

{{/* Common labels */}}
{{- define "example.labels" -}}
{{ include "startx.labels" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example annotations */}}
{{- define "example.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
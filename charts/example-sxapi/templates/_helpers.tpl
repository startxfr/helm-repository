{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-sxapi helpers */}}

{{/* Common labels */}}
{{- define "example-sxapi.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-sxapi annotations */}}
{{- define "example-sxapi.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
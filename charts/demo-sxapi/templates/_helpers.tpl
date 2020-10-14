{{/* vim: set filetype=mustache: */}}
{{/* STARTX demo-sxapi helpers */}}

{{/* Common labels */}}
{{- define "demo-sxapi.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common demo-sxapi annotations */}}
{{- define "demo-sxapi.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
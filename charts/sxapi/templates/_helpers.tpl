{{/* vim: set filetype=mustache: */}}
{{/* STARTX sxapi helpers */}}

{{/* Common labels */}}
{{- define "sxapi.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common sxapi annotations */}}
{{- define "sxapi.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
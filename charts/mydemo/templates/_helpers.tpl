{{/* vim: set filetype=mustache: */}}
{{/* STARTX mydemo helpers */}}

{{/* Common labels */}}
{{- define "mydemo.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common mydemo annotations */}}
{{- define "mydemo.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
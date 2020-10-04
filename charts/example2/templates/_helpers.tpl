{{/* vim: set filetype=mustache: */}}
{{/* STARTX example2 helpers */}}

{{/* Common labels */}}
{{- define "example2.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example2 annotations */}}
{{- define "example2.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
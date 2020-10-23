{{/* vim: set filetype=mustache: */}}
{{/* STARTX test2 helpers */}}

{{/* Common labels */}}
{{- define "test2.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common test2 annotations */}}
{{- define "test2.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
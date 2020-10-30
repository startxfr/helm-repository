{{/* vim: set filetype=mustache: */}}
{{/* STARTX project helpers */}}

{{/* Common labels */}}
{{- define "project.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common project annotations */}}
{{- define "project.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
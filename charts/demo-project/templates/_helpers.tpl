{{/* vim: set filetype=mustache: */}}
{{/* STARTX demo-project helpers */}}

{{/* Common labels */}}
{{- define "demo-project.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common demo-project annotations */}}
{{- define "demo-project.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
{{/* vim: set filetype=mustache: */}}
{{/* STARTX demo-deployment helpers */}}

{{/* Common labels */}}
{{- define "demo-deployment.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common demo-deployment annotations */}}
{{- define "demo-deployment.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
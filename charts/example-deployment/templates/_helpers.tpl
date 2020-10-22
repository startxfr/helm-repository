{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-deployment helpers */}}

{{/* Common labels */}}
{{- define "example-deployment.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-deployment annotations */}}
{{- define "example-deployment.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
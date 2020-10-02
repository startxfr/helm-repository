{{/* vim: set filetype=mustache: */}}
{{/* STARTX cluster config helpers */}}

{{/* Common labels */}}
{{- define "my-example.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common my-example annotations */}}
{{- define "my-example.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
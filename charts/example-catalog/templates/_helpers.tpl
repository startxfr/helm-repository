{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-catalog helpers */}}

{{/* Common labels */}}
{{- define "example-catalog.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-catalog annotations */}}
{{- define "example-catalog.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
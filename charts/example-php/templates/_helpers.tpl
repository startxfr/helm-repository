{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-php helpers */}}

{{/* Common labels */}}
{{- define "example-php.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-php annotations */}}
{{- define "example-php.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
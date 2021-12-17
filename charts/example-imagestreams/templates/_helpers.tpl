{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-imagestreams helpers */}}

{{/* Common labels */}}
{{- define "example-imagestreams.labels" -}}
{{ include "startx.labelsCommon" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-imagestreams annotations */}}
{{- define "example-imagestreams.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
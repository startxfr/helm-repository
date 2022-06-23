{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-chaos helpers */}}

{{/* Common labels */}}
{{- define "example-chaos.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common example-chaos annotations */}}
{{- define "example-chaos.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos-monkey helpers */}}

{{/* Common labels */}}
{{- define "chaos-monkey.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos-monkey annotations */}}
{{- define "chaos-monkey.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos helpers */}}

{{/* Common labels */}}
{{- define "chaos.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos annotations */}}
{{- define "chaos.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
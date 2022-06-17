{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos-cerberus helpers */}}

{{/* Common labels */}}
{{- define "chaos-cerberus.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos-cerberus annotations */}}
{{- define "chaos-cerberus.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
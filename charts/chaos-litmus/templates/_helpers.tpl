{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos-litmus helpers */}}

{{/* Common labels */}}
{{- define "chaos-litmus.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos-litmus annotations */}}
{{- define "chaos-litmus.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos-kraken helpers */}}

{{/* Common labels */}}
{{- define "chaos-kraken.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos-kraken annotations */}}
{{- define "chaos-kraken.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
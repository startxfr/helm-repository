{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos-mesh helpers */}}

{{/* Common labels */}}
{{- define "chaos-mesh.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos-mesh annotations */}}
{{- define "chaos-mesh.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
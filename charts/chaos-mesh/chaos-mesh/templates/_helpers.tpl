{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos-mesh helpers */}}

{{/* Common startx labels for the wrapper chart (avoid name conflict with upstream chaos-mesh subchart helper) */}}
{{- define "startx-chaos-mesh.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos-mesh annotations */}}
{{- define "chaos-mesh.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
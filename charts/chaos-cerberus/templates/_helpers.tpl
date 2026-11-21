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

{{/* Render a boolean as a YAML/Python friendly True or False: (list <value> <default when unset>) */}}
{{- define "chaos-cerberus.bool" -}}
{{- $v := index . 0 -}}
{{- if kindIs "invalid" $v -}}{{- $v = index . 1 -}}{{- end -}}
{{- if $v -}}True{{- else -}}False{{- end -}}
{{- end -}}

{{/* Image reference: repository, then digest when set, else tag */}}
{{- define "chaos-cerberus.image" -}}
{{- $i := .Values.cerberus.image -}}
{{- if $i.digest -}}{{ $i.repository }}@{{ $i.digest }}{{- else -}}{{ $i.repository }}:{{ $i.tag | default "latest" }}{{- end -}}
{{- end -}}

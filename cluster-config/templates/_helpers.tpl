{{/* vim: set filetype=mustache: */}}
{{/* STARTX cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-config.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-config annotations */}}
{{- define "cluster-config.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
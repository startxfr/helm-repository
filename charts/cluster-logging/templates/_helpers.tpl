{{/* vim: set filetype=mustache: */}}
{{/* STARTX cluster-logging helpers */}}

{{/* Common labels */}}
{{- define "cluster-logging.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-logging annotations */}}
{{- define "cluster-logging.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common cluster-logging annotations */}}
{{- define "cluster-logging.notes" -}}
-- cluster-logging --------------------
{{- end -}}
{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster RBAC helpers */}}

{{/* Common labels */}}
{{- define "cluster-pipeline.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-pipeline annotations */}}
{{- define "cluster-pipeline.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
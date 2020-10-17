{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-3scale.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-3scale annotations */}}
{{- define "cluster-3scale.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

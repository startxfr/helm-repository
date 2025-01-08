{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-mongo.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-mongo annotations */}}
{{- define "cluster-mongo.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-mongo.notes" -}}
-- MongoDB -----------------------
{{- if .mongo }}{{- if .mongo.enabled }}
         mongo : enabled
{{- end }}{{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-ods.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-ods annotations */}}
{{- define "cluster-ods.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-ods.notes" -}}
-- OpenDataScience -------------------
{{- if .ods }}{{- if .ods.enabled }}
{{- $namespace := .project.project.name | default "default-ods" }}
     ODS : enabled in {{ $namespace }}
ODS name : {{ .ods.name | default "default" | quote }}
{{- end }}{{- end }}
{{- end -}}

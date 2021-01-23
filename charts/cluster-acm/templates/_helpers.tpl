{{/* vim: set filetype=mustache: */}}
{{/* STARTX cluster-acm helpers */}}

{{/* Common labels */}}
{{- define "cluster-acm.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-acm annotations */}}
{{- define "cluster-acm.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common cluster-acm annotations */}}
{{- define "cluster-acm.notes" -}}
-- Advanced Cluster Management -----
{{- if .acm.enabled }}{{- if .acm.mch }}{{- if .acm.mch.enabled }}
{{- $root := . -}}
{{- $namespace := .project.project.name | default "open-cluster-management" -}}
     logging : enabled in {{ $namespace }}
         name : {{ .acm.mch.name | default "multiclusterhub" }}
{{- end }}{{- end }}{{- end }}
{{- end -}}

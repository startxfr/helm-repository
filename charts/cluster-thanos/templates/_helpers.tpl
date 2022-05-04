{{/* vim: set filetype=mustache: */}}
{{/* STARTX cluster-thanos helpers */}}

{{/* Common labels */}}
{{- define "cluster-thanos.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-thanos annotations */}}
{{- define "cluster-thanos.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common cluster-thanos annotations */}}
{{- define "cluster-thanos.notes" -}}
-- Advanced Cluster Management -----
{{- if .thanos.enabled }}{{- if .thanos.mch }}{{- if .thanos.mch.enabled }}
{{- $root := . -}}
{{- $namespace := .project.project.name | default "open-cluster-management-observability" -}}
     logging : enabled in {{ $namespace }}
         name : {{ .thanos.mch.name | default "multiclusterhub" }}
{{- end }}{{- end }}{{- end }}
{{- end -}}

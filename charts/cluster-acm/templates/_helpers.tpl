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
{{- $namespace := .project.project.name | default "open-cluster-management" -}}
          ACM : enabled in {{ $namespace }}
         name : {{ .acm.mch.name | default "multiclusterhub" }}
{{- end }}{{- end }}{{- end }}

-- Observability -------------------
{{- if .observability.enabled }}
{{- $namespace := .project.project.name | default "open-cluster-management" -}}
observability : enabled
    namespace : {{ $namespace }}
{{- end }}

-- Create cluster ------------------
{{- if .create.enabled }}
     creation : enabled
 cluster name : {{ .create.name }}
   cluster ns : {{ .project.project.name }}
{{- end }}

-- Import cluster ------------------
{{- if .import.enabled }}
    importing : enabled
 cluster name : {{ .create.name }}
   cluster ns : {{ .project.project.name }}
{{- end }}

{{- end -}}

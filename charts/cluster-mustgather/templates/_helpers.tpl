{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-mustgather.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-mustgather annotations */}}
{{- define "cluster-mustgather.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-mustgather.notes" -}}
-- MustGather ------------------------
{{- if .report }}{{- if .report.enabled }}
{{- $namespace := .project.project.name | default "default-mustgather" }}
    {{- if .project }}{{- if .project.enabled }}
      project : enabled
    {{- end }}{{- end }}
    {{- if .operator }}{{- if .operator.enabled }}
     operator : enabled
    {{- end }}{{- end }}
    {{- if .redhatCreds }}{{- if .redhatCreds.enabled }}
 redhat creds : {{ .redhatCreds.name }}
    {{- end }}{{- end }}
    {{- if .report }}{{- if .report.enabled }}
       report : enabled in {{ $namespace }}
  report name : {{ .report.name | default "default" | quote }}
    {{- end }}{{- end }}
{{- end }}{{- end }}
{{- end -}}

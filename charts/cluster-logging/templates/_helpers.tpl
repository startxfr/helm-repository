{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-logging.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-logging annotations */}}
{{- define "cluster-logging.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-logging.notes" -}}
-- Metering ------------------------
{{- if .logging }}{{- if .logging.enabled }}
{{- $namespace := .project.project.name | default "default-logging" }}
     logging : enabled in {{ $namespace }}
         name : {{ .logging.name | default "instance" }}
        state : {{ .logging.managementState | default "Managed" }}
    {{- if .logging.elasticsearch }}{{- if .logging.elasticsearch.enabled }}{{- with .logging.elasticsearch }}
elasticsearch : {{ .replicas | default 3 }} node(s) - {{ .storage.size | default "200G" }} {{ .storage.size | default "200G" }}
    {{- end }}{{- end }}{{- end }}
  {{- if .logging.kibana }}{{- if .logging.kibana.enabled }}{{- with .logging.kibana }}
       kibana : {{ .replicas | default 3 }} node(s)
  {{- end }}{{- end }}{{- end }}
  {{- if .logging.curation }}{{- if .logging.curation.enabled }}{{- with .logging.curation }}
      curator : {{ .schedule | default "30 3 * * *" }}
  {{- end }}{{- end }}{{- end }}
  {{- if .logging.collector }}{{- if .logging.collector.enabled }}{{- with .logging.collector }}
         type : {{ .type | default "vector" }}
  {{- end }}{{- end }}{{- end }}
{{- end }}{{- end }}
{{- if .eventrouter }}{{- if .eventrouter.enabled }}
{{- $namespace := .project.project.name | default "default-logging" }}
 eventrouter : enabled in {{ $namespace }}
         name : {{ .eventrouter.name | default "eventrouter" }}
{{- end }}{{- end }}
{{- if .logforwarder }}{{- if .logforwarder.enabled }}
{{- $namespace := .project.project.name | default "default-logging" }}
logforwarder : enabled in {{ $namespace }}
{{- end }}{{- end }}
{{- end -}}

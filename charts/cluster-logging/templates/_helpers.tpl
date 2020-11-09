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
         name : {{ .logging.name | default "default" | quote }}
    {{- if .logging.hive }}{{- if .logging.hive.enabled }}
        {{- with .logging.hive }}
storage class : {{ .storageClass | default "gp2" | quote }}
 storage size : {{ .size | default "5Gi" | quote }}
            {{- if .enabled }}
         hive : enabled
            {{- end }}
        {{- end }}
    {{- end }}{{- end }}
    {{- if .logging.reportingOperator }}{{- if .logging.reportingOperator.enabled }}
    reporting : enabled
    {{- end }}{{- end }}
    {{- if .logging.presto }}{{- if .logging.presto.enabled }}
       presto : enabled
    {{- end }}{{- end }}
{{- end }}{{- end }}
{{- end -}}

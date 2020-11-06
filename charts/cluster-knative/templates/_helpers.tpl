{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-knative.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-knative annotations */}}
{{- define "cluster-knative.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-knative.notes" -}}
-- Metering ------------------------
{{- if .metering }}{{- if .metering.enabled }}
{{- $namespace := .project.project.name | default "default-metering" -}}
metering is enabled in {{- $namespace -}}
name: {{ .metering.name | default "default" | quote }}
    {{- if .metering.hive }}{{- if .metering.hive.enabled }}
        {{- with .metering.hive }}
    storage class: {{ .storageClass | default "gp2" | quote }}
    storage size: {{ .size | default "5Gi" | quote }}
            {{- if .enabled }}
    hive: enabled
            {{- end }}
        {{- end }}
    {{- end }}{{- end }}
    {{- if .metering.reportingOperator }}{{- if .metering.reportingOperator.enabled }}
    reporting-operator: enabled
    {{- end }}{{- end }}
    {{- if .metering.presto }}{{- if .metering.presto.enabled }}
    presto: enabled
    {{- end }}{{- end }}
{{- end }}{{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-metering.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-metering annotations */}}
{{- define "cluster-metering.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-metering.notes" -}}
-- Openshift Container Storage -----
{{- if .ocs }}{{- if .ocs.enabled }}
ocs is enabled
{{- end }}{{- end }}
{{- end -}}

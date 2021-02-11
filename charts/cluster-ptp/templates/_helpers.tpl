{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-ptp.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-ptp annotations */}}
{{- define "cluster-ptp.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-ptp.notes" -}}
-- Precision Time Protocol ---------
{{- if .ptp }}{{- if .ptp.enabled }}
         ptp : enabled
{{- end }}{{- end }}
{{- end -}}

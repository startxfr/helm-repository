{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-kargo.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-kargo annotations */}}
{{- define "cluster-kargo.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-kargo.notes" -}}
-- Precision Time Protocol ---------
{{- if .kargo }}{{- if .kargo.enabled }}
         kargo : enabled
{{- end }}{{- end }}
{{- end -}}

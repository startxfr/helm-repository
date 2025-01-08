{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-maintenance.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-maintenance annotations */}}
{{- define "cluster-maintenance.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-maintenance.notes" -}}
-- NodeMaintenance ------------------
{{- if .maintenance }}{{- if .maintenance.enabled }}
         maintenance : enabled
{{- end }}{{- end }}
{{- end -}}

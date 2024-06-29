{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-mtr.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-mtr annotations */}}
{{- define "cluster-mtr.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-mtr.notes" -}}
-- Migration Toolkit Runtimes -------
{{- if .mtr }}{{- if .mtr.enabled }}
         mtr : enabled
{{- end }}{{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-mtc.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-mtc annotations */}}
{{- define "cluster-mtc.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-mtc.notes" -}}
-- Migration Toolkit Containers -----
{{- if .mtc }}{{- if .mtc.enabled }}
         mtc : enabled
{{- end }}{{- end }}
{{- end -}}

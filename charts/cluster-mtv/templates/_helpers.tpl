{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-mtv.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-mtv annotations */}}
{{- define "cluster-mtv.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-mtv.notes" -}}
-- Migration Toolkit Virt -----------
{{- if .mtv }}{{- if .mtv.enabled }}
         mtv : enabled
{{- end }}{{- end }}
{{- end -}}

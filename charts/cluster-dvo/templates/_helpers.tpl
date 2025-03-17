{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-dvo.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-dvo annotations */}}
{{- define "cluster-dvo.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-dvo.notes" -}}
-- DVO ---------
{{- if .dvo }}{{- if .dvo.enabled }}
         dvo : enabled
{{- end }}{{- end }}
{{- end -}}

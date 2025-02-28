{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-kepler.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-kepler annotations */}}
{{- define "cluster-kepler.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-kepler.notes" -}}
-- Kepler ---------
{{- if .kepler }}{{- if .kepler.enabled }}
         kepler : enabled
{{- end }}{{- end }}
{{- end -}}

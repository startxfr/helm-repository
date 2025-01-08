{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-descheduler.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-descheduler annotations */}}
{{- define "cluster-descheduler.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-descheduler.notes" -}}
-- KubeDescheduler ------------------
{{- if .descheduler }}{{- if .descheduler.enabled }}
         descheduler : enabled
{{- end }}{{- end }}
{{- end -}}

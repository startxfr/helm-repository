{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-redis.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-redis annotations */}}
{{- define "cluster-redis.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-redis.notes" -}}
-- Redis -----------------------
{{- if .redis }}{{- if .redis.enabled }}
         redis : enabled
{{- end }}{{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-couchbase.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-couchbase annotations */}}
{{- define "cluster-couchbase.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-couchbase.notes" -}}
-- Couchbase ---------------------------
{{- if .couchbase }}{{- if .couchbase.enabled }}
         couchbase : enabled
{{- end }}{{- end }}
{{- end -}}

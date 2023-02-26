{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-crunchy.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-crunchy annotations */}}
{{- define "cluster-crunchy.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-crunchy.notes" -}}
-- CrunchyDB -----------------------
{{- if .crunchy }}{{- if .crunchy.enabled }}
         crunchy : enabled
{{- end }}{{- end }}
{{- end -}}

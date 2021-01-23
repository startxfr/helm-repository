{{/* vim: set filetype=mustache: */}}
{{/* STARTX cluster-acm helpers */}}

{{/* Common labels */}}
{{- define "cluster-acm.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-acm annotations */}}
{{- define "cluster-acm.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common cluster-acm annotations */}}
{{- define "cluster-acm.notes" -}}
-- cluster-acm --------------------
{{- end -}}
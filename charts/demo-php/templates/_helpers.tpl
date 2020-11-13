{{/* vim: set filetype=mustache: */}}
{{/* STARTX demo-php helpers */}}

{{/* Common labels */}}
{{- define "demo-php.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common demo-php annotations */}}
{{- define "demo-php.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common demo-php annotations */}}
{{- define "demo-php.notes" -}}
-- demo-php --------------------
{{- end -}}
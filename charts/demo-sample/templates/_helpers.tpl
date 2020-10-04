{{/* vim: set filetype=mustache: */}}
{{/* STARTX demo-sample helpers */}}

{{/* Common labels */}}
{{- define "demo-sample.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common demo-sample annotations */}}
{{- define "demo-sample.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
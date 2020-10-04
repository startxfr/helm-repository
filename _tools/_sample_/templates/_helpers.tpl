{{/* vim: set filetype=mustache: */}}
{{/* STARTX _sample_ helpers */}}

{{/* Common labels */}}
{{- define "_sample_.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common _sample_ annotations */}}
{{- define "_sample_.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
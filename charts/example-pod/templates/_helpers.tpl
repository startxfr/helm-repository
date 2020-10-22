{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-pod helpers */}}

{{/* Common labels */}}
{{- define "example-pod.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-pod annotations */}}
{{- define "example-pod.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
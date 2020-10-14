{{/* vim: set filetype=mustache: */}}
{{/* STARTX demo-pod helpers */}}

{{/* Common labels */}}
{{- define "demo-pod.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common demo-pod annotations */}}
{{- define "demo-pod.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
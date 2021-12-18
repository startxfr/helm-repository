{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-knative helpers */}}

{{/* Common labels */}}
{{- define "example-knative.labels" -}}
{{ include "startx.labelsCommon" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-knative annotations */}}
{{- define "example-knative.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/* STARTX sxapi helpers */}}

{{/* Common labels */}}
{{- define "sxapi.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common sxapi annotations */}}
{{- define "sxapi.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common sxapi note */}}
{{- define "sxapi.notes" -}}
-- Application ----------------
version: {{- .Values.sxapi.version -}}
replicas: {{- .Values.sxapi.replicas -}}
profile: {{- .Values.sxapi.profile -}}
debug: {{- .Values.sxapi.debug -}}
{{- if .Values.sxapi.service -}}{{- if .Values.sxapi.service.enabled -}}
service: enabled
{{- else -}}
service: disabled
{{- end -}}
{{- else -}}
service: disabled
{{- end -}}
{{- end -}}
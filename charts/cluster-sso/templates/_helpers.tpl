{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-sso.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-sso annotations */}}
{{- define "cluster-sso.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-sso.notes" -}}
-- Redhat-SSO ----------------------
{{- if .sso }}{{- if .sso.enabled }}
         sso : enabled
{{- end }}{{- end }}
{{- end -}}

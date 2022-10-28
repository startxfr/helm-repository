{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-certmanager.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-certmanager annotations */}}
{{- define "cluster-certmanager.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-certmanager.notes" -}}
-- Cert-Manager ---------
{{- if .certmanager }}{{- if .certmanager.enabled }}
         certmanager : enabled
{{- end }}{{- end }}
{{- end -}}

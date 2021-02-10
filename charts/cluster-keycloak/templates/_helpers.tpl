{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-keycloak.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-keycloak annotations */}}
{{- define "cluster-keycloak.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-keycloak.notes" -}}
-- Precision Time Protocol ---------
{{- if .ptp }}{{- if .ptp.enabled }}
         ptp : enabled
{{- end }}{{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-compliance.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-compliance annotations */}}
{{- define "cluster-compliance.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-compliance.notes" -}}
-- Keycloak ------------------------
{{- if .keycloak }}{{- if .keycloak.enabled }}
         keycloak : enabled
{{- end }}{{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-nexus.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-nexus annotations */}}
{{- define "cluster-nexus.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-nexus.notes" -}}
-- Keycloak ------------------------
{{- if .keycloak }}{{- if .keycloak.enabled }}
         keycloak : enabled
{{- end }}{{- end }}
{{- end -}}

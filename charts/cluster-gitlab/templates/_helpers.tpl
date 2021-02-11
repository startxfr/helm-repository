{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-gitlab.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-gitlab annotations */}}
{{- define "cluster-gitlab.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-gitlab.notes" -}}
-- Keycloak ------------------------
{{- if .keycloak }}{{- if .keycloak.enabled }}
         keycloak : enabled
{{- end }}{{- end }}
{{- end -}}

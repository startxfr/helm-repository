{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-vpa.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-vpa annotations */}}
{{- define "cluster-vpa.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-vpa.notes" -}}
-- Keycloak ------------------------
{{- if .keycloak }}{{- if .keycloak.enabled }}
         keycloak : enabled
{{- end }}{{- end }}
{{- end -}}

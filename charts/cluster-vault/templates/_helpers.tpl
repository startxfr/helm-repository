{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-vault.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-vault annotations */}}
{{- define "cluster-vault.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-vault.notes" -}}
-- Hashicorp Vault -----------------
{{- if .route }}{{- if .route.enabled }}
        route : enabled
{{- end }}{{- end }}
{{- end -}}

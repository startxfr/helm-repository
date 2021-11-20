{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-vault-config.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-vault-config annotations */}}
{{- define "cluster-vault-config.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-vault-config.notes" -}}
-- Hashicorp Vault -----------------
{{- if .route }}{{- if .route.enabled }}
        route : enabled
{{- end }}{{- end }}
{{- end -}}

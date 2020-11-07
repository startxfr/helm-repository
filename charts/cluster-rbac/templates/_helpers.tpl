{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster RBAC helpers */}}

{{/* Common labels */}}
{{- define "cluster-rbac.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-rbac annotations */}}
{{- define "cluster-rbac.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-rbac.notes" -}}
-- Cluster RBAC --------------------
{{- if .groups.enabled }}
        group : enabled
        {{- range .groups.list }}
              - group {{ .id }}
        {{- end -}}
{{- else }}
 - Cluster RBAC group disabled
{{- end }}
{{- end -}}

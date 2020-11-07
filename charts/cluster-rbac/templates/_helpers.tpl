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
              - Groups enabled ({{ range .groups.list }}{{ .id }},{{- end -}})
   # oc get ClusterRoleBinding {{- if .context.scope }} -l app.startx.fr/scope={{ include "startx.appScope" . }}{{- end }}
   # oc get group {{- if .context.scope }} -l app.startx.fr/scope={{ include "startx.appScope" . }}{{- end }}
{{- else }}
 - Cluster RBAC group disabled
{{- end }}
{{- end -}}

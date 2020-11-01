{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster RBAC helpers */}}

{{/* Common labels */}}
{{- define "cluster-workspace.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-workspace annotations */}}
{{- define "cluster-workspace.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-workspace.notes" -}}
-- Che Cluster ---------------------
{{- if . }}{{- if .enabled }}
name: {{ .name | default "codeready-workspaces" | quote }}
namespace: {{ .Values.project.project.name }}
storage: {{ .storageClass | default "gp2" | quote }}
size:{{ .storageSize | default "1Gi" | quote }}
{{- end }}{{- end }}
{{- end -}}
{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-devworkspaces.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-devworkspaces annotations */}}
{{- define "cluster-devworkspaces.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-devworkspaces.notes" -}}
-- Dev Workspaces -------------------
{{- if .devworkspaces }}{{- if .devworkspaces.enabled }}
         devworkspaces : enabled
{{- end }}{{- end }}
{{- end -}}

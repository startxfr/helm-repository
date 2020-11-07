{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-istio.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-istio annotations */}}
{{- define "cluster-istio.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-istio.notes" -}}
-- Istio ---------------------------
{{- if .istio }}{{- if .istio.enabled }}
{{- $namespace := .project.project.name | default "default-istio" -}}
istio is enabled in {{- $namespace -}}
name: {{ .istio.name | default "default" | quote }}
{{- end }}{{- end }}
{{- end -}}

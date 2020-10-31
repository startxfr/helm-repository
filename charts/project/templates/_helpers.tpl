{{/* vim: set filetype=mustache: */}}
{{/* STARTX project helpers */}}

{{/* Common labels */}}
{{- define "project.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common project annotations */}}
{{- define "project.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common project note */}}
{{- define "project.notes" -}}
{{- if eq .Values.project.type "project" -}}
-- Project --------------------
name: {{- .Values.project.name -}}
description: {{- .Values.project.description | default "description" -}}
display-name: {{- .Values.project.display_name | default .Values.project.name -}}
{{- else -}}
-- Namespace ------------------
name: {{- .Values.project.name -}}
{{- end -}}

-- LimitRange -----------------
{{- if .Values.limits.enabled -}}
{{- .Values.limits.rules }}
{{- else -}}
no limit range defined
{{- end -}}

-- ResourceQuota --------------
{{- if .Values.quotas.enabled -}}
{{- .Values.quotas.rules }}
{{- else -}}
no resource quota defined
{{- end -}}

-- NetworkPolicy --------------
{{- if .Values.networkpolicy.enabled -}}
{{ range .Values.networkpolicy.rules }} 
- {{ .id }}
{{ end }}
{{- else -}}
no network policy defined
{{- end -}}

-- RBAC -----------------------
{{- if .Values.rbac.enabled -}}
{{ range .Values.rbac.groups }}
- group {{ .id }} has role {{ .role }}
{{ end }}
{{ range .Values.rbac.users }}
- user {{ .id }} has role {{ .role }}
{{ end }}
{{- else -}}
no rbac defined
{{- end -}}
{{- end -}}
{{/* vim: set filetype=mustache: */}}
{{/* STARTX project helpers */}}

{{/* Common labels */}}
{{- define "project.labels" -}}
{{ include "startx.labelsCommonStartxMin" . }}
{{ include "startx.labelsCommonHelm" . }}
{{ include "startx.labelsCommonK8SMin" . }}
app.startx.fr/component: {{ include "startx.appComponent" . | default "mycomponent" | quote }}
app.startx.fr/app: {{ include "startx.appName" . | default "myapp" | quote }}
{{- end -}}

{{/* Common project annotations */}}
{{- define "project.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}

{{/* Common project note */}}
{{- define "project.notes" -}}
{{- if eq .project.type "project" }}
-- Project --------------------
         name : {{ .project.name }}
  description : {{ .project.description | default "description" }}
 display-name : {{ .project.display_name | default .project.name }}
{{- else }}
-- Namespace ------------------
         name : {{ .project.name }}
{{- end }}

-- NetworkPolicy --------------
{{- if .networkpolicy.enabled }}
{{- range .networkpolicy.rules }} 
              - {{ .id }}
{{- end }}
{{- else }}
no network policy defined
{{- end }}

-- RBAC -----------------------
{{- if .rbac.enabled }}
{{- range .rbac.groups }}
              - group {{ .id }} has role {{ .role }}
{{- end }}
{{- range .rbac.users }}
              - user {{ .id }} has role {{ .role }}
{{- end }}
{{- else }}
no rbac defined
{{- end }}

-- LimitRange -----------------
{{- if .limits.enabled }}
{{- .limits.rules | nindent 12 }}
{{- else }}
no limit range defined
{{- end }}

-- ResourceQuota --------------
{{- if .quotas.enabled }}
{{- .quotas.rules | nindent 12 }}
{{- else }}
no resource quota defined
{{- end }}

{{- end -}}
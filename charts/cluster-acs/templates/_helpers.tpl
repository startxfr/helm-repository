{{/* vim: set filetype=mustache: */}}
{{/* STARTX cluster-acs helpers */}}

{{/* Common labels */}}
{{- define "cluster-acs.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-acs annotations */}}
{{- define "cluster-acs.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common cluster-acs annotations */}}
{{- define "cluster-acs.notes" -}}
-- Advanced Security Management -----
{{- if .acs.enabled }}{{- if .acs.central }}{{- if .acs.central.enabled }}
{{- $namespace := .project.project.name | default "open-security-management" -}}
     logging : enabled in {{ $namespace }}
         name : {{ .acs.central.name | default "default" }}
{{- end }}{{- end }}{{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "kasten.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common kasten annotations */}}
{{- define "kasten.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "kasten.notes" -}}
-- Kasten K10 ----------------------
{{- if .k10 }}{{- if .k10.enabled }}
{{- $namespace := .project.project.name | default "kasten-io" }}
          k10 : enabled in {{ $namespace }}
         name : {{ .k10.name | default "k10" }}
   tokenAuth : {{ .k10.auth.tokenAuth.enabled | default false }}
   basicAuth : {{ .k10.auth.basicAuth.enabled | default false }}
        route : {{ .k10.route.enabled | default false }}{{ if .k10.route.tls.enabled }} (TLS){{ end }}
{{- end }}{{- end }}
{{- end -}}

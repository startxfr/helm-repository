{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-auth.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-auth annotations */}}
{{- define "cluster-auth.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-auth.notes" -}}
-- Authentication ------------------
{{- if .auth }}{{- if .auth.enabled }}
{{- if .auth.templates -}}
templates:
{{- with .auth.templates.login -}}
  login: "{{- .name | default "default-login" -}}-template"
{{- end -}}
{{- with .auth.templates.errors -}}
  error: "{{- .name | default "default-errors" -}}-template"
{{- end -}}
{{- with .auth.templates.providers -}}
  provider: "{{- .name | default "default-providers" -}}-template"
{{- end -}}
{{- end -}}
{{- if .auth.authBackend -}}{{-  if eq .auth.authBackend.type "htpasswd" -}}
identity: "{{- .name | default "default-htpasswd" -}}_auth"
  type: HTPasswd
  secret: "{{- .name | default "default-htpasswd" -}}-auth"
{{- end -}}{{- end -}}
{{- end }}{{- end }}
{{- end -}}

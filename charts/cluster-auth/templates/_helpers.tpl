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
{{- if .auth.templates }}
{{- with .auth.templates.login }}
    tpl login : {{ .name | default "default-login" }}-template
{{- end }}
{{- with .auth.templates.errors }}
    tpl error : {{ .name | default "default-errors" }}-template
{{- end }}
{{- with .auth.templates.providers }}
 tpl provider : {{ .name | default "default-providers" }}-template
{{- end }}
{{- end }}
{{- if .auth.authBackend -}}
{{ range .auth.authBackend }} 
{{-  if eq .type "htpasswd" -}}
     identity : {{ .name | default "default-htpasswd" }}_auth
         type : HTPasswd
{{- else if eq .type "ldap" -}}
     identity : {{ .name | default "default-ldap" }}_auth
         type : LDAP
{{- end }}
{{ end }}
{{- end -}}
{{- end }}{{- end }}
{{- end -}}

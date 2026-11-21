{{/* vim: set filetype=mustache: */}}
{{/* STARTX chaos-litmus helpers */}}

{{/* Common labels */}}
{{- define "chaos-litmus.labels" -}}
{{ include "startx.labelsCommon" . }}
{{- end -}}

{{/* Common chaos-litmus annotations */}}
{{- define "chaos-litmus.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}

{{/* Credentials are never defaulted: refuse to render the portal without them */}}
{{- define "chaos-litmus.validate" -}}
{{- if .Values.litmus.enabled -}}
{{- $l := .Values.litmus -}}
{{- $mongo := ne (toString ($l.mongodb).enabled) "false" -}}
{{- if and (not $l.existingSecret) (not ($l.adminConfig).ADMIN_PASSWORD) -}}
{{- fail "chaos-litmus: no administrator password. Set litmus.adminConfig.ADMIN_PASSWORD, or litmus.existingSecret to a Secret with the keys ADMIN_USERNAME and ADMIN_PASSWORD." -}}
{{- end -}}
{{- if and $mongo (not (($l.mongodb).auth).existingSecret) (not (($l.mongodb).auth).rootPassword) -}}
{{- fail "chaos-litmus: no MongoDB password. Set litmus.mongodb.auth.rootPassword, or litmus.mongodb.auth.existingSecret to a Secret with the keys mongodb-root-password and mongodb-replica-set-key." -}}
{{- end -}}
{{- if and (not $mongo) (not $l.existingSecret) (not ($l.adminConfig).DBPASSWORD) -}}
{{- fail "chaos-litmus: no password for the external MongoDB. Set litmus.adminConfig.DBUSER and DBPASSWORD, or the keys DB_USER and DB_PASSWORD in litmus.existingSecret." -}}
{{- end -}}
{{- end -}}
{{- end -}}
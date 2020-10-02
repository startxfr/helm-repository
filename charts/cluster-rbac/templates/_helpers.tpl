{{/* vim: set filetype=mustache: */}}

{{/* STARTX cluster RBAC helpers */}}

{{/* Common labels */}}
{{- define "cluster-rbac.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-rbac annotations */}}
{{- define "cluster-rbac.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}
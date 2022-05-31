{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-localstorage.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-localstorage annotations */}}
{{- define "cluster-localstorage.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-localstorage.notes" -}}
-- Openshift Container Storage -----
{{- if .localstorage }}{{- if .localstorage.enabled }}
local storage : enabled
{{- end }}{{- end }}
{{- end -}}

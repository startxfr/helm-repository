{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-3scale.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-3scale annotations */}}
{{- define "cluster-3scale.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-3scale.notes" -}}
-- 3Scale --------------------------
{{- if .manager }}{{- if .manager.enabled }}
manager is enabled
{{- end }}{{- end }}
{{- if .rhn }}{{- if .rhn.enabled }}
RHN is enabled with user {{- .rhn.user }}
{{- end }}{{- end }}
{{- end -}}

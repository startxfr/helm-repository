{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-quay.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-quay annotations */}}
{{- define "cluster-quay.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-quay.notes" -}}
-- Quay registry -------------------
{{- if .quay }}{{- if .quay.enabled }}
quay is enabled
{{- end }}{{- end }}
{{- if .rhn }}{{- if .rhn.enabled }}
RHN is enabled with user {{- .rhn.user }}
{{- end }}{{- end }}
{{- end -}}

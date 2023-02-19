{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-odf.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-odf annotations */}}
{{- define "cluster-odf.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-odf.notes" -}}
-- Openshift Container Storage -----
{{- if .odf }}{{- if .odf.enabled }}
          ODF : enabled
{{- end }}{{- end }}
{{- end -}}

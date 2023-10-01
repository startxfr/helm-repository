{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-storage-efs.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-storage-efs annotations */}}
{{- define "cluster-storage-efs.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-storage-efs.notes" -}}
-- Openshift Container Storage -----
{{- if .efs }}{{- if .efs.enabled }}
          EFS : enabled
{{- end }}{{- end }}
{{- end -}}

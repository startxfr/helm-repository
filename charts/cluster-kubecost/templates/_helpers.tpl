{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-kubecost.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-kubecost annotations */}}
{{- define "cluster-kubecost.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-kubecost.notes" -}}
-- Kubecost ---------
{{- if .kubecost }}{{- if .kubecost.enabled }}
         kubecost : enabled
{{- end }}{{- end }}
{{- end -}}

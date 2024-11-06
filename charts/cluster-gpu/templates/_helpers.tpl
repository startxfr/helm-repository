{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-gpu.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-gpu annotations */}}
{{- define "cluster-gpu.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-gpu.notes" -}}
-- ClusterPolicy -----------
{{- if .gpu }}
{{- if .gpu.enabled }}
       ClusterPolicy : enabled
{{- else }}
       ClusterPolicy : disabled
{{- end }}
{{- end }}
{{- end -}}

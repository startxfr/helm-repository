{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-jenkins.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-jenkins annotations */}}
{{- define "cluster-jenkins.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-jenkins.notes" -}}
-- Jenkins -------------------------
{{- if .jenkins }}{{- if .jenkins.enabled }}
         jenkins : enabled
{{- end }}{{- end }}
{{- end -}}

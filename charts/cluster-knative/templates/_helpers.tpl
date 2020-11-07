{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-knative.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-knative annotations */}}
{{- define "cluster-knative.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-knative.notes" -}}
{{- if .kServing }}{{- if .kServing.enabled }}
-- Knative Serving -----------------
       status : enabled
         name : {{ .kServing.name | default "knative-serving" | quote }} 
    namespace : {{ .projectKServing.project.name | default "default-knative" }}
{{- end }}{{- end }}
{{- if .kEventing }}{{- if .kEventing.enabled }}
-- Knative Eventing ----------------
       status : enabled
         name : {{ .kEventing.name | default "knative-eventing" | quote }} 
    namespace : {{ .projectKEventing.project.name | default "default-knative" }}
{{- end }}{{- end }}
{{- end -}}

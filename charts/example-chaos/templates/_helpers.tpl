{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-chaos helpers */}}

{{/* Common labels */}}
{{- define "example-chaos.labels" -}}
{{ include "startx.labelsCommon" . }}
app.startx.fr/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/part-of: {{ include "startx.appCluster" . | default "cluster" | quote }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | default "myapp-0.0.1" | quote }}
{{- end -}}

{{/* Common example-chaos annotations */}}
{{- define "example-chaos.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-fruitapp-project helpers */}}

{{/* Common labels */}}
{{- define "example-fruitapp-project.labels" -}}
{{ include "startx.labelsCommon" . }}
app.startx.fr/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/part-of: {{ include "startx.appCluster" . | default "cluster" | quote }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | default "myapp-0.0.1" | quote }}
{{- end -}}

{{/* Common example-fruitapp-project annotations */}}
{{- define "example-fruitapp-project.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-pod helpers */}}

{{/* Common labels */}}
{{- define "example-pod.labels" -}}
{{ include "startx.labelsCommon" . }}
app.startx.fr/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/part-of: {{ include "startx.appCluster" . | default "cluster" | quote }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | default "myapp-0.0.1" | quote }}
{{- end -}}

{{/* Common example-pod annotations */}}
{{- define "example-pod.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}
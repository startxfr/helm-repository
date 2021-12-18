{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-knative helpers */}}

{{/* Common labels */}}
{{- define "example-knative.labels" -}}
{{ include "startx.labelsCommon" . }}
app.startx.fr/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/part-of: {{ include "startx.appCluster" . | default "cluster" | quote }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | default "myapp-0.0.1" | quote }}
{{- end -}}

{{/* Common example-knative annotations */}}
{{- define "example-knative.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
{{- end -}}

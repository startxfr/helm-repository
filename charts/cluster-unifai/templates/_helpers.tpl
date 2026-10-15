{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-unifai.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-unifai annotations */}}
{{- define "cluster-unifai.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Resolve the unifai workloads namespace (falls back to project.project.name) */}}
{{- define "cluster-unifai.namespace" -}}
{{- default (default "default-unifai" .Values.project.project.name) .Values.unifai.namespace -}}
{{- end -}}

{{/* Resolve the base application name used to prefix all unifai resources */}}
{{- define "cluster-unifai.appName" -}}
{{- default "unifai" .Values.context.app -}}
{{- end -}}

{{/* Common unifai note */}}
{{- define "cluster-unifai.notes" -}}
-- UnifAI ---------
{{- if .unifai }}{{- if .unifai.enabled }}
         unifai : enabled
       backend  : {{ if .unifai.backend.enabled }}enabled{{ else }}disabled{{ end }}
    multiagent  : {{ if .unifai.multiagent.enabled }}enabled{{ else }}disabled{{ end }}
           rag  : {{ if .unifai.rag.enabled }}enabled{{ else }}disabled{{ end }}
            ui  : {{ if .unifai.ui.enabled }}enabled{{ else }}disabled{{ end }}
      identity  : {{ if .unifai.identity.enabled }}enabled{{ else }}disabled{{ end }}
{{- end }}{{- end }}
{{- end -}}

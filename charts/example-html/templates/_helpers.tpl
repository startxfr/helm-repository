{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-html helpers */}}

{{/* Common labels */}}
{{- define "example-html.labels" -}}
{{ include "startx.labelsCommon" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-html annotations */}}
{{- define "example-html.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common example-html note */}}
{{- define "example-html.notes" -}}
-- Application ----------------
      version : {{ .version }}
     replicas : {{ .replicas }}
        debug : {{ .debug }}
{{- if .service -}}{{- if .service.enabled }}
      service : enabled
{{- else }}
      service : disabled
{{- end }}
{{- else }}
      service : disabled
{{- end }}
{{- end -}}
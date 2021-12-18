{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-php helpers */}}

{{/* Common labels */}}
{{- define "example-php.labels" -}}
{{ include "startx.labelsCommon" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-php annotations */}}
{{- define "example-php.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common example-php note */}}
{{- define "example-php.notes" -}}
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
{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-couchbase helpers */}}

{{/* Common labels */}}
{{- define "example-couchbase.labels" -}}
{{ include "startx.labelsCommon" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-couchbase annotations */}}
{{- define "example-couchbase.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common example-couchbase note */}}
{{- define "example-couchbase.notes" -}}
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
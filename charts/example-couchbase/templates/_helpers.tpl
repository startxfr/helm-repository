{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-couchbase helpers */}}

{{/* Common labels */}}
{{- define "example-couchbase.labels" -}}
{{ include "startx.labelsCommon" . }}
app.startx.fr/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/component: {{ include "startx.appComponent" . | default "component" | quote }}
app.kubernetes.io/part-of: {{ include "startx.appCluster" . | default "cluster" | quote }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | default "myapp-0.0.1" | quote }}
{{- end -}}

{{/* Common example-couchbase annotations */}}
{{- define "example-couchbase.annotations" -}}
{{- include "startx.annotationsCommon" . -}}
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
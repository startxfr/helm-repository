{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-logging.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-logging annotations */}}
{{- define "cluster-logging.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/*
Logging generation managed by this chart.
Return "true" when the new generation (Logging 6.x, API observability.openshift.io) is selected with
observability.enabled, and an empty string when the legacy generation (Logging 5.x) is used
*/}}
{{- define "cluster-logging.observability" -}}
{{- if .Values.observability }}{{- if .Values.observability.enabled }}true{{- end }}{{- end }}
{{- end -}}

{{/*
Render the spec of a custom resource from the values, as is.
Parameters (dict): kind and name (used in the error messages), spec (YAML map), required (fail when the spec is empty)
*/}}
{{- define "cluster-logging.spec" -}}
{{- if and .required (not .spec) -}}
{{- fail (printf "%s %s: spec is required" .kind .name) -}}
{{- end -}}
{{- if not (kindIs "map" .spec) -}}
{{- fail (printf "%s %s: spec must be a YAML map, not a text block" .kind .name) -}}
{{- end -}}
{{ toYaml .spec }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-logging.notes" -}}
-- Metering ------------------------
{{- $observability := dig "enabled" false (.observability | default dict) }}
{{- if not $observability }}
{{- if .logging }}{{- if .logging.enabled }}
{{- $namespace := .project.project.name | default "default-logging" }}
     logging : enabled in {{ $namespace }}
         name : {{ .logging.name | default "instance" }}
        state : {{ .logging.managementState | default "Managed" }}
    {{- if .logging.elasticsearch }}{{- if .logging.elasticsearch.enabled }}{{- with .logging.elasticsearch }}
elasticsearch : {{ .replicas | default 3 }} node(s) - {{ .storage.size | default "200G" }} {{ .storage.size | default "200G" }}
    {{- end }}{{- end }}{{- end }}
  {{- if .logging.kibana }}{{- if .logging.kibana.enabled }}{{- with .logging.kibana }}
       kibana : {{ .replicas | default 3 }} node(s)
  {{- end }}{{- end }}{{- end }}
  {{- if .logging.curation }}{{- if .logging.curation.enabled }}{{- with .logging.curation }}
      curator : {{ .schedule | default "30 3 * * *" }}
  {{- end }}{{- end }}{{- end }}
  {{- if .logging.collector }}{{- if .logging.collector.enabled }}{{- with .logging.collector }}
         type : {{ .type | default "vector" }}
  {{- end }}{{- end }}{{- end }}
{{- end }}{{- end }}
{{- end }}
{{- if .eventrouter }}{{- if .eventrouter.enabled }}
{{- $namespace := .project.project.name | default "default-logging" }}
 eventrouter : enabled in {{ $namespace }}
         name : {{ .eventrouter.name | default "eventrouter" }}
{{- end }}{{- end }}
{{- if not $observability }}
{{- if .logforwarder }}{{- if .logforwarder.enabled }}
{{- $namespace := .project.project.name | default "default-logging" }}
logforwarder : enabled in {{ $namespace }}
{{- end }}{{- end }}
{{- end }}
{{- if $observability }}
{{- $namespace := .project.project.name | default "openshift-logging" }}
observability : enabled in {{ $namespace }} (the logging and logforwarder blocks are ignored)
{{- with .observability.serviceAccount }}{{- if .enabled }}
      account : {{ .name | default "logging-collector" }}
{{- end }}{{- end }}
{{- with .observability.forwarder }}{{- if .enabled }}
    forwarder : {{ .name | default "instance" }}
{{- end }}{{- end }}
{{- with .observability.uiplugin }}{{- if .enabled }}
     uiplugin : logging
{{- end }}{{- end }}
{{- end }}
{{- end -}}

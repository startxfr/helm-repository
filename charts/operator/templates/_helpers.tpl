{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster RBAC helpers */}}

{{/* Common labels */}}
{{- define "operator.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common operator annotations */}}
{{- define "operator.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "operator.notes" -}}
-- Subscription --------
{{- if .Values.subscription }}{{- if .Values.subscription.enabled }}
{{- $name := .Values.subscription.name -}}
{{- $namespace := .Values.operatorGroup.namespace -}}
{{- $version := .Values.subscription.version -}}
name: {{ $name }}
namespace: {{ $namespace }}
{{- with .Values.subscription.operator }}
{{- $operator := . -}}
channel: {{ .channel | default "latest" }}
name: {{ .name | default $name }}
{{- with .source }}
source: {{ .name | default "redhat-operators" }}
sourceNamespace: {{ .namespace | default "openshift-marketplace" }}
{{- end }}
csv: "{{ .csv }}.v{{ $version }}"
{{- end }}
{{- else }}
subscription is disabled
{{- end }}
{{- else }}
subscription is disabled
{{- end }}

-- Operator group --------
{{- if .Values.operatorGroup }}{{- if .Values.operatorGroup.enabled }}
{{- $name := .Values.operatorGroup.name | default .Values.subscription.name -}}
{{- $namespace := .Values.operatorGroup.namespace | default .Values.subscription.namespace -}}
{{- $providedAPIs := .Values.operatorGroup.providedAPIs -}}
name: {{ $name }}
namespace: {{ $namespace }}
providedAPIs: {{ $providedAPIs }}
targetNamespace: {{ $namespace }}
{{- else }}
Operator group is disabled
{{- end }}
{{- else }}
Operator group is disabled
{{- end }}
{{- end -}}
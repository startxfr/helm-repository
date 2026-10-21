{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-qdrant.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-qdrant annotations */}}
{{- define "cluster-qdrant.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Resolve the qdrant workloads namespace (falls back to project.project.name) */}}
{{- define "cluster-qdrant.namespace" -}}
{{- default "default-qdrant" .Values.project.project.name -}}
{{- end -}}

{{/*
Resolve the vendor qdrant-helm subchart's own fullname, mirroring its own "qdrant.fullname"
helper exactly (https://github.com/qdrant/qdrant-helm/blob/main/charts/qdrant/templates/_helpers.tpl) :
fullnameOverride wins, otherwise if the release name already contains "qdrant" (or nameOverride)
it is used as-is, else it is suffixed with "-qdrant".
*/}}
{{- define "cluster-qdrant.qdrantFullname" -}}
{{- if .Values.qdrant.fullnameOverride -}}
{{- .Values.qdrant.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "qdrant" .Values.qdrant.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Common cluster-qdrant note */}}
{{- define "cluster-qdrant.notes" -}}
-- Qdrant ----------------------------
{{- if .qdrant }}{{- if .qdrant.enabled }}
        state : enabled
     replicas : {{ .qdrant.replicaCount | default 1 }}
      cluster : {{ if .qdrant.config.cluster.enabled }}enabled{{ else }}disabled{{ end }}
      apiKey  : {{ if .qdrant.apiKey }}enabled{{ else }}disabled{{ end }}
{{- end }}{{- end }}
{{- end -}}

{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster RBAC helpers */}}

{{/* Common labels */}}
{{- define "cluster-storage.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-storage annotations */}}
{{- define "cluster-storage.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-storage.notes" -}}
-- Cluster Storages classes --------
{{- range .storageClasses }}
              - {{ .id }} provisionned with {{ .provisioner | default "kubernetes.io/aws-ebs" }}
{{- end }}
{{- end -}}
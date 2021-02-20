{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster RBAC helpers */}}

{{/* Common labels */}}
{{- define "cluster-machine.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-machine annotations */}}
{{- define "cluster-machine.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-machine.notes" -}}
-- Cluster Storages classes --------
{{- range .storageClasses }}
              - {{ .id }} provisionned with {{ .provisioner | default "kubernetes.io/aws-ebs" }}
{{- end }}
{{- end -}}
{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster RBAC helpers */}}

{{/* Common labels */}}
{{- define "cluster-kubevirt.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-kubevirt annotations */}}
{{- define "cluster-kubevirt.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-kubevirt.notes" -}}
-- Che Cluster ---------------------
{{- if . }}{{- if .enabled }}
         name : {{ .name | default "codeready-workspaces" }}
      storage : {{ .storageClass | default "gp2" }}
         size : {{ .storageSize | default "1Gi" }}
{{- end }}{{- end }}
{{- end -}}
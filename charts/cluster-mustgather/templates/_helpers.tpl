{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-mustgather.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-mustgather annotations */}}
{{- define "cluster-mustgather.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-mustgather.notes" -}}
-- MustGather ------------------------
{{- if .mustgather }}{{- if .mustgather.enabled }}
{{- $namespace := .project.project.name | default "default-mustgather" }}
     mustgather : enabled in {{ $namespace }}
         name : {{ .mustgather.name | default "default" | quote }}
    {{- if .mustgather.hive }}{{- if .mustgather.hive.enabled }}
        {{- with .mustgather.hive }}
storage class : {{ .storageClass | default "gp3-csi" | quote }}
 storage size : {{ .size | default "5Gi" | quote }}
            {{- if .enabled }}
         hive : enabled
            {{- end }}
        {{- end }}
    {{- end }}{{- end }}
    {{- if .mustgather.reportingOperator }}{{- if .mustgather.reportingOperator.enabled }}
    reporting : enabled
    {{- end }}{{- end }}
    {{- if .mustgather.presto }}{{- if .mustgather.presto.enabled }}
       presto : enabled
    {{- end }}{{- end }}
{{- end }}{{- end }}
{{- end -}}

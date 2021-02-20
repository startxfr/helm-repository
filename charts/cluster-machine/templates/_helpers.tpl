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
-- Cluster MachineSet --------------
{{- if .machineSet.enabled }}
{{ range .machineSet.list }}
              - {{ .name }} 
{{ end }}
{{ else }}
            no machineSet defined
{{ end }}
-- Cluster MachineHealthCheck ------
{{- if .machineHealthCheck.enabled }}
{{ range .machineHealthCheck.list }}
              - {{ .name }} 
{{ end }}
{{ else }}
            no machineHealthCheck defined
{{ end }}
-- Cluster machineAutoscaler -------
{{- if .machineAutoscaler.enabled }}
{{ range .machineAutoscaler.list }}
              - {{ .name }} 
{{ end }}
{{ else }}
            no machineAutoscaler defined
{{ end }}
{{- end -}}
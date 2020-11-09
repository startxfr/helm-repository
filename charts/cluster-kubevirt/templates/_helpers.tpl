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

{{/* Common operator note for cluster config */}}
{{- define "cluster-kubevirt.notes" -}}
-- HyperConverged Cluster ----------
{{- if . }}{{- if .enabled }}
        state : enabled
         name : {{ .name | default "kubevirt-cluster" }}
{{- end }}{{- end }}
{{- end -}}

{{/* Common operator note for VM configuration */}}
{{- define "cluster-kubevirt.notesVms" -}}
-- Virtual Machines ----------------
{{- if . }}{{- if .enabled }}
        state : enabled
         VM's : 
{{ range .list }}
              - {{ .name | default "default-vm" }}
{{ end }}
{{- end }}{{- end }}
{{- end -}}
{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-ansible.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-ansible annotations */}}
{{- define "cluster-ansible.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-ansible.notes" -}}
-- Ansible automation -------------------
{{- if .ansible }}{{- if .ansible.enabled }}
         ansible : enabled
{{- end }}{{- end }}
{{- if .rhn }}{{- if .rhn.enabled }}
          RHN : enabled with user {{ .rhn.user }}
{{- end }}{{- end }}
{{- end -}}

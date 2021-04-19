{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster RBAC helpers */}}

{{/* Common labels */}}
{{- define "cluster-argocd.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-argocd annotations */}}
{{- define "cluster-argocd.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common operator note for cluster config */}}
{{- define "cluster-argocd.notes" -}}
-- ArgoCD Cluster ------------------
{{- if . }}{{- if .enabled }}
        state : enabled
         name : {{ .name | default "argocd-cluster" }}
{{- end }}{{- end }}
{{- end -}}

{{/* Common operator note for VM configuration */}}
{{- define "cluster-argocd.notesApplication" -}}
-- Application ---------------------
{{- if . }}{{- if .enabled }}
        state : enabled
  Application : 
{{ range .list }}
              - {{ .name | default "default-application" }}
{{ end }}
{{- end }}{{- end }}
{{- end -}}
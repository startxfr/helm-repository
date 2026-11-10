{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-cudn.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-cudn annotations */}}
{{- define "cluster-cudn.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common user-defined network note */}}
{{- define "cluster-cudn.notes" -}}
-- OVN-Kubernetes user-defined networks ----------
{{- if .namespaces }}{{- if .namespaces.enabled }}
{{- range .namespaces.list }}
     namespace : {{ .name | default "default-cudn" }} (primary user-defined network)
{{- end }}
{{- end }}{{- end }}
{{- if .clusterNetworks }}{{- if .clusterNetworks.enabled }}
{{- range .clusterNetworks.list }}
          cudn : {{ .name | default "default-cudn" }}{{ with .network }} ({{ .topology | default "no topology" }}){{ end }}
{{- end }}
{{- end }}{{- end }}
{{- if .networks }}{{- if .networks.enabled }}
{{- range .networks.list }}
           udn : {{ .name | default "default-udn" }}{{ with .network }} ({{ .topology | default "no topology" }}){{ end }}
{{- end }}
{{- end }}{{- end }}
{{- end -}}

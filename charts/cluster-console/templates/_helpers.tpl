{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-console.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-console annotations */}}
{{- define "cluster-console.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-console.notes" -}}
-- Console customization -----------
{{- if .console }}{{- if .console.enabled }}
console customisation enabled
{{- if .console.customize -}}
{{- with .console.customize.logo -}}
  logo: "{{- .name | default "default-logo" -}}"
{{- end -}}
{{- end -}}
{{- range .console.links -}}
-         link: "{{- .name | default "default-console-link" -}}"
{{- end }}
{{- range .console.logLinks -}}
- console-link: "{{- .name | default "default-console-loglink" -}}"
{{- end }}
{{- range .console.notifications -}}
- notification: "{{- .name | default "default-console-notification" -}}"
{{- end }}
{{- end }}{{- end }}
{{- end -}}

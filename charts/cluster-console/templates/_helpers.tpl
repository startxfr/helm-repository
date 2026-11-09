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
      console : customisation enabled 
{{- if .console.customize }}
{{- with .console.customize.logo }}
         logo : {{ .name | default "default-logo" }}
{{- end }}
{{- end }}
{{- range .console.links }}
       - link : {{ .name | default "default-console-link" }}
{{- end }}
{{- range .console.logLinks }}
- console-link: {{ .name | default "default-console-loglink" }}
{{- end }}
{{- range .console.notifications }}
- notification: {{ .name | default "default-console-notification" }}
{{- end }}
{{- end }}{{- end }}
{{- end -}}

{{/* Whether a per-theme logo entry defines a logo (file, inline content or inline base64) */}}
{{- define "cluster-console.logoSet" -}}
{{- if . }}{{- if or .file .content .base64 }}true{{- end }}{{- end }}
{{- end -}}

{{/* ConfigMap key of a per-theme logo entry (dict: entry, type, theme): the explicit key, else the key follows the
     source precedence of the ConfigMap template (content, then base64, then file): <type>-<theme>.svg for an inline
     SVG text, <type>-<theme>.png for an inline base64 image, the file name otherwise */}}
{{- define "cluster-console.logoKey" -}}
{{- if .entry.key }}{{ .entry.key }}
{{- else if .entry.content }}{{ printf "%s-%s.svg" .type .theme }}
{{- else if .entry.base64 }}{{ printf "%s-%s.png" .type .theme }}
{{- else }}{{ base .entry.file }}
{{- end }}
{{- end -}}

{{/* Whether a per-theme logo entry is a text file (SVG) stored in data, or a binary stored in binaryData */}}
{{- define "cluster-console.logoIsText" -}}
{{- if .content }}true
{{- else if .base64 }}
{{- else if hasSuffix ".svg" (lower .file) }}true
{{- end }}
{{- end -}}

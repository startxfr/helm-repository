{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-oadp.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-oadp annotations */}}
{{- define "cluster-oadp.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-oadp.notes" -}}
-- Application Data Protection -----
{{- if .oadp }}{{- if .oadp.enabled }}
               oadp : enabled
{{- if .oadp.dataProtectionApplication }}{{- if .oadp.dataProtectionApplication.enabled }}
     dataProtection : enabled
dataProtection name : {{ .oadp.dataProtectionApplication.name | default "myadp" }}
{{- end }}{{- end }}
{{- if .oadp.schedule }}{{- if .oadp.schedule.enabled }}
           Schedule : enabled
      Schedule name : {{ .oadp.schedule.name | default "daily_app" }}
{{- end }}{{- end }}
{{- end }}{{- end }}
{{- end -}}

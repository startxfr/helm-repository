{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-certmanager.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-certmanager annotations */}}
{{- define "cluster-certmanager.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-certmanager.notes" -}}
-- CertIssuer -----------
{{- if .clusterIssuer }}
{{- if .clusterIssuer.enabled }}
       clusterIssuer : enabled
{{- else }}
       clusterIssuer : disabled
{{- end }}
{{- if .clusterIssuer.enabled }}
             issuers : {{ len .clusterIssuer.list }}
{{- range .clusterIssuer.list }}
                       {{ .name | default "cert-issuer" }} (ns: {{ .namespace | default "default" }})
{{- end }}
{{- end }}
{{- end }}
-- Certificate ----------
{{- if .certmanager }}
{{- if .certmanager.enabled }}
         certificate : enabled
{{- else }}
         certificate : disabled
{{- end }}
{{- if .certmanager.enabled }}
        certificates : {{ len .certmanager.list }}
{{- range .certmanager.list }}
                       {{ .kind | default "manual" }}: {{ .name | default "default-certificate" }} (ns: {{ .namespace | default "default" }})
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

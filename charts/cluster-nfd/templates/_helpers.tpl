{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-nfd.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-nfd annotations */}}
{{- define "cluster-nfd.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-nfd.notes" -}}
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
{{- if .nfd }}
{{- if .nfd.enabled }}
         certificate : enabled
{{- else }}
         certificate : disabled
{{- end }}
{{- if .nfd.enabled }}
        certificates : {{ len .nfd.list }}
{{- range .nfd.list }}
                       {{ .kind | default "manual" }}: {{ .name | default "default-certificate" }} (ns: {{ .namespace | default "default" }})
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

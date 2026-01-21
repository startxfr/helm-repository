{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-kafka.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-kafka annotations */}}
{{- define "cluster-kafka.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-kafka.notes" -}}
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
{{- if .kafka }}
{{- if .kafka.enabled }}
         certificate : enabled
{{- else }}
         certificate : disabled
{{- end }}
{{- if .kafka.enabled }}
        certificates : {{ len .kafka.list }}
{{- range .kafka.list }}
                       {{ .kind | default "manual" }}: {{ .name | default "default-certificate" }} (ns: {{ .namespace | default "default" }})
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

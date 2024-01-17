{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-gpu.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-gpu annotations */}}
{{- define "cluster-gpu.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-gpu.notes" -}}
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
{{- if .gpu }}
{{- if .gpu.enabled }}
         certificate : enabled
{{- else }}
         certificate : disabled
{{- end }}
{{- if .gpu.enabled }}
        certificates : {{ len .gpu.list }}
{{- range .gpu.list }}
                       {{ .kind | default "manual" }}: {{ .name | default "default-certificate" }} (ns: {{ .namespace | default "default" }})
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

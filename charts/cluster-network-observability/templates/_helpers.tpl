{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-network-observability.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-network-observability annotations */}}
{{- define "cluster-network-observability.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-network-observability.notes" -}}
-- Network Observability Operator ----
{{- if .flowcollector }}{{- if .flowcollector.enabled }}
 flowcollector : {{ .flowcollector.name | default "cluster" }} (ns: {{ .flowcollector.namespace | default "netobserv" }})
         model : {{ .flowcollector.deploymentModel | default "Service" }}
      sampling : {{ if .flowcollector.agent }}{{ .flowcollector.agent.sampling | default 50 }}{{ else }}50{{ end }}
          loki : {{ if .flowcollector.loki }}{{ if .flowcollector.loki.enabled }}enabled ({{ .flowcollector.loki.mode | default "LokiStack" }}){{ else }}disabled{{ end }}{{ else }}disabled{{ end }}
{{- end }}{{- end }}
{{- if .flowMetrics }}{{- if .flowMetrics.enabled }}
   flowMetrics : {{ len .flowMetrics.list }}
{{- range .flowMetrics.list }}
                 {{ .name | default "default-flowmetric" }} (ns: {{ .namespace | default "netobserv" }})
{{- end }}
{{- end }}{{- end }}
{{- if .lokiRbac }}{{- if .lokiRbac.enabled }}
      lokiRbac : enabled
{{- end }}{{- end }}
{{- end -}}

{{/* Value of a key of a map when it is set (0 and false included), else the default (dict: map, key, default) */}}
{{- define "cluster-network-observability.setOrDefault" -}}
{{- if and (hasKey .map .key) (not (kindIs "invalid" (get .map .key))) }}{{ get .map .key }}{{ else }}{{ .default }}{{ end }}
{{- end -}}

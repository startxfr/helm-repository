{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-loki.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-loki annotations */}}
{{- define "cluster-loki.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-loki.notes" -}}
-- Loki log store ------------------
{{- $namespace := .project.project.name | default "openshift-logging" }}
{{- if .operatorNamespace }}{{- if .operatorNamespace.enabled }}
   operator ns : {{ .operatorNamespace.name | default "openshift-operators-redhat" }}
{{- end }}{{- end }}
{{- if .lokistack }}{{- if .lokistack.enabled }}
     lokistack : {{ .lokistack.name | default "logging-loki" }} in {{ $namespace }}
          size : {{ .lokistack.size | default "1x.small" }}
       storage : {{ dig "storage" "secret" "type" "s3" .lokistack }} (secret {{ dig "storage" "secret" "name" "logging-loki-s3" .lokistack }})
       tenants : {{ dig "tenants" "mode" "openshift-logging" .lokistack }}
{{- if dig "retention" "days" "" .lokistack }}
     retention : {{ dig "retention" "days" "" .lokistack }} day(s)
{{- end }}
{{- if .lokistack.infra_enabled }}
         nodes : infra
{{- end }}
{{- if dig "rules" "enabled" false .lokistack }}
         ruler : enabled
{{- end }}
{{- end }}{{- end }}
{{- if .storageSecret }}{{- if .storageSecret.enabled }}
storage secret : {{ .storageSecret.name | default (dig "storage" "secret" "name" "logging-loki-s3" (.lokistack | default dict)) }}{{ if dig "externalSecret" "enabled" false .storageSecret }} (ExternalSecret){{ end }}
{{- end }}{{- end }}
{{- if .alertingRules }}{{- if .alertingRules.enabled }}
 alertingRules : {{ len .alertingRules.list }} rule(s)
{{- end }}{{- end }}
{{- if .recordingRules }}{{- if .recordingRules.enabled }}
recordingRules : {{ len .recordingRules.list }} rule(s)
{{- end }}{{- end }}
{{- if .rulerConfig }}{{- if .rulerConfig.enabled }}
   rulerConfig : {{ .rulerConfig.name | default "logging-loki-ruler" }}
{{- end }}{{- end }}
{{- end -}}

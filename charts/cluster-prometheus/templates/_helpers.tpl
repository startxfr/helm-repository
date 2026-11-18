{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-prometheus.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-prometheus annotations */}}
{{- define "cluster-prometheus.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/*
Render the spec of a custom resource from the values, as is.
Parameters (dict): kind and name (used in the error messages), spec (YAML map), required (fail when the spec is empty)
*/}}
{{- define "cluster-prometheus.spec" -}}
{{- if and .required (not .spec) -}}
{{- fail (printf "%s %s: spec is required" .kind .name) -}}
{{- end -}}
{{- if not (kindIs "map" .spec) -}}
{{- fail (printf "%s %s: spec must be a YAML map, not a text block" .kind .name) -}}
{{- end -}}
{{ toYaml .spec }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-prometheus.notes" -}}
-- Prometheus monitoring stacks ----
{{- $namespace := .project.project.name | default "default-prometheus" }}
{{- if .operatorNamespace }}{{- if .operatorNamespace.enabled }}
        operator ns : {{ .operatorNamespace.name | default "openshift-cluster-observability-operator" }}
{{- end }}{{- end }}
{{- if .monitoringStacks }}{{- if .monitoringStacks.enabled }}
   monitoringStacks : {{ len .monitoringStacks.list }} declared
{{- range .monitoringStacks.list }}
                      - {{ .name }} in {{ .namespace | default $namespace }} (prometheus http://{{ .name }}-prometheus.{{ .namespace | default $namespace }}.svc:9090)
{{- end }}
{{- end }}{{- end }}
{{- if .thanosQueriers }}{{- if .thanosQueriers.enabled }}
     thanosQueriers : {{ range .thanosQueriers.list }}{{ .name }} {{ end }}
{{- end }}{{- end }}
{{- if .serviceMonitors }}{{- if .serviceMonitors.enabled }}
    serviceMonitors : {{ len .serviceMonitors.list }} declared
{{- end }}{{- end }}
{{- if .podMonitors }}{{- if .podMonitors.enabled }}
        podMonitors : {{ len .podMonitors.list }} declared
{{- end }}{{- end }}
{{- if .scrapeConfigs }}{{- if .scrapeConfigs.enabled }}
      scrapeConfigs : {{ len .scrapeConfigs.list }} declared
{{- end }}{{- end }}
{{- if .prometheusRules }}{{- if .prometheusRules.enabled }}
    prometheusRules : {{ len .prometheusRules.list }} declared
{{- end }}{{- end }}
{{- if .alertmanagerConfigs }}{{- if .alertmanagerConfigs.enabled }}
alertmanagerConfigs : {{ len .alertmanagerConfigs.list }} declared
{{- end }}{{- end }}
{{- if .networkPolicies }}{{- if .networkPolicies.enabled }}
    networkPolicies : {{ len .networkPolicies.list }} declared
{{- end }}{{- end }}
{{- if .routes }}{{- if .routes.enabled }}
             routes : {{ range .routes.list }}{{ .name }} {{ end }}
{{- end }}{{- end }}
{{- if .secrets }}{{- if .secrets.enabled }}
            secrets : {{ range .secrets.list }}{{ .name }}{{ if dig "externalSecret" "enabled" false . }} (ExternalSecret){{ end }} {{ end }}
{{- end }}{{- end }}
{{- end -}}

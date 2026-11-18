{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-metallb.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-metallb annotations */}}
{{- define "cluster-metallb.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/*
Render the spec of a custom resource from the values, as is.
Parameters (dict): kind and name (used in the error messages), spec (YAML map), required (fail when the spec is empty)
*/}}
{{- define "cluster-metallb.spec" -}}
{{- if and .required (not .spec) -}}
{{- fail (printf "%s %s: spec is required" .kind .name) -}}
{{- end -}}
{{- if not (kindIs "map" .spec) -}}
{{- fail (printf "%s %s: spec must be a YAML map, not a text block" .kind .name) -}}
{{- end -}}
{{ toYaml .spec }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-metallb.notes" -}}
-- MetalLB load balancer -----------
{{- $namespace := .project.project.name | default "metallb-system" }}
{{- if .metallb }}{{- if .metallb.enabled }}
          metallb : {{ .metallb.name | default "metallb" }} in {{ $namespace }}
{{- end }}{{- end }}
{{- if .ipAddressPools }}{{- if .ipAddressPools.enabled }}
   ipAddressPools : {{ range .ipAddressPools.list }}{{ .name }} {{ end }}
{{- end }}{{- end }}
{{- if .l2Advertisements }}{{- if .l2Advertisements.enabled }}
 l2Advertisements : {{ range .l2Advertisements.list }}{{ .name }} {{ end }}
{{- end }}{{- end }}
{{- if .bgpPeers }}{{- if .bgpPeers.enabled }}
         bgpPeers : {{ range .bgpPeers.list }}{{ .name }} {{ end }}
{{- end }}{{- end }}
{{- if .bgpAdvertisements }}{{- if .bgpAdvertisements.enabled }}
bgpAdvertisements : {{ range .bgpAdvertisements.list }}{{ .name }} {{ end }}
{{- end }}{{- end }}
{{- if .bfdProfiles }}{{- if .bfdProfiles.enabled }}
      bfdProfiles : {{ range .bfdProfiles.list }}{{ .name }} {{ end }}
{{- end }}{{- end }}
{{- if .communities }}{{- if .communities.enabled }}
      communities : {{ range .communities.list }}{{ .name }} {{ end }}
{{- end }}{{- end }}
{{- if .secrets }}{{- if .secrets.enabled }}
          secrets : {{ range .secrets.list }}{{ .name }}{{ if dig "externalSecret" "enabled" false . }} (ExternalSecret){{ end }} {{ end }}
{{- end }}{{- end }}
{{- end -}}

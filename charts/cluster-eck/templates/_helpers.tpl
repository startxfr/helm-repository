{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-eck.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-eck annotations */}}
{{- define "cluster-eck.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/*
Render the spec of a custom resource from the values, as is.
Parameters (dict): kind and name (used in the error messages), spec (YAML map), required (fail when the spec is empty)
*/}}
{{- define "cluster-eck.spec" -}}
{{- if and .required (not .spec) -}}
{{- fail (printf "%s %s: spec is required" .kind .name) -}}
{{- end -}}
{{- if not (kindIs "map" .spec) -}}
{{- fail (printf "%s %s: spec must be a YAML map, not a text block" .kind .name) -}}
{{- end -}}
{{ toYaml .spec }}
{{- end -}}

{{/*
Render the Route publishing the HTTP service created by the operator for an Elastic resource.
Parameters (dict):
  root      : root context ($)
  name      : name of the route
  namespace : namespace of the route and of the service
  service   : name of the service created by the operator
  config    : the `route` block of the resource (host, annotations, termination, tls)
  wave      : ArgoCD sync-wave of the route
*/}}
{{- define "cluster-eck.route" -}}
{{- $cfg := .config | default dict -}}
{{- $tls := deepCopy ($cfg.tls | default dict) -}}
{{- /* passthrough by default: the Elastic component is the TLS endpoint and presents its own certificate */ -}}
{{- $_ := set $tls "termination" ($cfg.termination | default "passthrough") -}}
{{- if not (hasKey $tls "insecureEdgeTerminationPolicy") -}}
{{- $_ := set $tls "insecureEdgeTerminationPolicy" "Redirect" -}}
{{- end }}
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ .name | quote }}
  namespace: {{ .namespace | quote }}
  labels:
    {{- include "cluster-eck.labels" .root | nindent 4 }}
    app.kubernetes.io/name: "{{- .name -}}-route"
  annotations:
    {{- include "cluster-eck.annotations" .root | nindent 4 }}
    argocd.argoproj.io/sync-wave: {{ .wave | quote }}
    {{- with $cfg.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- with $cfg.host }}
  host: {{ . | quote }}
  {{- end }}
  to:
    kind: Service
    name: {{ .service | quote }}
    weight: 100
  tls:
    {{- toYaml $tls | nindent 4 }}
  wildcardPolicy: None
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-eck.notes" -}}
-- Elastic Cloud on Kubernetes -----
{{- $namespace := .project.project.name | default "default-eck" }}
{{- if .tuned }}{{- if .tuned.enabled }}
         tuned : {{ .tuned.name | default "openshift-elasticsearch" }} (vm.max_map_count={{ .tuned.maxMapCount | default 1048576 | int64 }})
{{- end }}{{- end }}
{{- if .elasticsearch }}{{- if .elasticsearch.enabled }}
 elasticsearch : {{ len .elasticsearch.list }} declared
{{- range .elasticsearch.list }}
                 - {{ .name }} in {{ .namespace | default $namespace }} (https://{{ .name }}-es-http.{{ .namespace | default $namespace }}.svc:9200, password in the secret {{ .name }}-es-elastic-user){{ if dig "route" "enabled" false . }}, route {{ .name }}-es{{ end }}
{{- end }}
{{- end }}{{- end }}
{{- if .kibana }}{{- if .kibana.enabled }}
        kibana : {{ len .kibana.list }} declared
{{- range .kibana.list }}
                 - {{ .name }} in {{ .namespace | default $namespace }} (https://{{ .name }}-kb-http.{{ .namespace | default $namespace }}.svc:5601){{ if dig "route" "enabled" false . }}, route {{ .name }}-kb{{ end }}
{{- end }}
{{- end }}{{- end }}
{{- if .secrets }}{{- if .secrets.enabled }}
       secrets : {{ range .secrets.list }}{{ .name }}{{ if dig "externalSecret" "enabled" false . }} (ExternalSecret){{ end }} {{ end }}
{{- end }}{{- end }}
{{- end -}}

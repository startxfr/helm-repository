{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-cloudnativedb.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-cloudnativedb annotations */}}
{{- define "cluster-cloudnativedb.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-cloudnativedb.notes" -}}
-- CloudNativePG ({{ .flavor | default "community" }}) ----------
{{- if .cluster }}{{- if .cluster.enabled }}
{{- range .cluster.list }}
{{- if .enabled }}
      cluster : {{ .name }} (PostgreSQL {{ .postgresVersion | default 17 }}, {{ .instances | default 1 }} instance(s), backup {{ if (.backup | default dict).enabled }}{{ (.backup | default dict).method | default "barmanObjectStore" }}{{ else }}none{{ end }})
{{- end }}
{{- end }}
{{- end }}{{- end }}
{{- if .loader }}{{- if .loader.enabled }}
       loader : enabled
{{- end }}{{- end }}
{{- end -}}

{{/* Default namespace of the clusters, loaders and s3 secrets */}}
{{- define "cluster-cloudnativedb.defaultNamespace" -}}
{{- if and .Values.project .Values.project.project .Values.project.project.name -}}
{{- .Values.project.project.name -}}
{{- else -}}
{{- .Chart.Name -}}
{{- end -}}
{{- end -}}

{{/* API group and label prefix of the flavor */}}
{{- define "cluster-cloudnativedb.apiGroup" -}}
{{- if eq (.Values.flavor | default "community") "edb" -}}postgresql.k8s.enterprisedb.io{{- else -}}postgresql.cnpg.io{{- end -}}
{{- end -}}
{{- define "cluster-cloudnativedb.labelPrefix" -}}
{{- if eq (.Values.flavor | default "community") "edb" -}}k8s.enterprisedb.io{{- else -}}cnpg.io{{- end -}}
{{- end -}}
{{- define "cluster-cloudnativedb.metricsPrefix" -}}
{{- if eq (.Values.flavor | default "community") "edb" -}}cnp{{- else -}}cnpg{{- end -}}
{{- end -}}

{{/* Entry of s3.list named .name, or an empty dict: dict "root" $ "name" <name> */}}
{{- define "cluster-cloudnativedb.s3Entry" -}}
{{- $found := dict -}}
{{- range (.root.Values.s3 | default dict).list -}}
{{- if eq .name $.name -}}{{- $found = . -}}{{- end -}}
{{- end -}}
{{- toYaml $found -}}
{{- end -}}

{{/* Name of the Barman credentials Secret of an s3.list entry */}}
{{- define "cluster-cloudnativedb.s3SecretName" -}}
{{- printf "%s-barman-s3" .name -}}
{{- end -}}

{{/* Endpoint URL of an s3.list entry */}}
{{- define "cluster-cloudnativedb.s3EndpointUrl" -}}
{{- if .port -}}https://{{ .endpoint }}:{{ .port }}{{- else -}}https://{{ .endpoint }}{{- end -}}
{{- end -}}

{{/* Barman object store credentials block of an s3.list entry (endpointCA, s3Credentials): dict "s3" <entry> */}}
{{- define "cluster-cloudnativedb.s3Credentials" -}}
{{- $secret := include "cluster-cloudnativedb.s3SecretName" .s3 }}
{{- if .s3.caCert }}
endpointCA:
  name: {{ $secret | quote }}
  key: ca.crt
{{- end }}
s3Credentials:
  accessKeyId:
    name: {{ $secret | quote }}
    key: ACCESS_KEY_ID
  secretAccessKey:
    name: {{ $secret | quote }}
    key: ACCESS_SECRET_KEY
  {{- if .s3.region }}
  region:
    name: {{ $secret | quote }}
    key: REGION
  {{- end }}
{{- end -}}

{{/* Image of the instances of a cluster entry: dict "root" $ "cluster" <entry> */}}
{{- define "cluster-cloudnativedb.image" -}}
{{- if .cluster.imageName -}}
{{- .cluster.imageName -}}
{{- else if ne (.root.Values.flavor | default "community") "edb" -}}
{{- printf "ghcr.io/cloudnative-pg/postgresql:%d-system-trixie" (int (.cluster.postgresVersion | default 17)) -}}
{{- end -}}
{{- end -}}

{{/* Barman server name of a cluster entry */}}
{{- define "cluster-cloudnativedb.serverName" -}}
{{- (.backup | default dict).serverName | default .name -}}
{{- end -}}

{{/* Validation of the values: fails the rendering with an explicit message */}}
{{- define "cluster-cloudnativedb.validate" -}}
{{- $root := . -}}
{{- if not (has (.Values.flavor | default "community") (list "community" "edb")) -}}
{{- fail (printf "flavor must be community or edb (got %q)" (toString .Values.flavor)) -}}
{{- end -}}
{{- range .Values.cluster.list -}}
{{- if .enabled -}}
{{- $c := . -}}
{{- $b := $c.backup | default dict -}}
{{- $r := $c.restore | default dict -}}
{{- $ns := $c.namespace | default (include "cluster-cloudnativedb.defaultNamespace" $root) -}}
{{- if and (hasKey $c "instances") (lt (int $c.instances) 1) -}}
{{- fail (printf "cluster %s: instances must be at least 1" $c.name) -}}
{{- end -}}
{{- if and $c.failoverQuorum (not $c.synchronous) -}}
{{- fail (printf "cluster %s: failoverQuorum requires synchronous replication" $c.name) -}}
{{- end -}}
{{- if $b.enabled -}}
{{- if not (has ($b.method | default "barmanObjectStore") (list "barmanObjectStore" "plugin")) -}}
{{- fail (printf "cluster %s: backup.method must be barmanObjectStore or plugin (got %q)" $c.name (toString $b.method)) -}}
{{- end -}}
{{- if not $b.s3 -}}{{- fail (printf "cluster %s: backup.s3 must name an entry of s3.list when backup.enabled" $c.name) -}}{{- end -}}
{{- $s3 := include "cluster-cloudnativedb.s3Entry" (dict "root" $root "name" $b.s3) | fromYaml -}}
{{- if not $s3.name -}}{{- fail (printf "cluster %s: backup.s3 %q is not an entry of s3.list" $c.name $b.s3) -}}{{- end -}}
{{- range $k := list "endpoint" "bucket" "accessKey" "secretKey" -}}
{{- if not (index $s3 $k) -}}{{- fail (printf "s3.list entry %s: %s is required" $s3.name $k) -}}{{- end -}}
{{- end -}}
{{- end -}}
{{- if $r.enabled -}}
{{- if not $b.enabled -}}{{- fail (printf "cluster %s: restore.enabled requires backup.enabled (the restored cluster archives into its own folder)" $c.name) -}}{{- end -}}
{{- if not $r.source -}}{{- fail (printf "cluster %s: restore.source (serverName of the source cluster) is required when restore.enabled" $c.name) -}}{{- end -}}
{{- $own := include "cluster-cloudnativedb.serverName" $c -}}
{{- $ownPrefix := ($b.pathPrefix | default $ns) | trimAll "/" -}}
{{- $srcPrefix := ($r.pathPrefix | default $ownPrefix) | trimAll "/" -}}
{{- if and (eq $r.source $own) (eq $srcPrefix $ownPrefix) (eq ($r.s3 | default $b.s3) $b.s3) -}}
{{- fail (printf "cluster %s: restore.source is the folder this cluster would archive into (%s/%s): set backup.serverName (e.g. %s-r1), restore.pathPrefix or another cluster name" $c.name $ownPrefix $own $c.name) -}}
{{- end -}}
{{- $rs3 := include "cluster-cloudnativedb.s3Entry" (dict "root" $root "name" ($r.s3 | default $b.s3)) | fromYaml -}}
{{- if not $rs3.name -}}{{- fail (printf "cluster %s: restore.s3 %q is not an entry of s3.list" $c.name ($r.s3 | default $b.s3)) -}}{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

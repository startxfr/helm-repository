{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-crunchy.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-crunchy annotations */}}
{{- define "cluster-crunchy.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-crunchy.notes" -}}
-- CrunchyDB -----------------------
{{- if .cluster }}{{- if .cluster.enabled }}
{{- range .cluster.list }}
{{- if .enabled }}
      cluster : {{ .name }} (PostgreSQL {{ .postgresVersion | default 14 }}, {{ .replicas | default 1 }} instance(s), backup {{ include "cluster-crunchy.backupType" . }})
{{- end }}
{{- end }}
{{- end }}{{- end }}
{{- if .loader }}{{- if .loader.enabled }}
       loader : enabled
{{- end }}{{- end }}
{{- end -}}

{{/*
Boolean value of an optional key with a default: dict "d" <map> "k" <key> "def" <bool>.
Returns "true" or "" (usable in if): an explicit false is kept, unlike the default function
*/}}
{{- define "cluster-crunchy.bool" -}}
{{- if hasKey .d .k -}}{{- if index .d .k -}}true{{- end -}}{{- else if .def -}}true{{- end -}}
{{- end -}}

{{/* Default namespace of the clusters, loaders and s3 secrets */}}
{{- define "cluster-crunchy.defaultNamespace" -}}
{{- if and .Values.project .Values.project.project .Values.project.project.name -}}
{{- .Values.project.project.name -}}
{{- else -}}
{{- .Chart.Name -}}
{{- end -}}
{{- end -}}

{{/* Backup type of a cluster entry: none, volume or s3 */}}
{{- define "cluster-crunchy.backupType" -}}
{{- $b := .backup | default dict -}}
{{- if include "cluster-crunchy.bool" (dict "d" $b "k" "enabled" "def" true) -}}
{{- $b.type | default "volume" -}}
{{- else -}}none{{- end -}}
{{- end -}}

{{/* Entry of s3.list named .name, or an empty dict: dict "root" $ "name" <name> */}}
{{- define "cluster-crunchy.s3Entry" -}}
{{- $found := dict -}}
{{- range (.root.Values.s3 | default dict).list -}}
{{- if eq .name $.name -}}{{- $found = . -}}{{- end -}}
{{- end -}}
{{- toYaml $found -}}
{{- end -}}

{{/* Name of the pgBackRest credentials Secret of an s3.list entry */}}
{{- define "cluster-crunchy.s3SecretName" -}}
{{- printf "%s-pgbackrest-s3" .name -}}
{{- end -}}

{{/* pgBackRest global options of an s3.list entry (port, CA, uri style): dict "s3" <entry> */}}
{{- define "cluster-crunchy.s3GlobalOptions" -}}
repo1-s3-uri-style: {{ .s3.uriStyle | default "path" }}
{{- if .s3.port }}
repo1-storage-port: {{ .s3.port | quote }}
{{- end }}
{{- if .s3.caCert }}
repo1-storage-ca-file: /etc/pgbackrest/conf.d/s3-ca.crt
{{- end }}
{{- end -}}

{{/* psql initialization script generated from the optional keys of a cluster entry (owner, extensions) */}}
{{- define "cluster-crunchy.initSQL" -}}
\set ON_ERROR_STOP on
ALTER DATABASE "{{ .database | default .name }}" OWNER TO "{{ .username | default .name }}";
\connect "{{ .database | default .name }}"
{{- range .extensions }}
CREATE EXTENSION IF NOT EXISTS "{{ . }}";
{{- end }}
{{- end -}}

{{/* true when a cluster entry needs an init ConfigMap: initScript, extensions or a chart managed password */}}
{{- define "cluster-crunchy.hasInitSQL" -}}
{{- if or .initScript .extensions .password -}}true{{- end -}}
{{- end -}}

{{/* Validation of the cluster list: fails the rendering with an explicit message */}}
{{- define "cluster-crunchy.validate" -}}
{{- $root := . -}}
{{- range .Values.cluster.list -}}
{{- if .enabled -}}
{{- $c := . -}}
{{- $b := $c.backup | default dict -}}
{{- $r := $c.restore | default dict -}}
{{- $ip := $c.inPlaceRestore | default dict -}}
{{- $btype := include "cluster-crunchy.backupType" $c -}}
{{- if and (ne $btype "none") (not (has $btype (list "volume" "s3"))) -}}
{{- fail (printf "cluster %s: backup.type must be volume or s3 (got %q)" $c.name $btype) -}}
{{- end -}}
{{- if eq $btype "s3" -}}
{{- if not $b.s3 -}}{{- fail (printf "cluster %s: backup.s3 must name an entry of s3.list when backup.type is s3" $c.name) -}}{{- end -}}
{{- $s3 := include "cluster-crunchy.s3Entry" (dict "root" $root "name" $b.s3) | fromYaml -}}
{{- if not $s3.name -}}{{- fail (printf "cluster %s: backup.s3 %q is not an entry of s3.list" $c.name $b.s3) -}}{{- end -}}
{{- range $k := list "endpoint" "region" "bucket" "accessKey" "secretKey" -}}
{{- if not (index $s3 $k) -}}{{- fail (printf "s3.list entry %s: %s is required" $s3.name $k) -}}{{- end -}}
{{- end -}}
{{- end -}}
{{- if $r.enabled -}}
{{- if ne $btype "s3" -}}{{- fail (printf "cluster %s: restore.enabled requires backup.type s3 (the restored cluster archives into its own repository)" $c.name) -}}{{- end -}}
{{- if not $r.source -}}{{- fail (printf "cluster %s: restore.source (repo1-path of the source cluster) is required when restore.enabled" $c.name) -}}{{- end -}}
{{- $own := printf "/%s/%s/repo1" (($b.pathPrefix | default ($c.namespace | default (include "cluster-crunchy.defaultNamespace" $root))) | trimAll "/") $c.name -}}
{{- if and (eq (trimAll "/" $r.source) (trimAll "/" $own)) (eq ($r.s3 | default $b.s3) $b.s3) -}}
{{- fail (printf "cluster %s: restore.source is the repository this cluster would back up into (%s): set backup.pathPrefix or the cluster name to another value" $c.name $own) -}}
{{- end -}}
{{- $rs3 := include "cluster-crunchy.s3Entry" (dict "root" $root "name" ($r.s3 | default $b.s3)) | fromYaml -}}
{{- if not $rs3.name -}}{{- fail (printf "cluster %s: restore.s3 %q is not an entry of s3.list" $c.name ($r.s3 | default $b.s3)) -}}{{- end -}}
{{- end -}}
{{- if and $ip.enabled (ne $btype "s3") -}}
{{- fail (printf "cluster %s: inPlaceRestore requires backup.type s3" $c.name) -}}
{{- end -}}
{{- if and (hasKey $c "replicas") (lt (int $c.replicas) 1) -}}
{{- fail (printf "cluster %s: replicas must be at least 1" $c.name) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

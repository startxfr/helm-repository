{{/* vim: set filetype=mustache: */}}

{{/* cluster-quay-ha helpers */}}

{{/* Namespace of every object rendered by this chart */}}
{{- define "cluster-quay-ha.namespace" -}}
{{- if .Values.namespace -}}
{{ .Values.namespace }}
{{- else if and .Values.project .Values.project.enabled -}}
{{ .Values.project.project.name }}
{{- else -}}
{{ .Release.Namespace }}
{{- end -}}
{{- end -}}

{{/* Namespace of the database clusters (crunchy, cloudnativepg) */}}
{{- define "cluster-quay-ha.dbNamespace" -}}
{{- .Values.database.namespace | default (include "cluster-quay-ha.namespace" .) -}}
{{- end -}}

{{/* Common labels */}}
{{- define "cluster-quay-ha.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common annotations */}}
{{- define "cluster-quay-ha.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* true when the chart renders the databases (crunchy or cloudnativepg) */}}
{{- define "cluster-quay-ha.chartManagedDb" -}}
{{- if has .Values.database.mode (list "crunchy" "cloudnativepg") -}}true{{- end -}}
{{- end -}}

{{/* true when Quay and Clair reach databases outside the Quay operator (crunchy, cloudnativepg, external) */}}
{{- define "cluster-quay-ha.unmanagedDb" -}}
{{- if ne .Values.database.mode "quayOperator" -}}true{{- end -}}
{{- end -}}

{{/* true when the chart must render backups for the databases */}}
{{- define "cluster-quay-ha.dbBackup" -}}
{{- if and .Values.backup.enabled (include "cluster-quay-ha.chartManagedDb" .) -}}true{{- end -}}
{{- end -}}

{{/* API group and label prefix of CloudNativePG / EDB Postgres for Kubernetes */}}
{{- define "cluster-quay-ha.cnpgApiGroup" -}}
{{- if eq .Values.database.cloudnativepg.flavor "edb" -}}postgresql.k8s.enterprisedb.io{{- else -}}postgresql.cnpg.io{{- end -}}
{{- end -}}
{{- define "cluster-quay-ha.cnpgLabelPrefix" -}}
{{- if eq .Values.database.cloudnativepg.flavor "edb" -}}k8s.enterprisedb.io{{- else -}}cnpg.io{{- end -}}
{{- end -}}

{{/* Host, port of the Quay database */}}
{{- define "cluster-quay-ha.quayDbHost" -}}
{{- $db := .Values.database -}}
{{- if eq $db.mode "crunchy" -}}
{{ $db.quay.name }}-primary.{{ include "cluster-quay-ha.dbNamespace" . }}.svc
{{- else if eq $db.mode "cloudnativepg" -}}
{{ $db.quay.name }}-rw.{{ include "cluster-quay-ha.dbNamespace" . }}.svc
{{- else -}}
{{ $db.quay.host }}
{{- end -}}
{{- end -}}
{{- define "cluster-quay-ha.quayDbPort" -}}
{{- if eq .Values.database.mode "external" -}}{{ .Values.database.quay.port }}{{- else -}}5432{{- end -}}
{{- end -}}

{{/* Host, port of the Clair database */}}
{{- define "cluster-quay-ha.clairDbHost" -}}
{{- $db := .Values.database -}}
{{- if eq $db.mode "crunchy" -}}
{{ $db.clair.name }}-primary.{{ include "cluster-quay-ha.dbNamespace" . }}.svc
{{- else if eq $db.mode "cloudnativepg" -}}
{{ $db.clair.name }}-rw.{{ include "cluster-quay-ha.dbNamespace" . }}.svc
{{- else -}}
{{ $db.clair.host }}
{{- end -}}
{{- end -}}
{{- define "cluster-quay-ha.clairDbPort" -}}
{{- if eq .Values.database.mode "external" -}}{{ .Values.database.clair.port }}{{- else -}}5432{{- end -}}
{{- end -}}

{{/* DB_URI of Quay */}}
{{- define "cluster-quay-ha.dbUri" -}}
{{- $db := .Values.database -}}
{{- $uri := printf "postgresql://%s:%s@%s:%s/%s?sslmode=%s" $db.quay.user $db.quay.password (include "cluster-quay-ha.quayDbHost" .) (include "cluster-quay-ha.quayDbPort" .) $db.quay.database $db.tls.mode -}}
{{- if eq $db.tls.mode "verify-full" -}}
{{ $uri }}&sslrootcert=/.postgresql/root.crt
{{- else -}}
{{ $uri }}
{{- end -}}
{{- end -}}

{{/* Connection string of Clair */}}
{{- define "cluster-quay-ha.clairConnString" -}}
{{- $db := .Values.database -}}
{{- $conn := printf "host=%s port=%s dbname=%s user=%s password=%s sslmode=%s pool_max_conns=33" (include "cluster-quay-ha.clairDbHost" .) (include "cluster-quay-ha.clairDbPort" .) $db.clair.database $db.clair.user $db.clair.password $db.tls.mode -}}
{{- if eq $db.tls.mode "verify-full" -}}
{{ $conn }} sslrootcert=/var/run/certs/postgres-ca.crt
{{- else -}}
{{ $conn }}
{{- end -}}
{{- end -}}

{{/* Path prefix in the backup bucket */}}
{{- define "cluster-quay-ha.backupPrefix" -}}
{{- .Values.backup.s3.pathPrefix | default (include "cluster-quay-ha.dbNamespace" .) | trimAll "/" -}}
{{- end -}}

{{/* Path prefix of the backups to restore from (cloudnativepg) */}}
{{- define "cluster-quay-ha.restorePrefix" -}}
{{- .Values.restore.pathPrefix | default (include "cluster-quay-ha.backupPrefix" .) | trimAll "/" -}}
{{- end -}}

{{/* Barman Cloud server name of a chart managed database (cloudnativepg): dict "cluster" */}}
{{- define "cluster-quay-ha.cnpgServerName" -}}
{{- .cluster.cloudnativepg.serverName | default .cluster.name -}}
{{- end -}}

{{/* Endpoint URL of the backup bucket (cloudnativepg) */}}
{{- define "cluster-quay-ha.backupEndpointUrl" -}}
{{- $s3 := .Values.backup.s3 -}}
{{- if $s3.port -}}https://{{ $s3.endpoint }}:{{ $s3.port }}{{- else -}}https://{{ $s3.endpoint }}{{- end -}}
{{- end -}}

{{/* ScheduledBackup schedule: 6 fields (seconds first) from the 5 fields cron of backup.schedules.full */}}
{{- define "cluster-quay-ha.cnpgSchedule" -}}
0 {{ .Values.backup.schedules.full }}
{{- end -}}

{{/* psql initialization script of a chart managed database (crunchy) */}}
{{- define "cluster-quay-ha.initSQL" -}}
\set ON_ERROR_STOP on
ALTER DATABASE "{{ .database }}" OWNER TO "{{ .user }}";
\connect "{{ .database }}"
{{- range .extensions }}
CREATE EXTENSION IF NOT EXISTS "{{ . }}";
{{- end }}
{{- end -}}

{{/* Validation of the values: fails the rendering with an explicit message */}}
{{- define "cluster-quay-ha.validate" -}}
{{- $v := .Values -}}
{{- $db := $v.database -}}
{{- if not (has $db.mode (list "crunchy" "cloudnativepg" "external" "quayOperator")) -}}
{{- fail (printf "database.mode must be one of crunchy, cloudnativepg, external, quayOperator (got %q)" (toString $db.mode)) -}}
{{- end -}}
{{- if not (has $v.storage.mode (list "external" "operator")) -}}
{{- fail (printf "storage.mode must be external or operator (got %q)" (toString $v.storage.mode)) -}}
{{- end -}}
{{- if not (has $db.tls.mode (list "require" "verify-full")) -}}
{{- fail (printf "database.tls.mode must be require or verify-full (got %q)" (toString $db.tls.mode)) -}}
{{- end -}}
{{- if and (eq $db.tls.mode "verify-full") (not $db.tls.caCert) -}}
{{- fail "database.tls.caCert (PEM) is required when database.tls.mode is verify-full" -}}
{{- end -}}
{{- if not (has $db.cloudnativepg.flavor (list "community" "edb")) -}}
{{- fail (printf "database.cloudnativepg.flavor must be community or edb (got %q)" (toString $db.cloudnativepg.flavor)) -}}
{{- end -}}
{{- if ne $db.mode "quayOperator" -}}
{{- if not $db.quay.password -}}{{- fail "database.quay.password is required (secret)" -}}{{- end -}}
{{- if and $v.quay.components.clair (not $db.clair.password) -}}{{- fail "database.clair.password is required when quay.components.clair is true (secret)" -}}{{- end -}}
{{- end -}}
{{- if eq $db.mode "external" -}}
{{- if not $db.quay.host -}}{{- fail "database.quay.host is required with database.mode external" -}}{{- end -}}
{{- if and $v.quay.components.clair (not $db.clair.host) -}}{{- fail "database.clair.host is required with database.mode external and quay.components.clair" -}}{{- end -}}
{{- end -}}
{{- if and (include "cluster-quay-ha.chartManagedDb" .) (lt (int $db.replicas) 1) -}}
{{- fail "database.replicas must be at least 1" -}}
{{- end -}}
{{- if not $v.quay.existingConfigBundleSecret -}}
{{- if not $v.quay.secretKey -}}{{- fail "quay.secretKey is required (secret, 64 random characters)" -}}{{- end -}}
{{- if not $v.quay.databaseSecretKey -}}{{- fail "quay.databaseSecretKey is required (secret, 64 random characters)" -}}{{- end -}}
{{- if and (eq $v.storage.mode "external") (not $v.storage.external.custom) -}}
{{- $s := $v.storage.external -}}
{{- if not (has $s.driver (list "RadosGWStorage" "S3Storage")) -}}
{{- fail (printf "storage.external.driver must be RadosGWStorage or S3Storage (got %q); use storage.external.custom for other drivers" (toString $s.driver)) -}}
{{- end -}}
{{- if and (eq $s.driver "RadosGWStorage") (not $s.host) -}}{{- fail "storage.external.host is required with the RadosGWStorage driver" -}}{{- end -}}
{{- if and (eq $s.driver "S3Storage") (not $s.region) -}}{{- fail "storage.external.region is required with the S3Storage driver (Amazon S3; use RadosGWStorage for any other endpoint)" -}}{{- end -}}
{{- if not $s.bucket -}}{{- fail "storage.external.bucket is required" -}}{{- end -}}
{{- if not $s.accessKey -}}{{- fail "storage.external.accessKey is required (secret)" -}}{{- end -}}
{{- if not $s.secretKey -}}{{- fail "storage.external.secretKey is required (secret)" -}}{{- end -}}
{{- end -}}
{{- if $v.oidc.enabled -}}
{{- if not $v.oidc.server -}}{{- fail "oidc.server is required when oidc.enabled (issuer URL with a trailing slash)" -}}{{- end -}}
{{- if not (hasSuffix "/" $v.oidc.server) -}}{{- fail (printf "oidc.server must end with a trailing slash (got %q): Quay refuses the configuration otherwise" $v.oidc.server) -}}{{- end -}}
{{- if not $v.oidc.clientId -}}{{- fail "oidc.clientId is required when oidc.enabled" -}}{{- end -}}
{{- if not $v.oidc.clientSecret -}}{{- fail "oidc.clientSecret is required when oidc.enabled (secret)" -}}{{- end -}}
{{- if not $v.oidc.serviceName -}}{{- fail "oidc.serviceName is required when oidc.enabled" -}}{{- end -}}
{{- if has ($v.oidc.serviceName | lower) (list "ldap" "jwt" "keystone" "github" "google" "gitlab") -}}{{- fail (printf "oidc.serviceName %q is reserved by Quay: use another name (e.g. SSO, Keycloak)" $v.oidc.serviceName) -}}{{- end -}}
{{- end -}}
{{- if and (not $v.quay.components.route) (not $v.quay.hostname) -}}
{{- fail "quay.hostname is required when quay.components.route is false (the operator demands SERVER_HOSTNAME for an unmanaged route)" -}}
{{- end -}}
{{- if not $v.quay.tls.managed -}}
{{- if or (not $v.quay.tls.cert) (not $v.quay.tls.key) -}}{{- fail "quay.tls.cert and quay.tls.key (PEM) are required when quay.tls.managed is false" -}}{{- end -}}
{{- end -}}
{{- end -}}
{{- if include "cluster-quay-ha.dbBackup" . -}}
{{- $s := $v.backup.s3 -}}
{{- if not $s.endpoint -}}{{- fail "backup.s3.endpoint is required when backup.enabled" -}}{{- end -}}
{{- if not $s.bucket -}}{{- fail "backup.s3.bucket is required when backup.enabled" -}}{{- end -}}
{{- if not $s.accessKey -}}{{- fail "backup.s3.accessKey is required when backup.enabled (secret)" -}}{{- end -}}
{{- if not $s.secretKey -}}{{- fail "backup.s3.secretKey is required when backup.enabled (secret)" -}}{{- end -}}
{{- if and (eq $db.mode "crunchy") (not $s.region) -}}{{- fail "backup.s3.region is required with database.mode crunchy (pgBackRest repo1-s3-region)" -}}{{- end -}}
{{- if not (has $v.backup.cloudnativepg.method (list "barmanObjectStore" "plugin")) -}}
{{- fail (printf "backup.cloudnativepg.method must be barmanObjectStore or plugin (got %q)" (toString $v.backup.cloudnativepg.method)) -}}
{{- end -}}
{{- end -}}
{{- if and $v.restore.enabled (include "cluster-quay-ha.chartManagedDb" .) -}}
{{- if not $v.backup.enabled -}}{{- fail "restore.enabled requires backup.enabled and backup.s3.* (bucket holding the backups)" -}}{{- end -}}
{{- if not $v.restore.quay.source -}}{{- fail "restore.quay.source is required when restore.enabled" -}}{{- end -}}
{{- if and $v.quay.components.clair (not $v.restore.clair.source) -}}{{- fail "restore.clair.source is required when restore.enabled and quay.components.clair" -}}{{- end -}}
{{- /* A new cluster must not archive into the repository it restores from */ -}}
{{- range $key := list "quay" "clair" -}}
{{- if or (eq $key "quay") $v.quay.components.clair -}}
{{- $c := index $db $key -}}
{{- $src := index $v.restore $key "source" -}}
{{- if eq $db.mode "crunchy" -}}
{{- if eq (trimAll "/" $src) (printf "%s/%s/repo1" (include "cluster-quay-ha.backupPrefix" $) $c.name) -}}
{{- fail (printf "restore.%s.source is the repository the new cluster %s would back up into: set backup.s3.pathPrefix to a new value (the source path stays as is)" $key $c.name) -}}
{{- end -}}
{{- else if and (eq $src (include "cluster-quay-ha.cnpgServerName" (dict "cluster" $c))) (eq (include "cluster-quay-ha.restorePrefix" $) (include "cluster-quay-ha.backupPrefix" $)) -}}
{{- fail (printf "restore.%s.source is the Barman server name the new cluster %s would archive into: set database.%s.cloudnativepg.serverName (e.g. %s-r1), another cluster name, or restore.pathPrefix" $key $c.name $key $c.name) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if and $v.restore.inPlace.enabled (ne $db.mode "crunchy") -}}
{{- fail "restore.inPlace is only available with database.mode crunchy" -}}
{{- end -}}
{{- if and $v.restore.inPlace.enabled (not $v.backup.enabled) -}}
{{- fail "restore.inPlace requires backup.enabled" -}}
{{- end -}}
{{- /* Documentation placeholders (<value>) left in the non secret values in use; Argo CD Vault Plugin placeholders (<path:...>) are allowed */ -}}
{{- $ph := dict "quay.hostname" $v.quay.hostname -}}
{{- if and (eq $v.storage.mode "external") (not $v.storage.external.custom) -}}
{{- $_ := set $ph "storage.external.host" $v.storage.external.host -}}
{{- $_ := set $ph "storage.external.bucket" $v.storage.external.bucket -}}
{{- $_ := set $ph "storage.external.region" $v.storage.external.region -}}
{{- end -}}
{{- if include "cluster-quay-ha.dbBackup" . -}}
{{- $_ := set $ph "backup.s3.endpoint" $v.backup.s3.endpoint -}}
{{- $_ := set $ph "backup.s3.bucket" $v.backup.s3.bucket -}}
{{- $_ := set $ph "backup.s3.region" $v.backup.s3.region -}}
{{- end -}}
{{- if $v.oidc.enabled -}}{{- $_ := set $ph "oidc.server" $v.oidc.server -}}{{- end -}}
{{- if eq $db.mode "external" -}}
{{- $_ := set $ph "database.quay.host" $db.quay.host -}}
{{- $_ := set $ph "database.clair.host" $db.clair.host -}}
{{- end -}}
{{- range $name, $val := $ph -}}
{{- $s := toString $val -}}
{{- if and (contains "<" $s) (not (contains "<path:" $s)) -}}
{{- fail (printf "%s still holds the placeholder %s: replace it with the value of your environment" $name $s) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* config.yaml of the registry, as a dict */}}
{{- define "cluster-quay-ha.config" -}}
{{- $v := .Values -}}
{{- $q := $v.quay -}}
{{- $cfg := dict
  "REGISTRY_TITLE" $q.registryTitle
  "REGISTRY_TITLE_SHORT" $q.registryTitleShort
  "AUTHENTICATION_TYPE" "Database"
  "FEATURE_USER_INITIALIZE" $q.userInitialize
  "FEATURE_USER_CREATION" $q.userCreation
  "SUPER_USERS" $q.superUsers
  "DEFAULT_TAG_EXPIRATION" $q.defaultTagExpiration
  "TAG_EXPIRATION_OPTIONS" $q.tagExpirationOptions
  "SECRET_KEY" $q.secretKey
  "DATABASE_SECRET_KEY" $q.databaseSecretKey
-}}
{{- if $q.hostname -}}
{{- $_ := set $cfg "SERVER_HOSTNAME" $q.hostname -}}
{{- end -}}
{{- if include "cluster-quay-ha.unmanagedDb" . -}}
{{- $_ := set $cfg "DB_URI" (include "cluster-quay-ha.dbUri" .) -}}
{{- $args := dict "autorollback" true "threadlocals" true "sslmode" $v.database.tls.mode -}}
{{- if eq $v.database.tls.mode "verify-full" -}}{{- $_ := set $args "sslrootcert" "/.postgresql/root.crt" -}}{{- end -}}
{{- $_ := set $cfg "DB_CONNECTION_ARGS" $args -}}
{{- end -}}
{{- if eq $v.storage.mode "external" -}}
{{- $s := $v.storage.external -}}
{{- $_ := set $cfg "DISTRIBUTED_STORAGE_PREFERENCE" (list "default") -}}
{{- $_ := set $cfg "DISTRIBUTED_STORAGE_DEFAULT_LOCATIONS" (list "default") -}}
{{- if $s.custom -}}
{{- $_ := set $cfg "DISTRIBUTED_STORAGE_CONFIG" $s.custom -}}
{{- else if eq $s.driver "S3Storage" -}}
{{- /* Quay derives the endpoint from s3_region (s3.<region>.amazonaws.com): host and port would be ignored */ -}}
{{- $d := dict "s3_bucket" $s.bucket "s3_access_key" $s.accessKey "s3_secret_key" $s.secretKey "s3_region" $s.region "storage_path" $s.storagePath -}}
{{- $_ := set $cfg "DISTRIBUTED_STORAGE_CONFIG" (dict "default" (list "S3Storage" $d)) -}}
{{- else -}}
{{- $d := dict "hostname" $s.host "is_secure" $s.isSecure "access_key" $s.accessKey "secret_key" $s.secretKey "bucket_name" $s.bucket "storage_path" $s.storagePath "signature_version" "v4" -}}
{{- if $s.port -}}{{- $_ := set $d "port" (int $s.port) -}}{{- end -}}
{{- if $s.region -}}{{- $_ := set $d "region_name" $s.region -}}{{- end -}}
{{- $_ := set $cfg "DISTRIBUTED_STORAGE_CONFIG" (dict "default" (list "RadosGWStorage" $d)) -}}
{{- end -}}
{{- end -}}
{{- if $v.oidc.enabled -}}
{{- $o := $v.oidc -}}
{{- $_ := set $cfg "FEATURE_USER_CREATION" true -}}
{{- if $o.internalAuthentication -}}
{{- $_ := set $cfg "AUTHENTICATION_TYPE" "OIDC" -}}
{{- $_ := set $cfg "FEATURE_TEAM_SYNCING" $o.teamSyncing -}}
{{- if $o.nonSuperuserTeamSyncingSetup -}}{{- $_ := set $cfg "FEATURE_NONSUPERUSER_TEAM_SYNCING_SETUP" true -}}{{- end -}}
{{- end -}}
{{- $login := dict
  "SERVICE_NAME" $o.serviceName
  "OIDC_SERVER" $o.server
  "CLIENT_ID" $o.clientId
  "CLIENT_SECRET" $o.clientSecret
  "LOGIN_SCOPES" $o.loginScopes
  "PREFERRED_USERNAME_CLAIM_NAME" $o.usernameClaim
  "VERIFIED_EMAIL_CLAIM_NAME" $o.emailClaim
-}}
{{- if $o.groupClaim -}}{{- $_ := set $login "PREFERRED_GROUP_CLAIM_NAME" $o.groupClaim -}}{{- end -}}
{{- if $o.pkce -}}{{- $_ := set $login "USE_PKCE" true -}}{{- $_ := set $login "PKCE_METHOD" "S256" -}}{{- end -}}
{{- $_ := set $cfg (printf "%s_LOGIN_CONFIG" ($o.serviceName | upper)) $login -}}
{{- end -}}
{{- $cfg = mergeOverwrite $cfg (deepCopy $q.extraConfig) -}}
{{- toYaml $cfg -}}
{{- end -}}

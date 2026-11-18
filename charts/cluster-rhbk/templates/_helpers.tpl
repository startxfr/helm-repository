{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-rhbk.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-rhbk annotations */}}
{{- define "cluster-rhbk.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Namespace of the RHBK resources (the project namespace) */}}
{{- define "cluster-rhbk.namespace" -}}
{{- .Values.project.project.name | default "default-rhbk" -}}
{{- end -}}

{{/* Name of the Keycloak instance */}}
{{- define "cluster-rhbk.keycloakName" -}}
{{- .Values.rhbk.name | default "default" -}}
{{- end -}}

{{/* Name of the database credentials Secret */}}
{{- define "cluster-rhbk.dbSecretName" -}}
{{- .Values.rhbk.dbSecret.name | default (printf "%s-db-secret" (include "cluster-rhbk.keycloakName" .)) -}}
{{- end -}}

{{/* Name of the bootstrap admin Secret */}}
{{- define "cluster-rhbk.adminSecretName" -}}
{{- .Values.rhbk.adminSecret.name | default (printf "%s-bootstrap-admin" (include "cluster-rhbk.keycloakName" .)) -}}
{{- end -}}

{{/* Name of the development database (StatefulSet and Service) */}}
{{- define "cluster-rhbk.databaseName" -}}
{{- .Values.database.name | default (printf "%s-postgresql" (include "cluster-rhbk.keycloakName" .)) -}}
{{- end -}}

{{/* Hook annotations of the main resources */}}
{{- define "cluster-rhbk.hookAnnotations" -}}
helm.sh/hook: post-install,post-upgrade
helm.sh/hook-weight: "10"
helm.sh/hook-delete-policy: hook-failed
argocd.argoproj.io/hook: PostSync
argocd.argoproj.io/hook-delete-policy: HookFailed
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-rhbk.notes" -}}
-- Red Hat build of Keycloak ------
{{- if .database }}{{- if .database.enabled }}
    database : enabled (development PostgreSQL)
{{- end }}{{- end }}
{{- if .rhbk }}{{- if .rhbk.enabled }}
    keycloak : enabled ({{ .rhbk.name | default "default" }})
{{- end }}{{- end }}
{{- if .route }}{{- if .route.enabled }}
       route : enabled ({{ .route.termination | default "edge" }})
{{- end }}{{- end }}
{{- if .rhbk_realms }}{{- if .rhbk_realms.enabled }}
      realms : enabled ({{ len .rhbk_realms.list }} realm import(s))
{{- end }}{{- end }}
{{- end -}}

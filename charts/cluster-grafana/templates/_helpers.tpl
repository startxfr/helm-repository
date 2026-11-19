{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-grafana.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-grafana annotations */}}
{{- define "cluster-grafana.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Namespace of the Grafana resources (the project namespace) */}}
{{- define "cluster-grafana.namespace" -}}
{{- .Values.project.project.name | default "default-grafana" -}}
{{- end -}}

{{/* Name of the Grafana instance */}}
{{- define "cluster-grafana.grafanaName" -}}
{{- .Values.grafana.name | default "default" -}}
{{- end -}}

{{/* Name of the admin credentials Secret */}}
{{- define "cluster-grafana.adminSecretName" -}}
{{- .Values.grafana.adminSecret.name | default (printf "%s-admin" (include "cluster-grafana.grafanaName" .)) -}}
{{- end -}}

{{/* Name of the OpenID Connect client secret Secret */}}
{{- define "cluster-grafana.oidcSecretName" -}}
{{- .Values.oidc.clientSecret.name | default (printf "%s-oidc-client" (include "cluster-grafana.grafanaName" .)) -}}
{{- end -}}

{{/* Name of the ServiceAccount of the oauth-proxy sidecar */}}
{{- define "cluster-grafana.oauthProxySaName" -}}
{{- .Values.oauthProxy.serviceAccountName | default (printf "%s-oauth-proxy" (include "cluster-grafana.grafanaName" .)) -}}
{{- end -}}

{{/* Name of the Secret holding the serving certificate of the Service */}}
{{- define "cluster-grafana.oauthProxyTlsName" -}}
{{- .Values.oauthProxy.tlsSecretName | default (printf "%s-oauth-tls" (include "cluster-grafana.grafanaName" .)) -}}
{{- end -}}

{{/* Name of the oauth-proxy cookie secret Secret */}}
{{- define "cluster-grafana.oauthProxyCookieName" -}}
{{- .Values.oauthProxy.cookieSecret.name | default (printf "%s-oauth-cookie" (include "cluster-grafana.grafanaName" .)) -}}
{{- end -}}

{{/* Name of the ConfigMap holding the CA bundle trusted to reach the issuer */}}
{{- define "cluster-grafana.oidcCaName" -}}
{{- .Values.oidc.ca.configMap | default (printf "%s-oidc-ca" (include "cluster-grafana.grafanaName" .)) -}}
{{- end -}}

{{/* True when a CA bundle is configured for the OpenID Connect issuer */}}
{{- define "cluster-grafana.oidcCaEnabled" -}}
{{- if and .Values.oidc.enabled (or .Values.oidc.ca.certificate .Values.oidc.ca.injectTrustedBundle .Values.oidc.ca.configMap) -}}true{{- end -}}
{{- end -}}

{{/* Label selecting the Grafana instance of this chart (instanceSelector of datasources and dashboards) */}}
{{- define "cluster-grafana.instanceLabels" -}}
app.startx.fr/grafana: {{ include "cluster-grafana.grafanaName" . | quote }}
{{- end -}}

{{/* Hook annotations of the main resources */}}
{{- define "cluster-grafana.hookAnnotations" -}}
helm.sh/hook: post-install,post-upgrade
helm.sh/hook-weight: "10"
helm.sh/hook-delete-policy: hook-failed
argocd.argoproj.io/hook: PostSync
argocd.argoproj.io/hook-delete-policy: HookFailed
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-grafana.notes" -}}
-- Grafana -------------------------
{{- if .grafana }}{{- if .grafana.enabled }}
     grafana : enabled ({{ .grafana.name | default "default" }}, version {{ .grafana.version | default "operator default" }})
{{- end }}{{- end }}
{{- if .route }}{{- if .route.enabled }}
       route : enabled ({{ .route.termination | default "edge" }})
{{- end }}{{- end }}
{{- if .oidc }}{{- if .oidc.enabled }}
        oidc : enabled ({{ .oidc.issuerUrl | default .oidc.authUrl }})
{{- end }}{{- end }}
{{- if .oauthProxy }}{{- if .oauthProxy.enabled }}
 oauthProxy : enabled ({{ .oauthProxy.image }})
{{- end }}{{- end }}
{{- if .grafana_datasources }}{{- if .grafana_datasources.enabled }}
 datasources : enabled ({{ len .grafana_datasources.list }} datasource(s))
{{- end }}{{- end }}
{{- if .grafana_dashboards }}{{- if .grafana_dashboards.enabled }}
  dashboards : enabled ({{ len .grafana_dashboards.list }} dashboard(s))
{{- end }}{{- end }}
{{- end -}}

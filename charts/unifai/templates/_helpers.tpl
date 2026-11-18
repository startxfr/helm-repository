{{/* vim: set filetype=mustache: */}}

{{/* Common labels */}}
{{- define "unifai.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/* Common annotations */}}
{{- define "unifai.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Selector labels of the operator pod, as set by the upstream manifests */}}
{{- define "unifai.operatorSelector" -}}
control-plane: controller-manager
app.kubernetes.io/name: unifai-operator
{{- end -}}

{{/* Published host of the web interface */}}
{{- define "unifai.uiHost" -}}
{{- $exposure := default dict .Values.stack.spec.exposure -}}
{{- default (printf "unifai-ui-%s.%s" .Release.Namespace .Values.exposure.domain) $exposure.uiHost -}}
{{- end -}}

{{/* Published host of the identity service */}}
{{- define "unifai.identityHost" -}}
{{- $exposure := default dict .Values.stack.spec.exposure -}}
{{- default (printf "unifai-identity-%s.%s" .Release.Namespace .Values.exposure.domain) $exposure.identityHost -}}
{{- end -}}

{{/* Fail early on settings the operator would only reject after install */}}
{{- define "unifai.validate" -}}
{{- if not (has .Values.exposure.type (list "route" "ingress" "none")) -}}
{{- fail (printf "exposure.type must be route, ingress or none (got %q)" .Values.exposure.type) -}}
{{- end -}}
{{- if eq .Values.exposure.type "ingress" -}}
{{- if not .Values.exposure.domain -}}
{{- fail "exposure.type=ingress requires exposure.domain (the DNS domain of the UnifAI hosts)" -}}
{{- end -}}
{{- if not .Values.exposure.ingress.tlsSecretName -}}
{{- fail "exposure.type=ingress requires exposure.ingress.tlsSecretName (UnifAI only generates https:// URLs)" -}}
{{- end -}}
{{- end -}}
{{- if .Values.stack.enabled -}}
{{- $identity := default dict .Values.stack.spec.identity -}}
{{- if $identity.external -}}
{{- $secret := default dict $identity.external.clientSecret -}}
{{- if or (not $identity.external.url) (not $secret.name) (not $secret.key) -}}
{{- fail "stack.spec.identity.external requires url and clientSecret.name / clientSecret.key (a Secret you create first)" -}}
{{- end -}}
{{- else if not (hasKey $identity "keycloak") -}}
{{- fail "stack.spec.identity requires either keycloak (managed, OpenShift only) or external (your own Keycloak)" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Installation summary */}}
{{- define "unifai.notes" -}}
-- UnifAI --------------------------
     operator : {{ if .Values.operator.enabled }}installed by this release{{ else }}not installed (expected on the cluster){{ end }}
        stack : {{ if .Values.stack.enabled }}unifai in namespace {{ .Release.Namespace }}{{ else }}disabled{{ end }}
     exposure : {{ .Values.exposure.type }}
{{- end -}}

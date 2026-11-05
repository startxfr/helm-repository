{{/*
External Secrets Operator support.

"cluster-auth.externalSecret" renders an ExternalSecret that produces the Secret
this chart would otherwise render from its values: same name, namespace and
keys, so every object referencing that Secret keeps working unchanged.
Requires the External Secrets Operator and a (Cluster)SecretStore.

Parameters (dict):
  root      : root context ($)
  name      : name of the target Secret
  namespace : namespace of the target Secret
  config    : the `externalSecret` block of this secret
                enabled         : true to use this mode
                secretStoreRef  : {name, kind} (default: externalSecretDefaults.secretStoreRef)
                refreshInterval : (default: externalSecretDefaults.refreshInterval, then 1h)
                remoteRefs      : map secretKey -> ESO remoteRef ({key, property, version...})
                data            : raw ESO spec.data list
                dataFrom        : raw ESO spec.dataFrom list
                template        : raw ESO spec.target.template
  defaults  : the chart-level `externalSecretDefaults` block
  keys      : keys the target Secret must contain (checked unless dataFrom is used)
  type      : type of the target Secret (e.g. kubernetes.io/tls)
  wave      : ArgoCD sync-wave of the Secret being replaced (optional)
*/}}
{{- define "cluster-auth.externalSecret" -}}
{{- $cfg := .config | default dict -}}
{{- $def := .defaults | default dict -}}
{{- $store := $cfg.secretStoreRef | default $def.secretStoreRef | default dict -}}
{{- $refs := $cfg.remoteRefs | default dict -}}
{{- $id := printf "%s/%s" .namespace .name -}}
{{- if not $store.name -}}
{{- fail (printf "externalSecret %s: secretStoreRef.name is required (in this externalSecret block or in externalSecretDefaults)" $id) -}}
{{- end -}}
{{- if and (empty $refs) (empty $cfg.data) (empty $cfg.dataFrom) -}}
{{- fail (printf "externalSecret %s: set remoteRefs, data or dataFrom" $id) -}}
{{- end -}}
{{- if empty $cfg.dataFrom -}}
{{- $have := keys $refs -}}
{{- range $cfg.data }}{{ $have = append $have .secretKey }}{{ end -}}
{{- with $cfg.template }}{{ with .data }}{{ $have = concat $have (keys .) }}{{ end }}{{ end -}}
{{- range .keys -}}
{{- if not (has . $have) -}}
{{- fail (printf "externalSecret %s: key %q is not provided by remoteRefs, data or template.data" $id .) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $tpl := deepCopy ($cfg.template | default dict) -}}
{{- if and .type (not (hasKey $tpl "type")) -}}
{{- $_ := set $tpl "type" .type -}}
{{- end }}
---
apiVersion: {{ $cfg.apiVersion | default $def.apiVersion | default "external-secrets.io/v1" }}
kind: ExternalSecret
metadata:
  name: {{ .name | quote }}
  namespace: {{ .namespace | quote }}
  labels:
    {{- include "cluster-auth.labels" .root | nindent 4 }}
    app.kubernetes.io/name: {{ printf "%s-externalsecret" .name | quote }}
  annotations:
    {{- include "cluster-auth.annotations" .root | nindent 4 }}
    {{- with .wave }}
    argocd.argoproj.io/sync-wave: {{ . | quote }}
    {{- end }}
spec:
  refreshInterval: {{ $cfg.refreshInterval | default $def.refreshInterval | default "1h" | quote }}
  secretStoreRef:
    name: {{ $store.name | quote }}
    kind: {{ $store.kind | default "ClusterSecretStore" | quote }}
  target:
    name: {{ .name | quote }}
    creationPolicy: Owner
    {{- with $tpl }}
    template:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  {{- if or $refs $cfg.data }}
  data:
    {{- range $key := keys $refs | sortAlpha }}
    - secretKey: {{ $key | quote }}
      remoteRef:
        {{- toYaml (index $refs $key) | nindent 8 }}
    {{- end }}
    {{- with $cfg.data }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $cfg.dataFrom }}
  dataFrom:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}

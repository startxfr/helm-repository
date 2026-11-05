{{/* vim: set filetype=mustache: */}}
{{/* STARTX cluster-acs helpers */}}

{{/* Common labels */}}
{{- define "cluster-acs.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-acs annotations */}}
{{- define "cluster-acs.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common cluster-acs annotations */}}
{{- define "cluster-acs.notes" -}}
-- Advanced Security Management -----
{{- if .acs.enabled }}{{- if .acs.central }}{{- if .acs.central.enabled }}
{{- $namespace := .project.project.name | default "open-security-management" -}}
     logging : enabled in {{ $namespace }}
         name : {{ .acs.central.name | default "default" }}
{{- end }}{{- end }}{{- end }}
{{- if .acs.enabled }}{{- if .acs.securedCluster }}{{- if .acs.securedCluster.enabled }}
{{- $namespace := .project.project.name | default "open-security-management" }}
secured cluster : enabled in {{ $namespace }}
         name : {{ .acs.securedCluster.name | default "stackrox-secured-cluster-services" }}
      cluster : {{ .acs.securedCluster.clusterName }}
      central : {{ .acs.securedCluster.centralEndpoint | default "same namespace" }}
 registration : {{ include "cluster-acs.registrationMode" .acs.securedCluster }} (secret cluster-registration-secret)
{{- end }}{{- end }}{{- end }}
{{- end -}}

{{/* Registration mode of the secured cluster: job, externalSecret or none
     (registration.externalSecret.enabled: true is accepted as an alias of mode externalSecret) */}}
{{- define "cluster-acs.registrationMode" -}}
{{- $registration := .registration | default dict -}}
{{- $mode := $registration.mode | default "job" -}}
{{- if dig "externalSecret" "enabled" false $registration -}}
{{- if eq $mode "none" -}}
{{- fail "cluster-acs: acs.securedCluster.registration.externalSecret.enabled cannot be combined with acs.securedCluster.registration.mode none" -}}
{{- end -}}
{{- $mode = "externalSecret" -}}
{{- end -}}
{{- $mode -}}
{{- end -}}

{{/* Name of the SecuredCluster resource */}}
{{- define "cluster-acs.securedClusterName" -}}
{{- .Values.acs.securedCluster.name | default "stackrox-secured-cluster-services" -}}
{{- end -}}

{{/* Name of this cluster in ACS (acs.securedCluster.clusterName, required: it cannot be changed once registered) */}}
{{- define "cluster-acs.clusterName" -}}
{{- $clusterName := .Values.acs.securedCluster.clusterName | default "" | toString -}}
{{- if not $clusterName }}
{{- fail "cluster-acs: acs.securedCluster.clusterName is required (name of this cluster in ACS, it cannot be changed once the cluster is registered)" }}
{{- end }}
{{- $clusterName -}}
{{- end -}}

{{/* SecuredCluster deployed in the ArgoCD PostSync phase (acs.securedCluster.hooked, or a hooked Central) */}}
{{- define "cluster-acs.securedClusterHooked" -}}
{{- if or (.Values.acs.central | default dict).hooked .Values.acs.securedCluster.hooked -}}true{{- end -}}
{{- end -}}

{{/* Spec of the SecuredCluster (YAML), generated from the acs.securedCluster values */}}
{{- define "cluster-acs.securedClusterSpec" -}}
{{- $sc := .Values.acs.securedCluster -}}
{{- $central := .Values.acs.central | default dict -}}
{{- $spec := dict "clusterName" (include "cluster-acs.clusterName" .) -}}
{{- with $sc.centralEndpoint }}{{ $_ := set $spec "centralEndpoint" . }}{{ end -}}
{{- with $sc.clusterLabels }}{{ $_ := set $spec "clusterLabels" . }}{{ end -}}
{{- $infra := dict -}}
{{- if .Values.acs.infra -}}
{{- $infra = dict "nodeSelector" (dict "node-role.kubernetes.io/infra" "") "tolerations" (list (dict "effect" "NoSchedule" "key" "node-role.kubernetes.io/infra" "operator" "Exists")) -}}
{{- $_ := set $spec "sensor" (deepCopy $infra) -}}
{{- end -}}
{{- $admission := deepCopy $infra -}}
{{- with $sc.admissionControl }}
{{- with .enforcement }}{{ $_ := set $admission "enforcement" . }}{{ end }}
{{- with .failurePolicy }}{{ $_ := set $admission "failurePolicy" . }}{{ end }}
{{- end -}}
{{- with $admission }}{{ $_ := set $spec "admissionControl" . }}{{ end -}}
{{- $perNode := dict -}}
{{- with $sc.perNode }}
{{- with .collection }}{{ $_ := set $perNode "collector" (dict "collection" .) }}{{ end }}
{{- with .taintToleration }}{{ $_ := set $perNode "taintToleration" . }}{{ end }}
{{- end -}}
{{- with $perNode }}{{ $_ := set $spec "perNode" . }}{{ end -}}
{{- with $sc.auditLogs }}{{ $_ := set $spec "auditLogs" (dict "collection" .) }}{{ end -}}
{{- $scanner := dict -}}
{{- with $sc.scanner }}{{ $_ := set $scanner "scannerComponent" . }}{{ end -}}
{{- with $infra }}{{ $_ := set $scanner "analyzer" (deepCopy .) }}{{ $_ := set $scanner "db" (deepCopy .) }}{{ end -}}
{{- with $scanner }}{{ $_ := set $spec "scanner" . }}{{ end -}}
{{- $scannerV4 := dict -}}
{{- with $sc.scannerV4 }}{{ $_ := set $scannerV4 "scannerComponent" . }}{{ end -}}
{{- with $infra }}{{ $_ := set $scannerV4 "indexer" (deepCopy .) }}{{ $_ := set $scannerV4 "db" (deepCopy .) }}{{ end -}}
{{- with $scannerV4 }}{{ $_ := set $spec "scannerV4" . }}{{ end -}}
{{- /* Additional spec (acs.securedCluster.spec) merged over the generated one */ -}}
{{- with $sc.spec }}
{{- $extra := . }}
{{- if kindIs "string" $extra }}{{ $extra = fromYaml $extra }}{{ else }}{{ $extra = deepCopy $extra }}{{ end }}
{{- if hasKey $extra "Error" }}
{{- fail (printf "cluster-acs: acs.securedCluster.spec is not a valid YAML mapping: %s" (index $extra "Error")) }}
{{- end }}
{{- $spec = mustMergeOverwrite $spec $extra }}
{{- end }}
{{- if and (not $central.enabled) (not $spec.centralEndpoint) }}
{{- fail "cluster-acs: acs.securedCluster.centralEndpoint is required when acs.central.enabled is false (central.<namespace>.svc:443 for a Central deployed in the same namespace by another release)" }}
{{- end }}
{{- toYaml $spec -}}
{{- end -}}

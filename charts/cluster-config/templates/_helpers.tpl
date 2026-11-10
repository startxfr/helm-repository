{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-config.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-config annotations */}}
{{- define "cluster-config.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-config.notes" -}}
-- Cluster config ------------------
{{ if .autoscaling.enabled }}
 - Cluster autoscaling enabled (up to {{ default 4 .autoscaling.max.nodes }} nodes, {{ default 32 .autoscaling.max.cores }} Cores and {{ default 1024 .autoscaling.max.memory }} RAM)
  # oc describe ClusterAutoscaler default 
{{ else }}
 - Cluster autoscaling disabled
{{ end }}
{{ if .clusterversion.enabled }}
 - Cluster version enabled (channel {{ default "candidate" .clusterversion.channel }}-{{ default "4.9" .clusterversion.version }})
  # oc describe ClusterVersion version 
{{ else }}
 - Cluster version disabled
{{ end }}
{{ if .alertmanager.enabled }}
 - Cluster alert-manager enabled (receiver {{ default "receiverName" .alertmanager.receiverName }}  is of {{ default "api" .alertmanager.type }} type)
  # oc get secret alertmanager-main -n openshift-monitoring
{{ else }}
 - Cluster alert-manager disabled
{{ end }}
{{ if .imageprunner.enabled }}
 - Cluster image prunner enabled (scheduled every {{ default "30 * * * *" .imageprunner.schedule }})
  # oc describe ImagePruner cluster 
{{ else }}
 - Cluster image prunner disabled
{{ end }}
{{ if .projecttemplate.enabled }}
 - Cluster project template enabled (with{{ if .projecttemplate.rbac.enabled }}{{ else }}out{{ end }} RBAC, with{{ if .projecttemplate.networkpolicy.enabled }}{{ else }}out{{ end }} NetworkPolicy)
  # oc describe template project-request -n openshift-config
{{ else }}
 - Cluster project template disabled
{{ end }}
{{ if .redhat.enabled }}
 - Cluster redhat projects enabled (with{{ if .redhat.operators }}{{ else }}out{{ end }} RH operators)
  # oc describe ns openshift-operators-redhat
{{ else }}
 - Cluster Redhat namespace disabled
{{ end }}
{{ if .tracing.enabled }}
 - Cluster opentracing projects enabled (with{{ if .tracing.operators }}{{ else }}out{{ end }} OpenTracing operators)
  # oc describe ns openshift-distributed-tracing
{{ else }}
 - Cluster OpenTracing namespace disabled
{{ end }}
{{- end -}}

{{/* Scheduling of a monitoring component on the infra nodes (nodeSelector and tolerations) */}}
{{- define "cluster-config.monitoring.infraPlacement" -}}
nodeSelector:
  node-role.kubernetes.io/infra: ''
tolerations:
  - effect: NoSchedule
    key: node-role.kubernetes.io/infra
    operator: Exists
  - effect: NoExecute
    key: node-role.kubernetes.io/infra
    operator: Exists
{{- end -}}

{{/* External labels of the platform Prometheus: context labels plus custom labels, reserved keys rejected */}}
{{- define "cluster-config.monitoring.externalLabels" -}}
{{- $labels := dict -}}
{{- $cfg := .Values.monitoring.externalLabels | default dict -}}
{{- if ne (toString $cfg.contextLabels) "false" }}
{{- $_ := set $labels "scope" (include "startx.appScope" .) -}}
{{- $_ := set $labels "environment" (include "startx.appEnvironment" .) -}}
{{- $_ := set $labels "cluster_name" (include "startx.appCluster" .) -}}
{{- end }}
{{- range $key, $value := $cfg.custom | default dict }}
{{- if has $key (list "prometheus" "prometheus_replica" "cluster") }}
{{- fail (printf "monitoring.externalLabels.custom: the key %q is reserved by OpenShift (prometheus, prometheus_replica, cluster)" $key) }}
{{- end }}
{{- $_ := set $labels $key (toString $value) -}}
{{- end }}
{{- toYaml $labels -}}
{{- end -}}

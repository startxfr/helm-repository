{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster router helpers */}}

{{/* Common labels */}}
{{- define "cluster-router.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-router annotations */}}
{{- define "cluster-router.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-router.notes" -}}
-- Cluster router ------------------
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
{{- end -}}
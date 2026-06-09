{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-keepalived.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}

{{/* Common cluster-keepalived annotations */}}
{{- define "cluster-keepalived.annotations" -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-keepalived.notes" -}}
-- Keepalived -------------------
{{- if .Values.keepalived }}
{{- if .Values.keepalived.enabled }}
         keepalived : enabled
{{- if .Values.keepalived.groups }}
{{- if .Values.keepalived.groups.enabled }}
         keepalived groups : {{ .Values.keepalived.groups.list | len }} group(s)
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.publicIngress }}
{{- if .Values.publicIngress.enabled }}
         public ingress : enabled
         external ip : {{ .Values.publicIngress.externalIP.ip }}
{{- end }}
{{- end }}
-- Network Configuration ---------
{{- if .Values.clusterNetwork }}
{{- if .Values.clusterNetwork.enabled }}
         cluster network : enabled
{{- if .Values.clusterNetwork.externalIP }}
{{- if .Values.clusterNetwork.externalIP.autoAssignCIDRs }}
         external ips : {{ .Values.clusterNetwork.externalIP.autoAssignCIDRs | join ", " }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
-- Ingress Controller -----------
{{- if .Values.ingressController }}
{{- if .Values.ingressController.enabled }}
         ingress controller : {{ .Values.ingressController.name }} enabled
         domain : {{ .Values.ingressController.domain }}
         replicas : {{ .Values.ingressController.replicas }}
{{- end }}
{{- end }}
{{- if .Values.ingressControllerService }}
{{- if .Values.ingressControllerService.enabled }}
         ingress service : {{ .Values.ingressControllerService.name }} enabled
{{- if .Values.ingressControllerService.externalIPs }}
         service external ips : {{ .Values.ingressControllerService.externalIPs | join ", " }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}

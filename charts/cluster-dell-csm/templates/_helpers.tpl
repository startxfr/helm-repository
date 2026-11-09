{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-dell-csm.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-dell-csm annotations */}}
{{- define "cluster-dell-csm.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* CSIDriver name (provisioner) of the Dell driver selected by csm.driverType */}}
{{- define "cluster-dell-csm.provisioner" -}}
{{- $drivers := dict "powerstore" "csi-powerstore.dellemc.com" "powermax" "csi-powermax.dellemc.com" "powerflex" "csi-vxflexos.dellemc.com" "isilon" "csi-isilon.dellemc.com" "powerscale" "csi-isilon.dellemc.com" "unity" "csi-unity.dellemc.com" -}}
{{- get $drivers (.Values.csm.driverType | default "powerstore") | default "csi-powerstore.dellemc.com" -}}
{{- end -}}

{{/* Common operator note */}}
{{- define "cluster-dell-csm.notes" -}}
-- Dell Container Storage Modules --
{{- if .csm }}{{- if .csm.enabled }}
           csm : {{ .csm.name | default "powerstore" }} ({{ .csm.driverType | default "powerstore" }} driver, CSM {{ .csm.version | default "operator default" }})
{{- end }}{{- end }}
{{- if .arraySecret }}{{- if .arraySecret.enabled }}
  array secret : {{ .arraySecret.name | default .csm.authSecret | default (printf "%s-config" (.csm.name | default "powerstore")) }}{{- if dig "externalSecret" "enabled" false .arraySecret }} (ExternalSecret){{- end }}
{{- end }}{{- end }}
{{- if .storageClasses }}{{- if .storageClasses.enabled }}
storage classes : {{ len .storageClasses.list }} declared
{{- range .storageClasses.list }}
                 - {{ .name }} (reclaim={{ .reclaimPolicy | default "Delete" }}{{ if .isDefault }}, DEFAULT{{ end }})
{{- end }}
{{- end }}{{- end }}
{{- if .volumeSnapshotClasses }}{{- if .volumeSnapshotClasses.enabled }}
snapshot classes : {{ len .volumeSnapshotClasses.list }} declared
{{- range .volumeSnapshotClasses.list }}
                 - {{ .name }} (deletion={{ .deletionPolicy | default "Delete" }}{{ if .isDefault }}, DEFAULT{{ end }})
{{- end }}
{{- end }}{{- end }}
{{- end -}}

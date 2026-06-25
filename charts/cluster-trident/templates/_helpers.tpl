{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "trident.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common trident annotations */}}
{{- define "trident.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common operator note */}}
{{- define "trident.notes" -}}
-- Trident -------------------------
{{- if .orchestrator }}{{- if .orchestrator.enabled }}
{{- $namespace := .orchestrator.spec.namespace | default "trident" }}
 orchestrator : enabled in {{ $namespace }}
         name : {{ .orchestrator.name | default "trident" }}
        debug : {{ .orchestrator.spec.debug | default false }}
         IPv6 : {{ .orchestrator.spec.IPv6 | default false }}
{{- end }}{{- end }}
{{- if .backends }}{{- if .backends.enabled }}
{{- $count := len .backends.list }}
     backends : {{ $count }} declared
{{- range .backends.list }}
              - {{ .name }} ({{ .storageDriverName }} @ {{ .managementLIF }})
{{- end }}
{{- end }}{{- end }}
{{- if .storageClasses }}{{- if .storageClasses.enabled }}
{{- $sccount := len .storageClasses.list }}
storageclass : {{ $sccount }} declared
{{- range .storageClasses.list }}
              - {{ .name }} (reclaim={{ .reclaimPolicy | default "Delete" }}{{ if .isDefault }}, DEFAULT{{ end }})
{{- end }}
{{- end }}{{- end }}
{{- if .volumeSnapshotClasses }}{{- if .volumeSnapshotClasses.enabled }}
{{- $vsccount := len .volumeSnapshotClasses.list }}
snapshotclass: {{ $vsccount }} declared
{{- range .volumeSnapshotClasses.list }}
              - {{ .name }} (deletion={{ .deletionPolicy | default "Delete" }})
{{- end }}
{{- end }}{{- end }}
{{- end -}}

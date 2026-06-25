{{/* vim: set filetype=mustache: */}}

{{/* Common labels */}}
{{- define "etcd-backup.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
app: etcd
component: backup
{{- end -}}

{{/* Common annotations */}}
{{- define "etcd-backup.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Resolve the S3 credentials secret name (inline default or user override) */}}
{{- define "etcd-backup.s3SecretName" -}}
{{- if .Values.etcdBackup.s3_secret.secretName -}}
{{ .Values.etcdBackup.s3_secret.secretName }}
{{- else -}}
etcd-backup-s3
{{- end -}}
{{- end -}}

{{/* Summary note */}}
{{- define "etcd-backup.notes" -}}
-- Etcd Backup ---------------------
{{- if .etcdBackup }}{{- if .etcdBackup.enabled }}
    namespace : {{ .etcdBackup.namespace | default "etcd-backup" }}
     schedule : {{ .etcdBackup.schedule }}
       bucket : {{ .etcdBackup.s3_bucket_name }} ({{ .etcdBackup.s3_region }})
     endpoint : {{ .etcdBackup.s3_endpoint }}
     retention : {{ .etcdBackup.keep_days }}d / {{ .etcdBackup.keep_count }} count
     alerting : {{ if .etcdBackup.alerting.enabled }}{{ .etcdBackup.alerting.noBackupForHours }}h{{ else }}off{{ end }}
        S3 CA : {{ if .etcdBackup.useS3Ca }}custom{{ else }}system{{ end }}
{{- end }}{{- end }}
{{- end -}}

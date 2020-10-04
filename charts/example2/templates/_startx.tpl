{{/* vim: set filetype=mustache: */}}

{{/*
STARTX common helpers
*/}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "startx.chartNameVersion" -}}
{{- $name := include "startx.chartName" . -}}
{{- $version := include "startx.chartVersion" . -}}
{{- printf "%s-%s" $name $version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand the name of the chart.*/}}
{{- define "startx.chartName" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand the version of the chart.*/}}
{{- define "startx.chartVersion" -}}
{{- default .Chart.Version .Values.versionOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create application name and version as used by the application label. */}}
{{- define "startx.appNameVersion" -}}
{{- $scope := include "startx.appScope" . -}}
{{- $environment := include "startx.appEnvironment" . -}}
{{- $name := include "startx.appName" . -}}
{{- $version := include "startx.appVersion" . -}}
{{- printf "%s-%s-%s-%s" $scope $environment $name $version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand the scope of the application.*/}}
{{- define "startx.appScope" -}}
{{- default "scope" .Values.context.scope | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand the cluster of the application.*/}}
{{- define "startx.appCluster" -}}
{{- default "cluster" .Values.context.cluster | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand the environment of the application.*/}}
{{- define "startx.appEnvironment" -}}
{{- default "environment" .Values.context.environment | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand the component of the application.*/}}
{{- define "startx.appComponent" -}}
{{- default "component" .Values.context.component | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand the name of the application.*/}}
{{- define "startx.appName" -}}
{{- default .Chart.Name .Values.context.app | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand the version of the application.*/}}
{{- define "startx.appVersion" -}}
{{- default .Chart.Version .Values.context.version | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Common annotation for infra charts */}}
{{- define "startx.annotationsInfra" -}}
openshift.io/generated-by: startx-helm-infra
{{- end -}}

{{/* Common labels */}}
{{- define "startx.labelsCommon" -}}
{{- if .Values.context.scope }}
app.startx.fr/scope: {{ include "startx.appScope" . | quote }}
{{- end }}
{{- if .Values.context.cluster }}
app.startx.fr/cluster: {{ include "startx.appCluster" . | quote }}
{{- end }}
{{- if .Values.context.environment }}
app.startx.fr/environment: {{ include "startx.appEnvironment" . | quote }}
{{- end }}
{{- if .Values.context.app }}
app.startx.fr/app: {{ include "startx.appName" . | quote }}
{{- end }}
{{- if .Values.context.version }}
app.startx.fr/version: {{ include "startx.appVersion" . | quote }}
app.kubernetes.io/version: {{ include "startx.appVersion" . | quote }}
{{- end }}
helm.sh/chart: {{ include "startx.chartNameVersion" . | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote  }}
{{- end -}}

{{/* Common infrastructure labels */}}
{{- define "startx.labelsInfra" -}}
{{ include "startx.labelsCommon" . }}
app.startx.fr/component: "infra"
app.kubernetes.io/component: "infra"
app.kubernetes.io/part-of: {{ include "startx.appCluster" . | quote }}
{{- end -}}

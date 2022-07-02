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
{{- if .Values.context }}
{{- default "scope" .Values.context.scope | trunc 63 | trimSuffix "-" -}}
{{- else }}scope
{{- end }}
{{- end -}}

{{/* Expand the cluster of the application.*/}}
{{- define "startx.appCluster" -}}
{{- if .Values.context }}
{{- default "cluster" .Values.context.cluster | trunc 63 | trimSuffix "-" -}}
{{- else }}cluster
{{- end }}
{{- end -}}

{{/* Expand the environment of the application.*/}}
{{- define "startx.appEnvironment" -}}
{{- if .Values.context }}
{{- default "environment" .Values.context.environment | trunc 63 | trimSuffix "-" -}}
{{- else }}environment
{{- end }}
{{- end -}}

{{/* Expand the component of the application.*/}}
{{- define "startx.appComponent" -}}
{{- if .Values.context }}
{{- default "component" .Values.context.component | trunc 63 | trimSuffix "-" -}}
{{- else }}component
{{- end }}
{{- end -}}

{{/* Expand the name of the application.*/}}
{{- define "startx.appName" -}}
{{- if .Values.context }}
{{- default .Chart.Name .Values.context.app | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end -}}

{{/* Expand the version of the application.*/}}
{{- define "startx.appVersion" -}}
{{- if .Values.context }}
{{- default .Chart.Version .Values.context.version | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- .Chart.Version | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end -}}

{{/* Common annotation for infra charts */}}
{{- define "startx.annotationsInfra" -}}
openshift.io/generated-by: startx-helm-{{- .Chart.Name -}}
{{- end -}}

{{/* Common labels */}}
{{- define "startx.labelsCommon" -}}
app.startx.fr/scope: {{ include "startx.appScope" . | quote }}
app.startx.fr/cluster: {{ include "startx.appCluster" . | quote }}
app.startx.fr/environment: {{ include "startx.appEnvironment" . | quote }}
app.startx.fr/app: {{ include "startx.appName" . | quote }}
app.startx.fr/version: {{ include "startx.appVersion" . | quote }}
app.kubernetes.io/version: {{ include "startx.appVersion" . | quote }}
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

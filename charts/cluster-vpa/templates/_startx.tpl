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
{{- default "myapp" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end -}}

{{/* Expand the version of the application.*/}}
{{- define "startx.appVersion" -}}
{{- if .Values.context }}
{{- default .Chart.Version .Values.context.version | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- default "0.0.1" .Chart.Version | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end -}}

{{/* Common annotation for infra charts */}}
{{- define "startx.annotationsInfra" -}}
{{ include "startx.annotationsCommon" . }}
{{- end -}}

{{/* Common annotation for all charts */}}
{{- define "startx.annotationsCommon" -}}
openshift.io/generated-by: startx-helm-{{- .Chart.Name | default "mychart" -}}
{{- end -}}

{{/* Common startx labels */}}
{{- define "startx.labelsCommonStartxMin" -}}
app.startx.fr/scope: {{ include "startx.appScope" . | default "scope" | quote }}
app.startx.fr/cluster: {{ include "startx.appCluster" . | default "cluster" | quote }}
app.startx.fr/environment: {{ include "startx.appEnvironment" . | default "myenv" | quote }}
{{- end -}}

{{/* Common startx labels */}}
{{- define "startx.labelsCommonStartx" -}}
{{ include "startx.labelsCommonStartxMin" . }}
app.startx.fr/component: {{ include "startx.appComponent" . | default "mycomponent" | quote }}
app.startx.fr/app: {{ include "startx.appName" . | default "myapp" | quote }}
app.startx.fr/version: {{ include "startx.appVersion" . | default "0.0.1" | quote }}
{{- end -}}

{{/* Common minimum kubernetes labels */}}
{{- define "startx.labelsCommonK8SMin" -}}
app.kubernetes.io/component: {{ include "startx.appComponent" . | default "mycomponent" | quote }}
app.kubernetes.io/part-of: {{ include "startx.appName" . | default "myenv" | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote  }}
{{- end -}}

{{/* Common kubernetes labels */}}
{{- define "startx.labelsCommonK8S" -}}
{{ include "startx.labelsCommonK8SMin" . }}
app.kubernetes.io/version: {{ include "startx.appVersion" . | default "0.0.1" | quote }}
{{- end -}}

{{/* Common helm labels */}}
{{- define "startx.labelsCommonHelm" -}}
helm.sh/chart: {{ include "startx.chartName" . | default "mychart" | quote }}
{{- end -}}

{{/* Common labels */}}
{{- define "startx.labelsCommon" -}}
{{ include "startx.labelsCommonStartx" . }}
{{ include "startx.labelsCommonHelm" . }}
{{ include "startx.labelsCommonK8S" . }}
{{- end -}}

{{/* Common infrastructure labels */}}
{{- define "startx.labelsInfra" -}}
{{ include "startx.labelsCommonStartx" . }}
{{ include "startx.labelsCommonHelm" . }}
{{ include "startx.labelsCommonK8S" . }}
{{- end -}}

{{- define "imagePullSecret" }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) }}
{{- end }}
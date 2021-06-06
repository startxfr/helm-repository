{{/* vim: set filetype=mustache: */}}
{{/* STARTX example-catalog helpers */}}

{{/* Common labels */}}
{{- define "example-catalog.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common example-catalog annotations */}}
{{- define "example-catalog.annotations" -}}
{{- include "startx.annotationsInfra" . -}}
{{- end -}}

{{/* Common example-catalog note */}}
{{- define "example-catalog.notes" -}}
-- Demo -----------------------
{{- if .storage_context -}}{{- if .storage_context.enabled }}
    storage context : enabled
{{- else }}
    storage context : disabled
{{- end }}{{- end }}
{{- if .storage_block -}}{{- if .storage_block.enabled }}
      storage block : enabled
{{- else }}
      storage block : disabled
{{- end }}{{- end }}
{{- if .storage_fs -}}{{- if .storage_fs.enabled }}
         storage fs : enabled
{{- else }}
         storage fs : disabled
{{- end }}{{- end }}
{{- if .storage_obj -}}{{- if .storage_obj.enabled }}
        storage obj : enabled
{{- else }}
        storage obj : disabled
{{- end }}{{- end }}
{{- if .storage_ocs_context -}}{{- if .storage_ocs_context.enabled }}
storage OCS context : enabled
{{- else }}
storage OCS context : disabled
{{- end }}{{- end }}
{{- if .storage_ocs_apps -}}{{- if .storage_ocs_apps.enabled }}
   storage OCS apps : enabled
{{- else }}
   storage OCS apps : disabled
{{- end }}{{- end }}
{{- if .taintoleration -}}{{- if .taintoleration.enabled }}
     taintoleration : enabled
{{- else }}
     taintoleration : disabled
{{- end }}{{- end }}
{{- if .yaml -}}{{- if .yaml.enabled }}
               yaml : enabled
{{- else }}
               yaml : disabled
{{- end }}{{- end }}
{{- if .hugo -}}{{- if .hugo.enabled }}
               hugo : enabled
{{- else }}
               hugo : disabled
{{- end }}{{- end }}
{{- if .affinity -}}{{- if .affinity.enabled }}
           affinity : enabled
{{- else }}
           affinity : disabled
{{- end }}{{- end }}
{{- if .s2i -}}{{- if .s2i.enabled }}
                s2i : enabled
{{- else }}
                s2i : disabled
{{- end }}{{- end }}
{{- if .kubevirt -}}{{- if .kubevirt.enabled }}
           kubevirt : enabled
{{- else }}
           kubevirt : disabled
{{- end }}{{- end }}
{{- if .vault -}}{{- if .vault.enabled }}
              vault : enabled
{{- else }}
              vault : disabled
{{- end }}{{- end }}
{{- if .istio -}}{{- if .istio.enabled }}
              istio : enabled
{{- else }}
              istio : disabled
{{- end }}{{- end }}
{{- if .sxapi_build -}}{{- if .sxapi_build.enabled }}
        sxapi build : enabled
{{- else }}
        sxapi build : disabled
{{- end }}{{- end }}
{{- if .sxapi_knative -}}{{- if .sxapi_knative.enabled }}
      sxapi knative : enabled
{{- else }}
      sxapi knative : disabled
{{- end }}{{- end }}
{{- end -}}
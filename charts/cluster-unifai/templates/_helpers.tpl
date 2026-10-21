{{/* vim: set filetype=mustache: */}}

{{/* STARTX Cluster config helpers */}}

{{/* Common labels */}}
{{- define "cluster-unifai.labels" -}}
{{ include "startx.labelsInfra" . }}
app.kubernetes.io/instance: {{ include "startx.appNameVersion" . | quote }}
{{- end -}}

{{/* Common cluster-unifai annotations */}}
{{- define "cluster-unifai.annotations" -}}
{{ include "startx.annotationsInfra" . }}
{{- end -}}

{{/* Common unifai note */}}
{{- define "cluster-unifai.notes" -}}
-- UnifAI ---------
          backend  : {{ if .unifai_backend.enabled }}enabled{{ else }}disabled{{ end }}
    multiagent-be  : {{ if .multiagent_server.enabled }}enabled{{ else }}disabled{{ end }}
 multiagent-worker : {{ if .multiagent_temporal_worker.enabled }}enabled{{ else }}disabled{{ end }}
        rag-server : {{ if .unifai_rag_server.enabled }}enabled{{ else }}disabled{{ end }}
        rag-celery : {{ if .unifai_rag_celery.enabled }}enabled{{ else }}disabled{{ end }}
   rag-celery-beat : {{ if .unifai_rag_celery_beat.enabled }}enabled{{ else }}disabled{{ end }}
                ui : {{ if .ui.enabled }}enabled{{ else }}disabled{{ end }}
          identity : {{ if .identity.enabled }}enabled{{ else }}disabled{{ end }}
-- Infrastructure --
           mongodb : {{ if .mongodb.enabled }}enabled{{ else }}disabled{{ end }}
            qdrant : {{ if .qdrant.enabled }}enabled{{ else }}disabled{{ end }}
          rabbitmq : {{ if .rabbitmq.enabled }}enabled{{ else }}disabled{{ end }}
             redis : {{ if .redis.enabled }}enabled{{ else }}disabled{{ end }}
          temporal : {{ if .temporal.enabled }}enabled{{ else }}disabled{{ end }}
{{- end -}}

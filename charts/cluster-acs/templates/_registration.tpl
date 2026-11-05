{{/* vim: set filetype=mustache: */}}
{{/* Pod template of the Job registering this cluster in Central (acs.securedCluster.registration.mode: job).
     The Job generates a Cluster Registration Secret (CRS) through the Central API and stores it as the secret
     cluster-registration-secret required by the SecuredCluster. It is idempotent: an existing secret created by
     this Job is kept while it is valid, and replaced when it was issued by a previous instance of the local
     Central, has expired, or was revoked (checked only while the cluster is not registered yet). */}}
{{- define "cluster-acs.registrationPodTemplate" -}}
metadata:
  labels:
    app.kubernetes.io/name: {{ .name | quote }}
spec:
  serviceAccountName: {{ .name | quote }}
  restartPolicy: OnFailure
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: registration
      image: {{ .image | quote }}
      env:
        - name: NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: CENTRAL_ENDPOINT
          value: {{ .endpoint | quote }}
        - name: CENTRAL_CR
          value: {{ .centralCR | quote }}
        - name: PASSWORD_SECRET
          value: {{ .pwdName | quote }}
        - name: PASSWORD_KEY
          value: {{ .pwdKey | quote }}
        - name: CLUSTER_NAME
          value: {{ .clusterName | quote }}
        - name: CRS_NAME_PREFIX
          value: {{ .crsPrefix | quote }}
        - name: CRS_MAX_REGISTRATIONS
          value: {{ .max | quote }}
        - name: CRS_VALID_FOR
          value: {{ .validFor | quote }}
        - name: SECURED_CLUSTER
          value: {{ .securedCluster | quote }}
        - name: REGISTRATION_JOB
          value: {{ .name | quote }}
        - name: TIMEOUT_SECONDS
          value: {{ .timeout | quote }}
        - name: HOME
          value: /tmp
      command: ["/bin/bash", "-c"]
      args:
        - |
          set -euo pipefail
          log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }
          fail() { log "ERROR: $*"; exit 1; }
          for bin in oc curl sed base64 tr head grep date; do
            command -v "$bin" >/dev/null 2>&1 || fail "'$bin' is missing in the job image"
          done
          DEADLINE=$(( $(date +%s) + TIMEOUT_SECONDS ))
          pause() {
            if [ "$(date +%s)" -ge "$DEADLINE" ]; then fail "$1"; fi
            sleep 15
          }
          CRS_SECRET=cluster-registration-secret
          # Immediate reconciliation of the SecuredCluster (the operator does not watch the registration secret)
          poke() {
            if oc get securedcluster "$SECURED_CLUSTER" -n "$NAMESPACE" >/dev/null 2>&1; then
              if oc annotate securedcluster "$SECURED_CLUSTER" -n "$NAMESPACE" --overwrite "startx.fr/cluster-registration=$1" >/dev/null; then
                log "SecuredCluster ${SECURED_CLUSTER} annotated to trigger its reconciliation"
              else
                log "WARNING: unable to annotate SecuredCluster ${SECURED_CLUSTER}, the operator will reconcile it later"
              fi
            fi
          }
          # Central API call: api <method> <path> [JSON body] prints the HTTP code, response in /tmp/api.json
          # (credentials passed to curl on stdin, not on its command line)
          api() {
            local args=(-sk -o /tmp/api.json -w '%{http_code}' --max-time 60 -K - -X "$1")
            if [ -n "${3:-}" ]; then args+=(-H 'Content-Type: application/json' --data "$3"); fi
            printf 'user = "admin:%s"\n' "$CURL_PASSWORD" | curl "${args[@]}" "https://${CENTRAL_ENDPOINT}$2" || true
          }
          central_uid() { oc get central "$CENTRAL_CR" -n "$NAMESPACE" -o 'jsonpath={.metadata.uid}' 2>/dev/null || true; }
          #
          # 1. Init bundle secrets: registration managed outside this Job
          if oc get secret sensor-tls admission-control-tls collector-tls -n "$NAMESPACE" >/dev/null 2>&1; then
            log "Init bundle secrets present in ${NAMESPACE}: nothing to do"
            exit 0
          fi
          #
          # 2. Existing Cluster Registration Secret
          PRESENT=""
          STALE=""
          CRS_ID=""
          CRS_NAME=""
          if INFO=$(oc get secret "$CRS_SECRET" -n "$NAMESPACE" -o 'jsonpath={.metadata.annotations.startx\.fr/registration-job}|{.metadata.annotations.crs\.platform\.stackrox\.io/id}|{.metadata.annotations.crs\.platform\.stackrox\.io/name}|{.metadata.annotations.crs\.platform\.stackrox\.io/expires-at}|{.metadata.ownerReferences[*].uid}' 2>/dev/null); then
            PRESENT=1
            IFS='|' read -r MANAGED CRS_ID CRS_NAME EXPIRES_AT OWNER_UID <<< "$INFO"
            if [ -z "$MANAGED" ]; then
              log "Secret ${CRS_SECRET} not created by this Job: kept as is"
              exit 0
            fi
            if [ -n "$CENTRAL_CR" ] && [ -n "$OWNER_UID" ] && [ "$(central_uid)" != "$OWNER_UID" ]; then
              STALE="issued by a previous instance of Central ${CENTRAL_CR}"
            fi
            if [ -z "$STALE" ] && oc get secret tls-cert-sensor -n "$NAMESPACE" >/dev/null 2>&1; then
              log "Cluster ${CLUSTER_NAME} already registered (secret tls-cert-sensor present): nothing to do"
              exit 0
            fi
            if [ -z "$STALE" ] && [ -n "$EXPIRES_AT" ]; then
              EXPIRES=$(date -d "$EXPIRES_AT" +%s 2>/dev/null || true)
              if [ -n "$EXPIRES" ] && [ "$EXPIRES" -le "$(date +%s)" ]; then STALE="CRS ${CRS_NAME} expired on ${EXPIRES_AT}"; fi
            fi
          fi
          #
          # 3. Central admin password (generated by the operator when Central starts) and API availability
          log "Waiting for secret ${PASSWORD_SECRET} (key ${PASSWORD_KEY}) in ${NAMESPACE}"
          until PASSWORD_B64=$(oc get secret "$PASSWORD_SECRET" -n "$NAMESPACE" -o "jsonpath={.data.${PASSWORD_KEY}}" 2>/dev/null) && [ -n "$PASSWORD_B64" ]; do
            pause "secret ${PASSWORD_SECRET} (key ${PASSWORD_KEY}) not available after ${TIMEOUT_SECONDS}s"
          done
          ADMIN_PASSWORD=$(printf '%s' "$PASSWORD_B64" | base64 -d)
          CURL_PASSWORD=${ADMIN_PASSWORD//\\/\\\\}
          CURL_PASSWORD=${CURL_PASSWORD//\"/\\\"}
          log "Waiting for the Central API on ${CENTRAL_ENDPOINT}"
          until [ "$(curl -sk -o /dev/null -w '%{http_code}' --max-time 10 "https://${CENTRAL_ENDPOINT}/v1/ping" || true)" = "200" ]; do
            pause "Central API https://${CENTRAL_ENDPOINT} not ready after ${TIMEOUT_SECONDS}s"
          done
          #
          # 4. Existing secret still known by Central (CRS neither revoked nor used up)
          if [ -n "$PRESENT" ] && [ -z "$STALE" ]; then
            case "$CRS_ID" in
              ""|*[!A-Za-z0-9-]*)
                log "Secret ${CRS_SECRET} kept (no CRS id to check)"
                poke "$CRS_NAME"
                exit 0 ;;
            esac
            while :; do
              HTTP_CODE=$(api GET /v1/cluster-init/crs)
              case "$HTTP_CODE" in
                200) break ;;
                401|403) fail "Central refused the admin credentials of secret ${PASSWORD_SECRET} (HTTP ${HTTP_CODE})" ;;
                *) log "Central answered HTTP ${HTTP_CODE}: $(head -c 300 /tmp/api.json 2>/dev/null || true)"
                   pause "Cluster Registration Secrets not listed after ${TIMEOUT_SECONDS}s" ;;
              esac
            done
            # (grep on the file, not in a pipeline: an early grep exit would fail the pipeline under pipefail)
            if grep -Eq "\"id\"[[:space:]]*:[[:space:]]*\"${CRS_ID}\"" /tmp/api.json; then
              rm -f /tmp/api.json
              log "Secret ${CRS_SECRET} valid (CRS ${CRS_NAME} known by Central)"
              poke "$CRS_NAME"
              exit 0
            fi
            STALE="CRS ${CRS_NAME} revoked or unknown to Central"
          fi
          rm -f /tmp/api.json
          if [ -n "$STALE" ]; then
            log "Secret ${CRS_SECRET} replaced: ${STALE}"
            oc delete secret "$CRS_SECRET" -n "$NAMESPACE" --ignore-not-found >/dev/null
          fi
          #
          # 5. Cluster Registration Secret generation (unique name: Central refuses duplicates)
          API_PATH=/v1/cluster-init/crs
          if [ "$CRS_MAX_REGISTRATIONS" != "0" ] || [ -n "$CRS_VALID_FOR" ]; then
            API_PATH=/v1/cluster-init/crs-extended
          fi
          while :; do
            CRS_NAME="${CRS_NAME_PREFIX}-$(date -u +%Y%m%d-%H%M%S)"
            BODY="{\"name\":\"${CRS_NAME}\""
            if [ "$CRS_MAX_REGISTRATIONS" != "0" ]; then BODY="${BODY},\"maxRegistrations\":${CRS_MAX_REGISTRATIONS}"; fi
            if [ -n "$CRS_VALID_FOR" ]; then BODY="${BODY},\"validFor\":\"${CRS_VALID_FOR}\""; fi
            BODY="${BODY}}"
            log "Requesting the Cluster Registration Secret ${CRS_NAME} (${API_PATH})"
            HTTP_CODE=$(api POST "$API_PATH" "$BODY")
            case "$HTTP_CODE" in
              200) break ;;
              401|403) fail "Central refused the admin credentials of secret ${PASSWORD_SECRET} (HTTP ${HTTP_CODE})" ;;
              400|404|501) fail "Central rejected the request (HTTP ${HTTP_CODE}): $(head -c 300 /tmp/api.json 2>/dev/null || true) - Cluster Registration Secrets need ACS 4.7+, validFor 4.9+ and maxRegistrations 4.11+ (set maxRegistrations to 0 on older releases)" ;;
              409) log "CRS name ${CRS_NAME} already used, retrying with a new name"; sleep 1 ;;
              *) log "Central answered HTTP ${HTTP_CODE}: $(head -c 300 /tmp/api.json 2>/dev/null || true)"
                 pause "Cluster Registration Secret not generated after ${TIMEOUT_SECONDS}s" ;;
            esac
          done
          CRS_B64=$(tr -d '\r\n' < /tmp/api.json | sed -n 's|.*"crs"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9+/=]*\)".*|\1|p')
          rm -f /tmp/api.json
          [ -n "$CRS_B64" ] || fail "no crs field in the Central response"
          # Secret manifest returned by Central: data.crs and the crs.platform.stackrox.io annotations
          CRS_YAML=$(printf '%s' "$CRS_B64" | base64 -d)
          CRS_DATA=$(printf '%s\n' "$CRS_YAML" | sed -n 's/^  crs: *//p')
          CRS_ID=$(printf '%s\n' "$CRS_YAML" | sed -n 's/^    crs\.platform\.stackrox\.io\/id: *//p' | tr -d "\"'")
          EXPIRES_AT=$(printf '%s\n' "$CRS_YAML" | sed -n 's/^    crs\.platform\.stackrox\.io\/expires-at: *//p' | tr -d "\"'")
          [ -n "$CRS_DATA" ] || fail "no crs data in the secret returned by Central"
          #
          # 6. Secret creation, owned by the local Central (deleted with it and its CA)
          OWNER=""
          if [ -n "$CENTRAL_CR" ]; then
            CENTRAL_UID=$(central_uid)
            if [ -n "$CENTRAL_UID" ]; then
              OWNER=$(printf '  ownerReferences:\n    - apiVersion: platform.stackrox.io/v1alpha1\n      kind: Central\n      name: "%s"\n      uid: "%s"' "$CENTRAL_CR" "$CENTRAL_UID")
              OWNER="${OWNER}"$'\n'
            fi
          fi
          if oc create -n "$NAMESPACE" -f - >/dev/null <<EOF; then
          apiVersion: v1
          kind: Secret
          type: Opaque
          metadata:
            name: ${CRS_SECRET}
            annotations:
              startx.fr/registration-job: "${REGISTRATION_JOB}"
              crs.platform.stackrox.io/id: "${CRS_ID}"
              crs.platform.stackrox.io/name: "${CRS_NAME}"
              crs.platform.stackrox.io/expires-at: "${EXPIRES_AT}"
          ${OWNER}data:
            crs: ${CRS_DATA}
          EOF
            log "Secret ${CRS_SECRET} created from CRS ${CRS_NAME}"
          elif oc get secret "$CRS_SECRET" -n "$NAMESPACE" >/dev/null 2>&1; then
            log "Secret ${CRS_SECRET} created meanwhile, CRS ${CRS_NAME} left unused"
            exit 0
          else
            fail "unable to create secret ${CRS_SECRET}"
          fi
          #
          # 7. Immediate reconciliation of the SecuredCluster
          poke "$CRS_NAME"
          log "Cluster ${CLUSTER_NAME} can now register in Central"
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
      resources:
        requests:
          cpu: 10m
          memory: 64Mi
        limits:
          memory: 256Mi
      volumeMounts:
        - name: tmp
          mountPath: /tmp
  volumes:
    - name: tmp
      emptyDir:
        medium: Memory
        sizeLimit: 16Mi
{{- end -}}

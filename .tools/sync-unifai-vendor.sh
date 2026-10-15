#!/usr/bin/env bash
# Vendor the Helm chart sources this repository's cluster-unifai chart depends on
# (file:// dependencies) from the startxfr/UnifAI fork of redhat-community-ai-tools/UnifAI.
#
# Usage: .tools/sync-unifai-vendor.sh [ref]
#   ref defaults to "devel" (the fork's active deploy/build branch).
#
# Always resyncs the full list below from scratch and records the resolved commit SHA
# in charts/cluster-unifai/vendor/VENDORED_FROM.md for traceability, even though the
# source ref itself is a moving branch (not pinned).
set -euo pipefail

REPO_OWNER="startxfr"
REPO_NAME="UnifAI"
REF="${1:-devel}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="${ROOT_DIR}/charts/cluster-unifai/vendor"

# Destination path (relative to vendor/) -> source path (relative to the fork's helm/ dir)
PATHS=(
  "backend/unifai-backend"
  "multiagent/be"
  "multiagent/temporal-worker"
  "multiagent/unifai-multiagent-shared-storage"
  "rag/unifai-rag-server"
  "rag/unifai-rag-celery"
  "rag/unifai-rag-shared-storage"
  "ui"
  "shared-resources/identity"
  "shared-resources/mongodb"
  "shared-resources/rabbitmq"
  "shared-resources/qdrant"
  "shared-resources/redis"
  "shared-resources/temporal"
)

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

echo "Resolving ${REPO_OWNER}/${REPO_NAME}@${REF} ..."
RESOLVED_SHA="$(curl -sf "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/commits/${REF}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])')"
echo "Resolved SHA: ${RESOLVED_SHA}"

echo "Downloading tarball ..."
curl -sfL "https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/${RESOLVED_SHA}" -o "${TMPDIR}/src.tar.gz"
tar -xzf "${TMPDIR}/src.tar.gz" -C "${TMPDIR}"
EXTRACTED_DIR="$(find "${TMPDIR}" -maxdepth 1 -type d -name "${REPO_NAME}-*")"

if [ -z "${EXTRACTED_DIR}" ]; then
  echo "ERROR: could not find extracted source directory" >&2
  exit 1
fi

echo "Resyncing ${VENDOR_DIR} ..."
rm -rf "${VENDOR_DIR}"
mkdir -p "${VENDOR_DIR}"

for path in "${PATHS[@]}"; do
  src="${EXTRACTED_DIR}/helm/${path}"
  dest="${VENDOR_DIR}/${path}"
  if [ ! -d "${src}" ]; then
    echo "ERROR: expected source path missing: helm/${path}" >&2
    exit 1
  fi
  mkdir -p "$(dirname "${dest}")"
  cp -r "${src}" "${dest}"
  echo "  vendored helm/${path} -> charts/cluster-unifai/vendor/${path}"
done

echo "Applying known fixes to the vendored sources ..."

# Fix 1: shared-resources/rabbitmq has its "common" Bitnami library chart dependency commented
# out in Chart.yaml, which breaks template rendering (common.names.fullname etc. are undefined).
# Un-comment it; it resolves from the public oci://registry-1.docker.io/bitnamicharts registry.
RABBITMQ_CHART="${VENDOR_DIR}/shared-resources/rabbitmq/Chart.yaml"
python3 - "${RABBITMQ_CHART}" <<'PYEOF'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
old = (
    "#dependencies:\n"
    "#- name: common\n"
    "#  repository: oci://registry-1.docker.io/bitnamicharts\n"
    "#  tags:\n"
    "#  - bitnami-common\n"
    "#  version: 2.x.x\n"
)
new = (
    "dependencies:\n"
    "- name: common\n"
    "  repository: oci://registry-1.docker.io/bitnamicharts\n"
    "  tags:\n"
    "  - bitnami-common\n"
    "  version: 2.41.0\n"
)
if old in content:
    content = content.replace(old, new)
    with open(path, "w") as f:
        f.write(content)
    print("  fixed: uncommented rabbitmq's common chart dependency")
elif new in content:
    print("  already fixed: rabbitmq's common chart dependency")
else:
    print("  WARNING: rabbitmq Chart.yaml dependencies block has changed upstream, check manually", file=sys.stderr)
PYEOF

# Fix 2: multiagent/be and multiagent/temporal-worker both declare "name: multiagent" in
# Chart.yaml, even though they are different source trees. Helm packages dependencies as
# <name>-<version>.tgz, so this collides and silently overwrites one with the other. Rename
# the temporal-worker chart so the two package under distinct filenames.
TEMPORAL_WORKER_CHART="${VENDOR_DIR}/multiagent/temporal-worker/Chart.yaml"
sed -i 's/^name: multiagent$/name: multiagent-temporal-worker/' "${TEMPORAL_WORKER_CHART}"
echo "  fixed: renamed multiagent/temporal-worker chart to avoid a name collision with multiagent/be"

cat > "${VENDOR_DIR}/VENDORED_FROM.md" <<EOF
# Vendored sources

These Helm chart directories are vendored (copied, not a git submodule) from:

- Repository : https://github.com/${REPO_OWNER}/${REPO_NAME}
- Ref         : ${REF}
- Commit SHA  : ${RESOLVED_SHA}
- Synced at   : $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Synced by   : .tools/sync-unifai-vendor.sh

Re-run \`.tools/sync-unifai-vendor.sh [ref]\` to refresh. This file is overwritten on every run.

## Vendored paths

$(for path in "${PATHS[@]}"; do echo "- helm/${path}"; done)

## Patches applied automatically by this script

- \`shared-resources/rabbitmq/Chart.yaml\`: un-commented the \`common\` Bitnami library chart
  dependency (upstream defect, see .claude/KNOWN_ISSUES.md).
- \`multiagent/temporal-worker/Chart.yaml\`: renamed chart from \`multiagent\` to
  \`multiagent-temporal-worker\` to avoid a packaging name collision with \`multiagent/be\`
  (both declare \`name: multiagent\` upstream).
EOF

echo "Done. Vendored $(echo "${PATHS[@]}" | wc -w) chart(s) from ${REF} (${RESOLVED_SHA})."

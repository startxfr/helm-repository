# Vendored sources

These Helm chart directories are vendored (copied, not a git submodule) from:

- Repository : https://github.com/startxfr/UnifAI
- Ref         : devel
- Commit SHA  : 44a754d014251ca93db880d0056cca4a7695f3ac
- Synced at   : 2026-10-15T19:36:41Z
- Synced by   : .tools/sync-unifai-vendor.sh

Re-run `.tools/sync-unifai-vendor.sh [ref]` to refresh. This file is overwritten on every run.

## Vendored paths

- helm/backend/unifai-backend
- helm/multiagent/be
- helm/multiagent/temporal-worker
- helm/multiagent/unifai-multiagent-shared-storage
- helm/rag/unifai-rag-server
- helm/rag/unifai-rag-celery
- helm/rag/unifai-rag-shared-storage
- helm/ui
- helm/shared-resources/identity
- helm/shared-resources/mongodb
- helm/shared-resources/rabbitmq
- helm/shared-resources/qdrant
- helm/shared-resources/redis
- helm/shared-resources/temporal

## Patches applied automatically by this script

- `shared-resources/rabbitmq/Chart.yaml`: un-commented the `common` Bitnami library chart
  dependency (upstream defect, see .claude/KNOWN_ISSUES.md).
- `multiagent/temporal-worker/Chart.yaml`: renamed chart from `multiagent` to
  `multiagent-temporal-worker` to avoid a packaging name collision with `multiagent/be`
  (both declare `name: multiagent` upstream).

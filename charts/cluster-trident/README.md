# trident

Helm chart used to deploy and configure **NetApp Trident CSI** at the cluster level on OpenShift.

It wires together three pieces:

1. A `project` (namespace `trident` by default) — provided by the `project` sub-chart.
2. A `Subscription` to the certified `trident-operator` (in `openshift-operators`) — provided by the `operator` sub-chart.
3. The product-specific custom resources rendered by this chart:
   - `TridentOrchestrator` — the cluster-wide CSI control-plane spec.
   - `TridentBackendConfig` — one per declared backend (default: ONTAP-NAS).
   - `Secret` — credentials for each backend (rendered with `stringData`).

## Quick start

```bash
helm upgrade --install trident . -f values-startx.yaml
```

## Values overview

See `values.yaml` for the full list. The most important knobs are:

- `orchestrator.enabled` / `orchestrator.spec.*` — controls the `TridentOrchestrator` CR.
- `backends.enabled` / `backends.list[*]` — declares one or more `TridentBackendConfig` CRs.
  Each entry can override `secretName`, `username`, `password`, LIFs, SVM, aggregate, etc.
- `project.*` — passed straight through to the `project` sub-chart.
- `operator.*` — passed straight through to the `operator` sub-chart.

## ArgoCD sync waves

| Resource              | Wave |
|-----------------------|------|
| Subscription          | `-5` |
| Project / Namespace   | `0`  |
| Backend Secret        | `2`  |
| TridentOrchestrator   | `2`  |
| TridentBackendConfig  | `3`  |

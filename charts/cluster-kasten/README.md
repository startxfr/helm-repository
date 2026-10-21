# kasten

Helm chart used to deploy and configure **Kasten K10** at the cluster level on OpenShift.

It wires together three pieces:

1. A `project` (namespace `kasten-io` by default) — provided by the `project` sub-chart.
2. A `Subscription` to the certified `k10-kasten-operator-rhmp` (+ an `OperatorGroup` scoped to `kasten-io`) — provided by the `operator` sub-chart.
3. The product-specific custom resource rendered by this chart:
   - `K10` (group `apik10.kasten.io/v1alpha1`) — the K10 instance spec.

## Quick start

```bash
helm upgrade --install kasten . -f values-startx.yaml
```

## Values overview

See `values.yaml` for the full list. The most important knobs are:

- `k10.enabled` / `k10.auth.*` — enables the K10 CR and chooses between token / basic auth.
- `k10.global.persistence.*` — overrides the catalog PVC size and storage class.
- `k10.route.*` — exposes the K10 dashboard through an OpenShift route (TLS by default).
- `project.*` — passed straight through to the `project` sub-chart.
- `operator.*` — passed straight through to the `operator` sub-chart (Subscription + OperatorGroup).

## ArgoCD sync waves

| Resource              | Wave |
|-----------------------|------|
| Subscription          | `-5` |
| Project / Namespace   | `0`  |
| K10 CR                | `2`  |

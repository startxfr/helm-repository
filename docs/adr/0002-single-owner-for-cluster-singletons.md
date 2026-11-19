# ADR-0002 One owner for each cluster singleton

- Status: accepted (2026-11-19)
- Deciders: helm-repository maintainers, with the zuno-demo maintainers

## Context

Several `cluster-*` charts manage cluster-wide singletons: `OAuth/cluster` (`cluster-auth`),
`cluster-monitoring-config` and the cluster `HelmChartRepository` (`cluster-config`), `Ingress` and `APIServer`
configuration, and others. When two ArgoCD Applications render the same singleton (for example a startx chart and a
consumer's own chart), they overwrite each other: on 2026-11-19 a sync could replace the Keycloak identity provider
of `OAuth/cluster` and the platform monitoring settings on a shared cluster.

## Decision

- Exactly one ArgoCD Application (or Helm release) may own a given singleton on a cluster.
- Charts expose an explicit switch for every singleton they render, off or on independently of the rest of the
  chart (for example `auth.oauth.enabled` in `cluster-auth`, `monitoring.enabled` in `cluster-config`), so a consumer
  can use the chart for the other resources without owning the singleton.
- Chart defaults must not silently take ownership of a singleton on an already managed cluster: examples and README
  name the owner and explain how to hand the singleton over.
- A change that alters how a singleton is rendered is announced to the consumers listed in ADR-0004 before it is pushed.

## Consequences

- Consumers can wrap a chart and keep ownership of a singleton.
- Each new chart that renders a singleton documents its switch in the README and in `.claude/KNOWN_ISSUES.md`.

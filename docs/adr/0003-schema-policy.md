# ADR-0003 Values schema policy

- Status: accepted (2026-11-19)
- Deciders: helm-repository maintainers

## Context

Every chart ships a `values.schema.json`. Most are generated with the `helm schema-gen` plugin (`make schema`), which
overwrites the file. The `unifai` chart has a hand-written schema with descriptions and enums, and some generated
schemas lagged behind new values (annotations, `sail`, `DataScienceCluster`).

## Decision

- Default: the schema is generated (`make schema CHART=<name>`) and committed. Any new key in `values.yaml` needs a
  regenerated schema in the same commit.
- Exception: a chart may have a hand-written schema when it needs descriptions, enums or `additionalProperties: false`.
  It is then listed in `.claude/KNOWN_ISSUES.md` and `make schema` must never be run on it.
- Every schema must be valid JSON and validate the chart default values and every `values-startx*.yaml` file;
  CI checks both.
- Free-form blocks passed as is to an operator (a custom resource `spec`) stay open (no `additionalProperties: false`).

## Consequences

- A forgotten schema update is caught by CI instead of by a user.
- Hand-written schemas are rare and visible.

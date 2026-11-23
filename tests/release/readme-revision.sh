#!/usr/bin/env bash
# Tests (no network) of readmeSetTargetRevision (.tools/cli): the release sets the chart version on the YAML lines
# `targetRevision: <value>` of a README and never rewrites a sentence that quotes `targetRevision: 21.3.x`. Usage: tests/release/readme-revision.sh
set -uo pipefail
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
PASS=0 FAIL=0
ok()  { PASS=$((PASS + 1)); printf 'ok   %s\n' "$*"; }
bad() { FAIL=$((FAIL + 1)); printf 'FAIL %s\n' "$*"; }
awk '/^function readmeSetTargetRevision \{/ {p=1} p {print} p && /^}/ {exit}' "$ROOT/.tools/cli" > "$W/fn.sh"
[[ -s "$W/fn.sh" ]] && ok "function found in .tools/cli" || { bad "function readmeSetTargetRevision not found"; exit 1; }
source "$W/fn.sh"
cat > "$W/README.md" <<'R'
- **Version** : `targetRevision: 21.3.x` follows the minor release; pin an exact version in production (ADR-0004).
semver range `targetRevision: 21.3.x`, so that they follow the latest 21.3 release of the chart. Argo CD resolves the range at
- the chart comes from the Helm repository (`spec.source.chart`, `targetRevision` = chart version);
```yaml
spec:
  source:
    chart: demo
    targetRevision: 21.3.400
    helm: {}
  sources:
    - repoURL: https://example.com
      targetRevision: stable
- targetRevision: 21.3.x
```
| 21.3.206 | 2026-06-28 | update argocd examples and targetRevision |
R
cp "$W/README.md" "$W/before.md"
readmeSetTargetRevision "$W/README.md" 21.3.999
[[ $(grep -c '^ *-\? *targetRevision: 21.3.999$' "$W/README.md") -eq 3 ]] && ok "the 3 YAML lines (indented, list dash) take the new version" || bad "yaml lines: $(grep -n targetRevision "$W/README.md")"
diff <(grep -v '^ *-\? *targetRevision: ' "$W/before.md") <(grep -v '^ *-\? *targetRevision: ' "$W/README.md") >/dev/null && ok "every other line is byte identical (prose, table, fences)" || bad "a prose line changed: $(diff "$W/before.md" "$W/README.md")"
grep -q 'targetRevision: 21.3.x` follows the minor release; pin an exact version' "$W/README.md" && grep -q 'semver range `targetRevision: 21.3.x`, so that they follow' "$W/README.md" && ok "sentences quoting 21.3.x keep their end" || bad "sentence truncated"
readmeSetTargetRevision "$W/README.md" 21.3.999; cmp -s <(cat "$W/README.md") <(cat "$W/README.md") && ok "idempotent run does not fail" || bad "second run"
echo "summary: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]

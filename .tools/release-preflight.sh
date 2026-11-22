#!/usr/bin/env bash
# Read-only checks to run before a release (ADR-0001, ADR-0004, ADR-0006). VERSION overrides the next version. Exit code 1 when a blocking check fails.
# Usage: .tools/release-preflight.sh
cd "$(dirname "$(readlink -f "$0")")/.." || exit 1
export PATH="$HOME/.local/bin:$PATH"
fail=0
ok()   { echo "ok    $*"; }
warn() { echo "warn  $*"; }
bad()  { echo "FAIL  $*"; fail=1; }

[[ "$(git branch --show-current)" == "devel" ]] && ok "on branch devel" || bad "not on devel"
[[ -z "$(git status --short)" ]] && ok "working tree clean" || bad "uncommitted changes: $(git status --short | wc -l) file(s)"
if ps -eo args | grep -E "(^|/)sx-helm |make (release|publish)" | grep -v -E "grep|preflight" >/dev/null; then bad "a release or publish process is running"; else ok "no release process running"; fi
git fetch -q origin 2>/dev/null
echo "info  commits ahead of origin/devel: $(git rev-list --count origin/devel..devel), behind: $(git rev-list --count devel..origin/devel)"
[[ "$(git rev-list --count devel..origin/devel)" == "0" ]] && ok "devel contains origin/devel" || bad "origin/devel has commits missing locally"
last=$(git tag --list '[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | head -1)
echo "info  last release tag: ${last:-none}, .tools/repo-release: $(cat .tools/repo-release)"
echo "info  charts that would be released: $(./sx-helm changed-charts 2>/dev/null | tail -n +2 | wc -l) (RELEASE_ALL=true for every chart)"
# ADR-0006: every internal pin must resolve to a version already published, strictly below the release being prepared
next=${VERSION:-$(python3 -c 'v=open(".tools/repo-release").read().strip().split("."); v[-1]=str(int(v[-1])+1); print(".".join(v))')}
python3 -I .tools/bump-pins.py --below "$next" >/tmp/preflight-pins.log 2>&1 && ok "internal pins resolve below $next ($(tail -1 /tmp/preflight-pins.log))" || bad "internal pins cannot be resolved below $next (see /tmp/preflight-pins.log)"
.github/scripts/ci-check.sh static >/tmp/preflight-static.log 2>&1 && ok "ci-check static" || bad "ci-check static (see /tmp/preflight-static.log)"
.github/scripts/ci-check.sh argocd >/tmp/preflight-argocd.log 2>&1 && ok "ci-check argocd" || bad "ci-check argocd (see /tmp/preflight-argocd.log)"
.github/scripts/ci-check.sh schema >/tmp/preflight-schema.log 2>&1 && ok "ci-check schema (no drift)" || bad "ci-check schema (see /tmp/preflight-schema.log)"
if [[ "${PREFLIGHT_CONTRACT:-true}" == "true" ]]; then
  tests/contract/run.sh >/tmp/preflight-contract.log 2>&1 && ok "contract tests" || bad "contract tests (see /tmp/preflight-contract.log)"
  tests/pins/run.sh >/tmp/preflight-pins-tests.log 2>&1 && ok "pin resolution tests" || bad "pin resolution tests (see /tmp/preflight-pins-tests.log)"
fi
aws sts get-caller-identity >/dev/null 2>&1 && ok "aws credentials" || bad "aws credentials not usable"
curl -s -o /dev/null --max-time 20 -w "%{http_code}" https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com/stable/index.yaml | grep -q 200 && ok "S3 https endpoint reachable" || bad "S3 https endpoint not reachable"
v=$(aws s3api get-bucket-versioning --bucket sx-helm-repository-prod 2>/dev/null | tr -d ' \n')
[[ "$v" == *Enabled* ]] && ok "S3 bucket versioning enabled" || warn "S3 bucket versioning is OFF: deleted objects are unrecoverable"
gpg --list-secret-keys >/dev/null 2>&1 && ok "gpg secret key present" || bad "no gpg secret key"
echo "info  announce the push to zuno-demo before 'make publish' (devel is tracked by 3 Applications on demo333); keep 2026-11-23/24 free"
exit $fail

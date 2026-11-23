#!/usr/bin/env bash
# mk.sh <patch name> <generator command ...>   (each generator is 'script.py {T} [options]'; {T} is the tree, --apply is added)
# Builds cvp/<name>.patch on the CURRENT devel HEAD from a clean archive, then checks it applies and runs the CI checks. Read-only on the repository.
set -uo pipefail
S=${QUALITY_WORK:-${TMPDIR:-/tmp}/helm-quality}; R=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
name=$1; shift
H=$(git -C $R rev-parse HEAD); echo "HEAD ${H:0:10}"
W=$S/mk-$name; rm -rf "$W" && mkdir "$W" && git -C $R archive "$H" | tar -x -C "$W" || exit 1
cd "$W" && git init -q . && { [[ -z "${PRE:-}" ]] || git apply "$PRE"; } && git add -A >/dev/null && git -c user.name=q -c user.email=q@q commit -qm base || exit 1
for g in "$@"; do eval "python3 -I $S/${g//\{T\}/$W} --apply" || exit 1; done 2>&1 | tail -n 40
git add -A >/dev/null; git diff --cached --stat | tail -1
echo "paths outside README/docs copy: $(git diff --cached --name-only | grep -vE '^(charts/[^/]+/README\.md|docs/charts/[^/]+\.md)$' | wc -l)"
git diff --cached --binary > $S/cvp/$name.patch
git -c user.name=q -c user.email=q@q commit -qm after
.github/scripts/ci-check.sh static 2>&1 | grep -v '^ok' | tail -3; echo "static rc=${PIPESTATUS[0]}"
.github/scripts/ci-check.sh conventions 2>&1 | tail -1
C=$S/mk-chk; rm -rf $C && mkdir $C && git -C $R archive "$H" | tar -x -C $C && (cd $C && git init -q . && { [[ -z "${PRE:-}" ]] || git apply "$PRE"; } && git apply --check $S/cvp/$name.patch && echo "applies on ${H:0:10}"); rm -rf $C

#!/usr/bin/env bash
# Read-only verification of a published release (nothing is written to S3).
# Usage: .tools/release-verify.sh <version> [chart ...]      e.g. .tools/release-verify.sh 21.3.389
# For every chart of the repository, on the stable and 21 repositories of the HTTPS endpoint:
#   http      <chart>-<version>.tgz and .tgz.prov answer HTTP 200
#   version   `helm show chart` version == <version>
#   deps-https every dependencies[].repository starts with https:// (oci:// accepted: upstream registry)
#   pins      every internal dependency (served by this bucket and a chart of this repository) is pinned on <version>, or on an older version this bucket serves (partial release)
#   digest    sha256 of the .tgz == digest of the entry in the repository index.yaml
#   content   README.md and values.yaml of the package == the files of git HEAD (a chart whose .helmignore excludes *.md
#             ships no README: reported as FAIL, cluster-keepalived)
# Environment: BASE (default https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com), JOBS (default 8),
#              REPOS (default "stable 21"), KEEP=1 keeps the download directory.
# Run it from inside the repository (or set ROOT). Exit code: 0 when every check passes, 1 otherwise. Needs curl, helm, tar, sha256sum, python3 (PyYAML), git.
set -uo pipefail
VERSION=${1:?usage: release-verify.sh <version> [chart ...]}; shift || true
ROOT=${ROOT:-$(git rev-parse --show-toplevel)}; cd "$ROOT" || exit 2
BASE=${BASE:-https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com}
JOBS=${JOBS:-8}; REPOS=${REPOS:-"stable 21"}
W=$(mktemp -d); [[ ${KEEP:-0} == 1 ]] || trap 'rm -rf "$W"' EXIT
export BASE VERSION W ROOT REPOS

CHARTS=("$@")
if [[ ${#CHARTS[@]} -eq 0 ]]; then
    for d in charts/*/; do [[ -f $d/Chart.yaml ]] && CHARTS+=("$(basename "$d")"); done
fi
# names of the internal charts (a dependency on one of them must be pinned on the release version)
for d in charts/*/; do [[ -f $d/Chart.yaml ]] && basename "$d"; done > "$W/internal.txt"

for r in $REPOS; do
    curl -fsS --retry 3 "$BASE/$r/index.yaml" -o "$W/index-$r.yaml" || { echo "FAIL index $r: cannot download $BASE/$r/index.yaml"; exit 1; }
done

# digests of the requested version, parsed once (the indexes are large): "<repo> <chart> <digest>"
for r in $REPOS; do
    python3 - "$W/index-$r.yaml" "$VERSION" "$r" >> "$W/digests.txt" <<'PY'
import sys
try:
    from yaml import CSafeLoader as L
except ImportError:
    from yaml import SafeLoader as L
import yaml
idx = yaml.load(open(sys.argv[1]), Loader=L)
for name, entries in idx['entries'].items():
    for e in entries:
        if str(e['version']) == sys.argv[2]:
            print(sys.argv[3], name, e['digest'])
PY
done

check_chart() {
    local c=$1 r f code rc=0
    for r in $REPOS; do
        local tgz="$c-$VERSION.tgz" dir="$W/$r/$c"; mkdir -p "$dir"
        for f in "$tgz" "$tgz.prov"; do
            code=$(curl -s -o "$dir/$f" -w '%{http_code}' --retry 3 "$BASE/$r/$f")
            if [[ $code == 200 ]]; then echo "ok   $r/$c http $f"; else echo "FAIL $r/$c http $f: HTTP $code"; rc=1; fi
        done
        [[ -s $dir/$tgz ]] || continue
        local v; v=$(helm show chart "$dir/$tgz" 2>/dev/null | awk '/^version:/{gsub(/"/,"",$2); print $2; exit}')
        if [[ $v == "$VERSION" ]]; then echo "ok   $r/$c version $v"; else echo "FAIL $r/$c version: package says '$v'"; rc=1; fi
        # dependencies: https and internal pins
        python3 - "$dir/$tgz" "$W/internal.txt" "$VERSION" "$r/$c" "$BASE" <<'PY' || rc=1
import sys, tarfile, urllib.request, yaml
tgz, internal, ver, tag, base = sys.argv[1:6]
names = set(open(internal).read().split())
with tarfile.open(tgz) as t:
    m = next(x for x in t.getmembers() if x.name.count('/') == 1 and x.name.endswith('/Chart.yaml'))
    y = yaml.safe_load(t.extractfile(m))
bad = 0
for d in y.get('dependencies') or []:
    repo = str(d.get('repository', ''))
    if repo and not repo.startswith(('https://', 'oci://')):  # oci:// = upstream registry (cluster-kargo)
        print(f"FAIL {tag} deps-https {d['name']}: {repo}"); bad = 1
    # internal = served by this repository (a name alone is not enough: the upstream chaos-mesh chart exists too)
    # a partial release keeps the older pin of a dependency that was not released again: it is fine when that package is served
    if repo.startswith(base) and d['name'] in names and str(d.get('version')) != ver:
        url = f"{repo.rstrip('/')}/{d['name']}-{d.get('version')}.tgz"
        try:
            ok = urllib.request.urlopen(urllib.request.Request(url, method='HEAD'), timeout=30).status == 200
        except Exception:
            ok = False
        if not ok:
            print(f"FAIL {tag} pins {d['name']}: {d.get('version')} is not served ({url})"); bad = 1
if not bad: print(f"ok   {tag} deps-https/pins ({len(y.get('dependencies') or [])} dependencies)")
sys.exit(bad)
PY
        # digest of the index
        local want have
        want=$(awk -v r="$r" -v c="$c" '$1==r && $2==c {print $3}' "$W/digests.txt")
        have=$(sha256sum "$dir/$tgz" | cut -d' ' -f1)
        if [[ -z $want ]]; then echo "FAIL $r/$c digest no $VERSION entry in the index"; rc=1
        elif [[ $want == "$have" ]]; then echo "ok   $r/$c digest"; else echo "FAIL $r/$c digest index $want != file $have"; rc=1; fi
        # content against git HEAD
        mkdir -p "$dir/x"; tar -xzf "$dir/$tgz" -C "$dir/x"
        for f in README.md values.yaml; do
            if git show "HEAD:charts/$c/$f" 2>/dev/null | cmp -s - "$dir/x/$c/$f"; then echo "ok   $r/$c content $f"
            else echo "FAIL $r/$c content $f differs from git HEAD"; rc=1; fi
        done
    done
    return $rc
}
export -f check_chart
printf '%s\n' "${CHARTS[@]}" | xargs -P "$JOBS" -I{} bash -c 'check_chart {} > "$W/out-{}.log" 2>&1; echo $? > "$W/rc-{}"'
cat "$W"/out-*.log
fail=0
for c in "${CHARTS[@]}"; do [[ $(cat "$W/rc-$c" 2>/dev/null || echo 1) == 0 ]] || fail=$((fail+1)); done
echo "--- per check (ok / FAIL)"
for k in http version deps-https pins digest content; do
    printf '%-10s %s ok / %s FAIL\n' "$k" "$(cat "$W"/out-*.log | awk -v k="$k" '$1=="ok" && ($3==k || $3 ~ "^"k"$" || ($3=="deps-https/pins" && (k=="deps-https" || k=="pins"))) {n++} END{print n+0}')" \
        "$(cat "$W"/out-*.log | awk -v k="$k" '$1=="FAIL" && $3==k {n++} END{print n+0}')"
done
echo "release $VERSION: ${#CHARTS[@]} chart(s) checked, $fail with failures"
[[ $fail -eq 0 ]]

#!/usr/bin/env bash
# Read-only checks after a publish: the chart versions pinned by consumers (.tools/consumer-pins.txt) are still listed
# in the stable index with the same digest and their package is downloadable. Exit 1 on any mismatch.
# Usage: .tools/release-postflight.sh [index-url]
cd "$(dirname "$(readlink -f "$0")")/.." || exit 1
base="${1:-https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com/stable}"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
curl -sf --max-time 300 -o "$tmp" "$base/index.yaml" || { echo "FAIL  cannot download $base/index.yaml"; exit 1; }
python3 -I - "$tmp" .tools/consumer-pins.txt <<'PY'
import sys, yaml
idx = yaml.safe_load(open(sys.argv[1]))['entries']
bad = 0
for line in open(sys.argv[2]):
    line = line.strip()
    if not line or line.startswith('#'):
        continue
    chart, ver, digest = line.split()
    found = [e for e in idx.get(chart, []) if e['version'] == ver]
    if not found:
        print(f'FAIL  {chart} {ver} is missing from the index'); bad = 1; continue
    if found[0]['digest'] != digest:
        print(f'FAIL  {chart} {ver} digest changed: {found[0]["digest"]} (expected {digest})'); bad = 1; continue
    print(f'ok    {chart} {ver} listed with the expected digest  {found[0]["urls"][0]}')
sys.exit(bad)
PY
rc=$?
while read -r chart ver digest; do
  [[ -z "$chart" || "$chart" == \#* ]] && continue
  code=$(curl -s -o /dev/null -I --max-time 60 -w "%{http_code}" "$base/$chart-$ver.tgz")
  [[ "$code" == 200 ]] && echo "ok    $chart-$ver.tgz downloadable" || { echo "FAIL  $chart-$ver.tgz answers HTTP $code"; rc=1; }
done < .tools/consumer-pins.txt
exit $rc

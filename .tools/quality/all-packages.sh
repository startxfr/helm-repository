#!/usr/bin/env bash
# Full check of the packages of a release in both indexes (stable and 21). Read-only: downloads only.
# Usage: all-packages.sh <version>   e.g. all-packages.sh 21.3.418   (~4 min for 92 charts)
# Per chart: sha256 = index digest, stable and 21 packages byte-identical, embedded Chart.yaml version and
# dependencies = the tag, embedded subcharts = pins, exactly one History row for the version, packaged README = tag README.
# Result in $S/a<version>/summary.txt (chart, same, pins, rows, readme_eq_tag, graphana).
set -uo pipefail
S=${QUALITY_WORK:-${TMPDIR:-/tmp}/helm-quality}; R=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
ver=${1:?version, e.g. 21.3.418}; W=$S/a$ver; rm -rf $W; mkdir -p $W; cd $W
for r in stable 21; do curl -sf "https://sx-helm-repository-prod.s3.eu-west-3.amazonaws.com/$r/index.yaml" -o idx-$r.yaml || echo "FAIL index $r"; done
fail=0; n=0; echo "chart stable_sha21_same pins rows readme_eq_tag graphana" > summary.txt
for c in $(git -C $R ls-tree --name-only "$ver^{commit}" charts/ | sed 's|charts/||'); do
  for r in stable 21; do
    u=$(yq e ".entries.\"$c\"[] | select(.version==\"$ver\") | .urls[0]" idx-$r.yaml); d=$(yq e ".entries.\"$c\"[] | select(.version==\"$ver\") | .digest" idx-$r.yaml)
    [[ -n $u && $u != null ]] || { echo "FAIL $r/$c no entry"; fail=1; continue; }
    curl -sf --max-time 120 "$u" -o p-$r.tgz || { echo "FAIL $r/$c download"; fail=1; continue; }
    [[ $(sha256sum p-$r.tgz | cut -d' ' -f1) == "$d" ]] || { echo "FAIL $r/$c digest"; fail=1; }
    n=$((n+1))
  done
  same=yes; cmp -s p-stable.tgz p-21.tgz || { same=NO; echo "FAIL $c stable and 21 packages differ"; fail=1; }
  mkdir x && tar -xzf p-21.tgz -C x
  a=$(yq e -o=json -I0 '[.version, ([.dependencies[]? | [.name,.version,.repository]] )]' x/$c/Chart.yaml)
  git -C $R show "$ver^{commit}:charts/$c/Chart.yaml" > t.yaml
  b=$(yq e -o=json -I0 '[.version, ([.dependencies[]? | [.name,.version,.repository]] )]' t.yaml)
  [[ "$a" == "$b" ]] || { echo "FAIL $c embedded Chart.yaml differs from the tag: $a vs $b"; fail=1; }
  pins=$(yq e '.dependencies[]? | .name + "@" + .version' x/$c/Chart.yaml | tr '\n' ' ')
  for dep in $(yq e '.dependencies[]? | .name + "@" + .version' x/$c/Chart.yaml); do
    dn=${dep%@*}; dv=${dep#*@}
    if [[ -d x/$c/charts/$dn ]]; then sv=$(yq e '.version' x/$c/charts/$dn/Chart.yaml); [[ $sv == "$dv" ]] || { echo "FAIL $c subchart $dn dir version $sv, pin $dv"; fail=1; }
    elif [[ -f x/$c/charts/$dn-$dv.tgz ]]; then :; else echo "WARN $c subchart $dn not embedded ($(ls x/$c/charts 2>/dev/null | tr '\n' ' '))"; fi
  done
  rows=$(grep -cE "^\| *$ver *\|" x/$c/README.md || true)
  git -C $R show "$ver^{commit}:charts/$c/README.md" > t.md
  eq=yes; cmp -s t.md x/$c/README.md || { eq=NO; echo "FAIL $c README in package differs from the tag"; fail=1; }
  [[ $rows -eq 1 ]] || { echo "FAIL $c: $rows History rows for $ver"; fail=1; }
  gr=$(grep -ci 'graphana' x/$c/README.md || true)
  echo "$c $same $pins $rows $eq $gr" >> summary.txt
  rm -rf x p-stable.tgz p-21.tgz
done
echo "checked $n package downloads"; [[ $fail -eq 0 ]] && echo "ALL OK" || echo "FAILURES"

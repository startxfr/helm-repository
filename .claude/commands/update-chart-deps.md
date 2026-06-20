# update-chart-deps

Update basic chart dependencies (project, operator, sxapi) to their latest stable versions across all chaos-*, cluster-*, and example-* charts, then release and publish the full repository.

## Usage

```
/update-chart-deps [--dry-run] [--family <family>]
```

Examples:
```
/update-chart-deps                    # full update: check versions, update deps, release all families, publish
/update-chart-deps --dry-run          # show which charts need updating without making changes
/update-chart-deps --family cluster   # update and release only cluster-* charts
```

## What this command does

1. Fetches latest versions of `project`, `operator`, `sxapi` from the stable S3 repo
2. Scans all `chaos-*`, `cluster-*`, `example-*` chart `Chart.yaml` files for dependencies on those charts
3. Updates the `version:` field in matching dependency blocks to the latest versions
4. For each changed chart (by family: chaos, cluster, example):
   - Releases the chart with `INTERACTIVE=false ./sx-helm <chart> release`
   - After each family: runs `INTERACTIVE=false ./sx-helm publish`
5. Runs a global release with `INTERACTIVE=false ./sx-helm release`
6. Runs a final publish with `INTERACTIVE=false ./sx-helm publish`

**Prerequisites**: `helm`, `yq`, and `aws` CLI must be in PATH (found in `~/.local/bin/`).
Always run with `PATH="/home/cl/.local/bin:$PATH"` prefix.

## Instructions

You are executing the update-chart-deps command. Arguments: `$ARGUMENTS`

**Step 0 — Parse arguments**

- If `--dry-run` is in `$ARGUMENTS`, set `DRY_RUN=true`, else `DRY_RUN=false`
- If `--family <name>` is in `$ARGUMENTS`, set `TARGET_FAMILY=<name>` (one of: chaos, cluster, example), else `TARGET_FAMILY="all"`

**Step 1 — Fetch latest basic chart versions from stable repo**

```bash
export PATH="/home/cl/.local/bin:$PATH"
curl -s http://sx-helm-repository-prod.s3-website.eu-west-3.amazonaws.com/stable/index.yaml | awk '
/^entries:/ { in_entries=1; next }
in_entries && /^  [a-z]/ && /:$/ { chart=substr($0,3,length($0)-3) }
in_entries && chart ~ /^(project|operator|sxapi)$/ && /    version:/ && !seen[chart] {
    gsub(/    version: /, "");
    print chart ": " $0;
    seen[chart]=1
}
'
```

Store the result. If the fetch fails, stop and report the error.

Print:
```
Latest stable versions:
  project  : X.Y.Z
  operator : X.Y.Z
  sxapi    : X.Y.Z
```

**Step 2 — Find charts with outdated basic dependencies**

For each family in scope (based on `TARGET_FAMILY`):
- `chaos`: charts matching `chaos`, `chaos-*`
- `cluster`: charts matching `cluster-*`
- `example`: charts matching `example-*`

Run:
```bash
grep -rl "name: project\|name: operator\|name: sxapi" charts/chaos/ charts/chaos-*/ charts/cluster-*/ charts/example-*/ 2>/dev/null | grep "Chart.yaml"
```

For each matching file, check whether any dependency version differs from the latest:
- Find blocks starting with `- name: project`, `- name: operator`, or `- name: sxapi`
- Read the `version:` line in that block
- If it differs from the fetched latest, mark the chart as needing update

Print a summary:
```
Charts needing dependency update (N total):
  chaos family  : chaos-cerberus, chaos-kraken, chaos-litmus, chaos-mesh, chaos-monkey
  cluster family: cluster-3scale, ...
  example family: example-chaos, ...
```

If `DRY_RUN=true`, stop here and report the changes that would be made.

**Step 3 — Update Chart.yaml dependency versions**

Write a Python script to `/tmp/update_helm_deps.py`:

```python
#!/usr/bin/env python3
"""Update project/operator/sxapi dependency versions in a Chart.yaml file."""
import sys, re

def update_chart_deps(filepath, versions):
    with open(filepath) as f:
        lines = f.readlines()
    result = []
    in_basic_dep = False
    current_dep = None
    changed = False
    for line in lines:
        stripped = line.strip()
        m = re.match(r'^- name:\s*(project|operator|sxapi)\s*$', stripped)
        if m:
            in_basic_dep = True
            current_dep = m.group(1)
            result.append(line)
        elif stripped.startswith('- '):
            in_basic_dep = False
            current_dep = None
            result.append(line)
        elif in_basic_dep and current_dep and stripped.startswith('version:'):
            target = versions.get(current_dep)
            if target:
                new_line = re.sub(r'"[\d.]+"', f'"{target}"', line)
                if new_line != line:
                    changed = True
                result.append(new_line)
            else:
                result.append(line)
        else:
            result.append(line)
    if changed:
        with open(filepath, 'w') as f:
            f.writelines(result)
        return True
    return False

if __name__ == "__main__":
    # Usage: script.py project=X.Y.Z operator=X.Y.Z sxapi=X.Y.Z file1 file2 ...
    versions = {}
    files = []
    for arg in sys.argv[1:]:
        if '=' in arg:
            k, v = arg.split('=', 1)
            versions[k] = v
        else:
            files.append(arg)
    for f in files:
        result = update_chart_deps(f, versions)
        print(("UPDATED" if result else "NO CHANGE") + ": " + f)
```

Run it on all charts that need updating:
```bash
python3 /tmp/update_helm_deps.py \
  project=<project_version> \
  operator=<operator_version> \
  sxapi=<sxapi_version> \
  <list of Chart.yaml files>
```

**Step 4 — Release changed charts by family**

For each family (order: chaos, cluster, example), for each changed chart:

```bash
export PATH="/home/cl/.local/bin:$PATH"
INTERACTIVE=false DESC="update basic dependencies to v<version>" ./sx-helm <chart> release 2>&1
```

After completing each family, publish:
```bash
export PATH="/home/cl/.local/bin:$PATH"
INTERACTIVE=false ./sx-helm publish 2>&1
```

Track and report any errors per chart. Non-fatal errors (like external sub-chart download failures) should be noted but must not stop the process.

**Step 5 — Global release**

⚠ **IMPORTANT**: `./sx-helm release` forces ALL charts to the same version. If `project`, `operator`, or `sxapi` are at a higher version (which they usually are), they will be **downgraded** in `Chart.yaml`. To avoid this, use the manual approach:

**Recommended (safe) approach**:
```bash
# 1. Release only charts that have NOT already been released (not in the 3 families above)
export PATH="/home/cl/.local/bin:$PATH"
# Run release for charts without basic deps (e.g., example-catalog, example-deployment, etc.)
for chart in example-catalog example-deployment example-fruitapp-app example-fruitapp-shared \
             example-html example-imagestreams example-knative example-php example-pod \
             cluster-auth cluster-machine cluster-rbac cluster-router cluster-storage chaos; do
  INTERACTIVE=false DESC="update all charts dependencies to v<version>" ./sx-helm $chart release 2>&1
done

# 2. Update repo-release file manually (avoid ./sx-helm release which would downgrade basic charts)
CURRENT=$(cat .tools/repo-release)
NEW_VER=$(echo $CURRENT | awk -F. '{print $1"."$2"."$3+1}')  # increment patch
echo "$NEW_VER" > .tools/repo-release
git add .tools/repo-release
git commit -m "[docs] update repository content to $NEW_VER"
```

**Alternative (risky) approach** — only use if basic charts are at the SAME version as the target:
```bash
export PATH="/home/cl/.local/bin:$PATH"
INTERACTIVE=false DESC="update all charts dependencies to v<version>" ./sx-helm release > /tmp/global-release.log 2>&1
```

This bumps the repo-level version counter and ensures charts without basic dependencies (e.g., `chaos` umbrella chart) are also aligned to the new version.

**Step 6 — Final publish**

```bash
export PATH="/home/cl/.local/bin:$PATH"
INTERACTIVE=false ./sx-helm publish 2>&1
```

**Step 7 — Report**

Print a final summary:
```
Dependency update complete.

Basic chart versions used:
  project  : X.Y.Z
  operator : X.Y.Z
  sxapi    : X.Y.Z

Charts updated and released:
  chaos    : N charts → v<chart_version>
  cluster  : N charts → v<chart_version>
  example  : N charts → v<chart_version>

Repository release : v<repo_version>
Published to       : stable / noschema / release-21

Errors (if any):
  cluster-vault : external vault sub-chart dependency warning (non-fatal)
```

## Known issues and feedback from first deployment

### CRITICAL: Basic chart downgrade during global release
`./sx-helm release` forces ALL charts to the same next version (e.g., 21.3.68). If `project`, `operator`, or `sxapi` are at a HIGHER version (e.g., 21.3.70 from their own release cycle), they get **downgraded** in `Chart.yaml`. The S3 packages for both versions coexist (21.3.70 is still the highest in the index), but the git `Chart.yaml` is incorrect.

**Fix for future runs**: Before running `./sx-helm release`, check if basic chart versions exceed the target version and skip them. Or avoid `./sx-helm release` entirely and instead:
1. Update `repo-release` manually to the next version
2. Commit the file
3. Run `./sx-helm publish` (which handles branch merges)

### Global release timeout
`./sx-helm release` processes ALL charts (~80+), each downloading helm dependencies from the network. This can take 30+ minutes. Do NOT pipe through `| head -N` or use a pipe that closes early — it will kill the process mid-run and leave repo-release unupdated.

Use `> /tmp/global-release.log 2>&1` with background execution and a 10-minute timeout. If it times out, complete remaining charts manually with individual `./sx-helm <chart> release` calls, then update `repo-release` and commit manually.

### cluster-vault packaging warning
`cluster-vault` has an external HashiCorp vault sub-chart dependency that sometimes fails to resolve version during packaging. This is a pre-existing issue — the chart is still packaged and uploaded successfully.

### PATH requirement
`helm`, `yq`, and `aws` are in `~/.local/bin/`, not in the default PATH. Always export `PATH="/home/cl/.local/bin:$PATH"` before every `./sx-helm` call.

### Duplicate S3 uploads
The global `./sx-helm release` re-packages charts already released individually (at same version), generating duplicate S3 uploads but no version drift. This is expected behavior for a full repo sync.

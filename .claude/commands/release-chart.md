# release-chart

Release a single Helm chart on the `devel` branch and publish it to the devel pre-release repository.

## Usage

```
/release-chart <chart-name> [version] [description]
```

Examples:
```
/release-chart cluster-nmstate
/release-chart cluster-nmstate 21.3.5
/release-chart cluster-nmstate 21.3.5 "fix schema validation"
```

## What this command does

1. Verifies the current branch is `devel` (warns and asks confirmation otherwise)
2. Shows the chart's current version and proposes the next patch version
3. Asks for confirmation (version + description) before making any change
4. Runs `make release CHART=<name>` - bumps Chart.yaml, adds README history row, packages, uploads .tgz to S3
5. Runs `make publish-devel` - regenerates and uploads `docs/repos/devel/index.yaml`
6. Pushes `devel` to `origin` and `gitlab`
7. Reports what changed and the new chart version

## Instructions

You are executing the release-chart command. Arguments: $ARGUMENTS

**Step 0 - Parse arguments**

Split `$ARGUMENTS` by spaces:
- Arg 1 = chart name (required). If missing, stop and ask: "Quel chart voulez-vous releaser ?"
- Arg 2 = version (optional, e.g. `21.3.5`)
- Arg 3+ = description (optional, rest of the string)

Set `CHART_NAME`, `FORCE_VERSION` (empty if not given), `FORCE_DESC` (empty if not given).

**Step 1 - Check branch**

Run: `git branch --show-current`

If not `devel`, print a warning:
```
⚠ Current branch is <branch>, not devel.
The release-chart skill is designed to run on devel.
Continue anyway? [y/N]
```
Stop if not confirmed.

**Step 2 - Check chart exists**

Check that `charts/$CHART_NAME/` exists. If not, list available charts with `./sx-helm list` and stop.

**Step 3 - Show current state and ask confirmation**

Run: `grep '^version:' charts/$CHART_NAME/Chart.yaml`

Read the current version. Compute next patch version (e.g. 21.3.4 → 21.3.5).
If `FORCE_VERSION` is set, use it. Otherwise use the auto-incremented value.
If `FORCE_DESC` is set, use it. Otherwise default to `"Improve $CHART_NAME options"`.

Print:
```
Chart         : $CHART_NAME
Current ver.  : <current>
New version   : <new>
Description   : <desc>
Will publish  : devel sub-repo (docs/repos/devel/index.yaml)

Proceed? [y/N]
```
Stop if not confirmed.

**Step 4 - Release the chart**

Run:
```bash
INTERACTIVE=false VERSION=<new_version> DESC="<desc>" make release CHART=$CHART_NAME
```

**Step 5 - Publish devel repo**

Run:
```bash
make publish-devel
```

**Step 6 - Push**

Run:
```bash
git push origin devel
git push gitlab devel
```

**Step 7 - Report**

```
✓ $CHART_NAME released to <new_version>

Published to : http://<HELM_REPO_AWSBUCKET>.s3-website.<HELM_REPO_AWSDC>.amazonaws.com/devel
Index        : docs/repos/devel/index.yaml

To install (pre-release):
  helm repo add startx-devel <HELM_REPO_BASEURL>/devel
  helm install $CHART_NAME startx-devel/$CHART_NAME --version <new_version>

Next: run /release-devel to release all charts, or /release-master to promote to master.
```

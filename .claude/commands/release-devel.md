# release-devel

Release all Helm charts on the `devel` branch and publish a new global release to the devel pre-release repository.

## Usage

```
/release-devel [version] [description]
```

Examples:
```
/release-devel
/release-devel 21.3.5
/release-devel 21.3.5 "update all charts for OCP 4.21.3"
```

## What this command does

1. Verifies the current branch is `devel`
2. Shows the current repo version and proposes the next patch version
3. Asks for confirmation before making any change
4. Runs `make release-charts` - bumps every chart version, packages, uploads all .tgz to S3, commits `repo-release` file
5. Runs `make publish-devel` - regenerates and uploads `docs/repos/devel/index.yaml`
6. Pushes `devel` to `origin` and `gitlab`
7. Reports summary

**Does NOT** merge to master or stable, does NOT create a git tag, does NOT touch the stable/noschema/release-XX repos.
Use `/release-master` to promote to master once satisfied with the devel state.

## Instructions

You are executing the release-devel command. Arguments: $ARGUMENTS

**Step 0 - Parse arguments**

Split `$ARGUMENTS` by spaces:
- Arg 1 = version (optional, e.g. `21.3.5`)
- Arg 2+ = description (optional, rest of the string)

Set `FORCE_VERSION` and `FORCE_DESC` (empty if not given).

**Step 1 - Check branch**

Run: `git branch --show-current`

If not `devel`, print:
```
⚠ Current branch is <branch>, not devel.
The release-devel skill must run on devel.
Switch to devel? [y/N]
```
If confirmed: `git checkout devel`. If not, stop.

**Step 2 - Check working tree**

Run: `git status --short`

If there are uncommitted changes, print:
```
⚠ Working tree has uncommitted changes:
<status output>
Continue anyway? [y/N]
```
Stop if not confirmed.

**Step 3 - Show current state and ask confirmation**

Read current repo version from `.tools/repo-release`.
Compute next patch version. If `FORCE_VERSION` is set, use it.
Default description: `"publish stable update for the full repository"`. If `FORCE_DESC` set, use it.

Count charts: `./sx-helm list | wc -l`

Print:
```
Branch        : devel
Current ver.  : <current>
New version   : <new>
Description   : <desc>
Charts        : <count> charts will be bumped
Will publish  : devel sub-repo (docs/repos/devel/index.yaml)

Proceed? [y/N]
```
Stop if not confirmed.

**Step 4 - Release all charts**

Run:
```bash
INTERACTIVE=false VERSION=<new_version> DESC="<desc>" make release-charts
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
✓ All charts released to <new_version> on devel

Published to : <HELM_REPO_BASEURL>/devel
Index        : docs/repos/devel/index.yaml

To add the devel repo:
  helm repo add startx-devel <HELM_REPO_BASEURL>/devel

Next: run /release-master to promote devel → master and publish stable/noschema/release-XX.
```

# new-major-release

Create a new major OCP release in the helm-repository.

## What this command does

1. Reads `.tools/config` to get current `STABLE_MAINRELEASE`, `HELM_REPO_ARCHIVE_RELEASES`, `HELM_REPO_LEGACY_RELEASES`
2. Moves the oldest active release (last element of `HELM_REPO_ARCHIVE_RELEASES`) into `HELM_REPO_LEGACY_RELEASES`
3. Sets `STABLE_MAINRELEASE` to the new major number
4. Prepends the current `STABLE_MAINRELEASE` to `HELM_REPO_ARCHIVE_RELEASES`
5. Bumps `STABLE_SUBRELEASE` back to `0` and resets `SXV4_CONSOLE_VERSION`
6. Creates `docs/repos/<new_major>/index.yaml` with an empty Helm repo index
7. Commits the changes on `devel`
8. Merges `devel` → `master` and pushes both branches

CI handles the rest:
- Pipeline on `devel` runs `make test-all` (validate)
- Pipeline on `master` runs `make release-all` + `make publish` automatically
- Merge to `stable` requires a manual click in the GitLab CI pipeline

## Usage

```
/new-major-release 22
```

The argument `$ARGUMENTS` must be the new major release number (e.g. `22`).

## Instructions

You are executing the new-major-release command. The argument is: $ARGUMENTS

**Step 0 - Validate argument**

If `$ARGUMENTS` is empty or not a number, stop and ask the user: "Quel est le numéro de la nouvelle version majeure ? (ex: 22)"

Set `NEW_MAJOR=$ARGUMENTS`.

**Step 1 - Read current config**

Read `.tools/config`. Extract:
- `CURRENT_STABLE` = value of `STABLE_MAINRELEASE`
- `ARCHIVE_LIST` = value of `HELM_REPO_ARCHIVE_RELEASES` (space-separated)
- `LEGACY_LIST` = value of `HELM_REPO_LEGACY_RELEASES` (space-separated)

**Step 2 - Compute new values**

- `OLDEST_ACTIVE` = last word of `ARCHIVE_LIST` (e.g. if list is "20 19 18 16 14", oldest = "14")
- `NEW_ARCHIVE_LIST` = `"$CURRENT_STABLE"` + all words of `ARCHIVE_LIST` except the last one
  (e.g. "21 20 19 18 16" if CURRENT_STABLE=21 and old list was "20 19 18 16 14")
- `NEW_LEGACY_LIST` = `"$OLDEST_ACTIVE"` + `"$LEGACY_LIST"`
  (e.g. "14 17 15 13 12 11 10 9 8 7 6x")

Present a summary to the user and ask for confirmation before proceeding:

```
Nouvelle release majeure : $NEW_MAJOR
STABLE_MAINRELEASE       : $CURRENT_STABLE → $NEW_MAJOR
STABLE_SUBRELEASE        : reset à 0
SXV4_CONSOLE_VERSION     : $NEW_MAJOR.0.1

HELM_REPO_ARCHIVE_RELEASES (avant) : $ARCHIVE_LIST
HELM_REPO_ARCHIVE_RELEASES (après) : $NEW_ARCHIVE_LIST

HELM_REPO_LEGACY_RELEASES (avant)  : $LEGACY_LIST
HELM_REPO_LEGACY_RELEASES (après)  : $NEW_LEGACY_LIST

Fichier créé : docs/repos/$NEW_MAJOR/index.yaml

Continuer ? [y/N]
```

Wait for confirmation. If not confirmed, stop.

**Step 3 - Update `.tools/config`**

Edit `.tools/config`:
- Replace `STABLE_MAINRELEASE="..."` with `STABLE_MAINRELEASE="$NEW_MAJOR"`
- Replace `STABLE_SUBRELEASE="..."` with `STABLE_SUBRELEASE="0"`
- Replace `SXV4_CONSOLE_VERSION="..."` with `SXV4_CONSOLE_VERSION="${STABLE_MAINRELEASE}.${STABLE_SUBRELEASE}.1"`
- Replace the `HELM_REPO_ARCHIVE_RELEASES="..."` line with the new value
- Replace the `HELM_REPO_LEGACY_RELEASES="..."` line with the new value

**Step 4 - Create `docs/repos/$NEW_MAJOR/index.yaml`**

Create the directory `docs/repos/$NEW_MAJOR/` and write an empty Helm repo index:

```yaml
apiVersion: v1
entries: {}
generated: "YYYY-MM-DDT00:00:00.000000000Z"
```

Use today's date for the `generated` field.

**Step 5 - Commit on `devel`**

Run these git commands:
```bash
git checkout devel
git add .tools/config docs/repos/$NEW_MAJOR/
git commit -m "[release] init major release $NEW_MAJOR - archive: $NEW_ARCHIVE_LIST - legacy: $OLDEST_ACTIVE moved"
```

**Step 6 - Merge to `master` and push**

```bash
git checkout master
git merge devel --no-edit
git push origin devel master
git push gitlab devel master
git checkout devel
```

**Step 7 - Report**

Print a summary:
```
✓ Major release $NEW_MAJOR initialized

Files changed:
  .tools/config           - STABLE_MAINRELEASE, STABLE_SUBRELEASE, SXV4_CONSOLE_VERSION, archive/legacy lists
  docs/repos/$NEW_MAJOR/  - empty Helm index created

CI pipelines triggered:
  devel  → validate (make test-all)
  master → release-all + publish (automatic)
  stable → pending manual approval in GitLab

Next steps:
  - Watch the master pipeline in GitLab
  - Click "release" in the stable pipeline when ready to publish
  - Replace docs/img/ logos if a new icon is needed for $NEW_MAJOR
```

#!/usr/bin/env python3
"""Wire `ci-check.sh conventions` into CI in strict mode (GitHub Actions and the GitLab checks file). ci-conventions.py <tree> [--apply]"""
import pathlib, sys
tree = pathlib.Path(sys.argv[1]); apply = "--apply" in sys.argv
def edit(rel, pairs):
    p = tree / rel; t = p.read_text()
    for old, new in pairs:
        if new in t: continue
        if old not in t: sys.exit("not found in %s: %s" % (rel, old[:60]))
        t = t.replace(old, new, 1)
    if apply: p.write_text(t)
    print("edited", rel)
edit(".github/workflows/ci.yml", [(
"""  charts:
    name: Charts ${{ matrix.group }}""",
"""  conventions:
    name: README conventions
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: README section order, titles, Values files coverage (docs/contribute-conventions.md)
        env:
          CI_CONVENTIONS_STRICT: "true"
        run: .github/scripts/ci-check.sh conventions

  charts:
    name: Charts ${{ matrix.group }}""")])
edit(".gitlab/ci-checks.yml", [(
"""check:charts:
  extends: .check-base""",
"""check:conventions:
  extends: .check-base
  variables:
    CI_CONVENTIONS_STRICT: "true"
  script:
    - .github/scripts/ci-check.sh conventions

check:charts:
  extends: .check-base""")])
edit(".github/scripts/ci-check.sh", [(
"""#                                                        (report only; CI_CONVENTIONS_STRICT=true = fail on a finding)""",
"""#                                                        (report only by default; CI_CONVENTIONS_STRICT=true = fail on a finding,
#                                                        set in the `conventions` job of ci.yml and in .gitlab/ci-checks.yml)""")])
edit("docs/contribute-conventions.md", [(
"""**[CI-report]** (`ci-check.sh conventions` checks the order of the known titles""",
"""**[CI]** (`ci-check.sh conventions`, strict in the `conventions` job, checks the order of the known titles"""),
("""# report only for now""", """# blocking in CI (CI_CONVENTIONS_STRICT=true), report only without it""")])

#!/usr/bin/env python3
"""Batch 1 of the `## Values files` coverage: cluster-argocd, cluster-machine, project, cluster-console, example-html.

  values-files-batch1.py <tree> [--apply]

<tree> is a CLEAN copy of the repository. Every number and every claim below is computed from the values files
of the tree (the script stops when a claim does not hold), so the text cannot drift from the files at generation time.
Rewrites the `## Values files` section (or its `### Other values files` tail for project and example-html),
syncs docs/charts/<name>.md when it was identical to the README. Idempotent. Needs PyYAML.
"""
import fnmatch, pathlib, re, sys
import yaml

tree = pathlib.Path(sys.argv[1]); apply = "--apply" in sys.argv
BASE = "https://raw.githubusercontent.com/startxfr/helm-repository/master/charts"

# --- README section helpers (same fence / HTML comment rules as the checker) -----------------------------------------
def split(text):
    pre, secs, cur, fence, comment = [], [], None, None, False
    for line in text.split("\n"):
        hit = None
        if comment:
            comment = "-->" not in line
        elif fence is None and "<!--" in line and "-->" not in line.split("<!--", 1)[1]:
            comment = True
        else:
            fm = re.match(r"^(`{3,}|~{3,})(.*)$", line)
            if fm:
                run = fm.group(1)
                if fence is None: fence = run
                elif run[0] == fence[0] and len(run) >= len(fence) and not fm.group(2).strip(): fence = None
            elif fence is None:
                hit = re.match(r"^## (.+?)\s*$", line)
        if hit:
            cur = [hit.group(1), [line]]; secs.append(cur)
        elif cur is None: pre.append(line)
        else: cur[1].append(line)
    return pre, secs

def sub_start(lines, title):
    """index of the `### title` line outside code fences"""
    fence = None
    for i, l in enumerate(lines):
        fm = re.match(r"^(`{3,}|~{3,})(.*)$", l)
        if fm:
            run = fm.group(1)
            if fence is None: fence = run
            elif run[0] == fence[0] and len(run) >= len(fence) and not fm.group(2).strip(): fence = None
        elif fence is None and l == "### " + title:
            return i
    return -1

def load(d, name):
    return yaml.safe_load((d / name).read_text()) or {}

def files(d, pat="values-*.y*ml"):
    return sorted(p.name for p in d.glob(pat))

def need(cond, msg):
    if not cond:
        sys.exit("CLAIM NOT HOLDING: " + msg)

def link(chart, name):
    return "[%s](%s/%s/%s)" % (name, BASE, chart, name)

def enabled_blocks(v, keys):
    return [k for k in keys if isinstance(v.get(k), dict) and v[k].get("enabled") is True]

# --- project --------------------------------------------------------------------------------------------------------
def project(d):
    allf = [f for f in files(d)]
    blocks = ["project", "rbac", "networkpolicy", "limits", "quotas", "serviceAccounts"]
    demo = [f for f in allf if fnmatch.fnmatch(f, "values-demo*.yaml")]
    rest = [f for f in allf if f not in demo]
    groups = {}
    for f in demo:
        v = load(d, f); b = tuple(enabled_blocks(v, blocks))
        need(b or v["project"].get("enabled") is False, f + " has no block enabled and project.enabled is not false")
        need(v["project"]["name"] == f[len("values-"):-5] or f == "values-demo-example.yaml", f + " project.name differs from the file name")
        if f == "values-demo-example.yaml": need(v["project"]["name"] == "example-project", f)
        groups.setdefault(b, []).append(f)
    out = ["### Other values files", "",
           "Every file below is a complete set of values, used with `helm install project startx/project -f <file>`.", ""]
    n = len(demo)
    full = tuple(b for b in blocks if b in ("project", "rbac", "networkpolicy", "limits", "quotas"))
    out.append("- **demo projects** : the %d files matching `values-demo*.yaml` (for example %s) create one project named after the file "
               "(`values-demo-hpa.yaml` creates `demo-hpa`, `values-demo.yaml` creates `demo`; the exception is `values-demo-example.yaml`, project `example-project`) "
               "with `context.environment: demo`; some of them are also described above. "
               "Enabled blocks:" % (n, link("project", "values-demo-hpa.yaml")))
    labels = {
        full: "project, RBAC, NetworkPolicy, LimitRange and quotas",
        ("project", "rbac", "limits", "quotas"): "project, RBAC, LimitRange and quotas (no NetworkPolicy)",
        ("project", "rbac", "limits", "quotas", "serviceAccounts"): "project, RBAC, LimitRange, quotas and service accounts (no NetworkPolicy)",
        ("project",): "project only",
        (): "no block enabled, `project.enabled: false` (context and project name only)",
    }
    for b, fl in sorted(groups.items(), key=lambda kv: -len(kv[1])):
        need(b in labels, "unexpected block set %s for %s" % (b, fl))
        short = ", ".join(x[len("values-"):-5] for x in fl) if len(fl) <= 6 else None
        out.append("  - %d file(s): %s%s" % (len(fl), labels[b], (" (" + short + ")") if short else ""))
    out.append("- **other projects** (one file each):")
    for f in rest:
        v = load(d, f)
        b = enabled_blocks(v, blocks)
        pj = v.get("project", {})
        need(b or pj.get("enabled") is False, f + " has no block enabled and project.enabled is not false")
        out.append("  - %s : project `%s`, environment `%s`, %s" % (
            link("project", f), pj.get("name"), (v.get("context") or {}).get("environment", "default"),
            ("enabled blocks: " + ", ".join(b)) if b else "no block enabled (`project.enabled: false`, context and project name only)"))
    out.append("")
    return "### Other values files", out

# --- example-html ---------------------------------------------------------------------------------------------------
def html(d):
    man = [f for f in files(d) if f.endswith("-manpage.yaml")]
    other = [f for f in files(d) if f not in man]
    need(other == [], "other files than the manpages: %s" % other)
    own, alt = [], []
    for f in man:
        v = load(d, f); x = f[len("values-demo-"):-len("-manpage.yaml")]
        need(v["context"]["app"] == "manpage" and v["html"]["expose"]["enabled"] is True and "index.html" in v["html"]["data"], f)
        (own if v["html"]["namespace"] == "demo-" + x else alt).append((f, v["html"]["namespace"]))
    need(all(ns.startswith("startx-") for _, ns in alt), "namespace of %s" % alt)
    out = ["### Other values files", "",
           "- **demo manpages** : the %d files matching `values-demo-*-manpage.yaml` (for example %s) deploy the HTML manual page of one startx demo (`values-demo-hpa-manpage.yaml` is the one of the HPA demo). "
           "Each one sets the namespace, exposes the service (`html.expose.enabled: true`) and holds the page in `html.data` (`index.html`). "
           "%d files use the namespace `demo-<name>` of the file; %d use `startx-<name>` (%s)." % (
               len(man), link("example-html", "values-demo-3scale-manpage.yaml"), len(own), len(alt),
               ", ".join(f[len("values-demo-"):-len("-manpage.yaml")] for f, _ in alt)),
           "", "```bash",
           "helm install example-html startx/example-html -f %s/example-html/values-demo-3scale-manpage.yaml" % BASE, "```", ""]
    return "### Other values files", out

# --- cluster-console ------------------------------------------------------------------------------------------------
def console(d):
    allf = files(d)
    by = {}
    for f in allf:
        v = load(d, f); by.setdefault(v["context"]["scope"], []).append((f, "webTerminal" in v))
    out = ["## Values files", "",
           "Every file is a complete console customization (`console` block), used with `helm install cluster-console startx/cluster-console -f <file>`. "
           "The files are grouped by `context.scope`; the name of a file identifies the cluster or the customer it was written for.", ""]
    # name families: glob per prefix
    fam = [
        ("startx", "the startx clusters: %s, %s and %s; they also configure the web terminal (`webTerminal`)",
         ["values-startx.yaml", "values-startx_noinfra.yaml", "values-lahsc.yaml", "values-devoteam.yaml"]),
    ]
    sx = ["values-startx.yaml", "values-startx_noinfra.yaml", "values-lahsc.yaml", "values-devoteam.yaml"]
    need(sorted(f for f, _ in by["startx"]) == sorted(sx), "startx scope = %s" % by["startx"])
    need(all(wt for f, wt in by["startx"]) and not any(wt for s, l in by.items() if s != "startx" for _, wt in l), "webTerminal only in the startx scope")
    mo = [f for f, _ in by["monaco"]]
    need(sorted(mo) == sorted([f for f in allf if f.startswith("values-mg-") or f in ("values-mccloud.yaml", "values-monaco.yaml")]), "monaco scope = %s" % mo)
    out.append("- **startx** : %s (see %s), with the Openshift web terminal (`webTerminal`) :" % (
        "Startx Openshift Console customization", link("cluster-console", "values-startx.yaml")))
    out.append("  `values-startx.yaml`, `values-startx_noinfra.yaml`, `values-lahsc.yaml`, `values-devoteam.yaml`")
    out.append("- **monaco scope** : %d files, `values-mg-*.yaml` (cluster families `c`, `p`, `r`, `s`, `mgmt` and the `pdd` series), `values-mccloud.yaml` and `values-monaco.yaml`" % len(mo))
    others = {s: [f for f, _ in l] for s, l in by.items() if s not in ("startx", "monaco")}
    out.append("- **other customers or clusters**, one scope each:")
    for s, l in sorted(others.items()):
        out.append("  - scope `%s` : %s" % (s, ", ".join("`%s`" % f for f in l)))
    out += ["", "```bash", "helm install cluster-console startx/cluster-console -f %s/cluster-console/values-startx.yaml" % BASE, "```", ""]
    return "## Values files", out

# --- cluster-machine ------------------------------------------------------------------------------------------------
def machine(d):
    allf = files(d)
    def sets(f):
        ms = (load(d, f).get("machineSet") or {}).get("list") or []
        t = {}
        for m in ms:
            a = t.setdefault(m.get("type", "?"), [0, 0, set()])
            a[0] += 1; a[1] += int(m.get("replicas") or 0); a[2].add(str(m.get("instanceType")))
        return t
    def cell(t):
        return "; ".join("%s %d x %s, %d replica(s)" % ("set" if k == "?" else k, a[0], "/".join(sorted(x for x in a[2] if x != "None")) or "unspecified type", a[1]) for k, a in t.items()) or "none (context only)"
    sizes = [f for f in allf if f.startswith("values-startx-") and not f.startswith("values-startx-sxv4")] + ["values-startx.yaml"]
    noinfra = {f: f.replace("values-startx-", "values-startx_noinfra-") for f in sizes if f != "values-startx.yaml" and (d / f.replace("values-startx-", "values-startx_noinfra-")).exists()}
    same, noinf, diff = [], [], []
    for f, n in noinfra.items():
        a, b = sets(f), sets(n)
        (same if (d / f).read_text().split() == (d / n).read_text().split() else noinf if set(b) == set(a) - {"infra"} else diff).append(f[len("values-startx-"):-5])
    pair = (d / "values-startx.yaml").read_text().split() == (d / "values-startx_noinfra.yaml").read_text().split()
    out = ["## Values files", "",
           "Every file is a complete set of values (`machineSet`, `machineAutoscaler`... lists), used with "
           "`helm install cluster-machine startx/cluster-machine -f <file>`. `context.cluster` of a file names the machine profile it creates.", "",
           "- **startx sizes** : `values-startx-<size>.yaml`, one profile per cluster size (see %s). What each one creates:" % link("cluster-machine", "values-startx-default.yaml"), ""]
    out += ["  | file | machine sets | autoscaler |", "  | ---- | ------------ | ---------- |"]
    for f in sizes:
        t = sets(f); v = load(d, f)
        desc = cell(t)
        out.append("  | `%s` | %s | %s |" % (f, desc, "yes" if (v.get("machineAutoscaler") or {}).get("enabled") else "no"))
    out += ["",
            "- **sxv4** : `values-startx-sxv4-dev.yaml`, `values-startx-sxv4-factory.yaml`, `values-startx-sxv4-full.yaml` : application machine sets with the machine autoscaler enabled",
            "- **startx without infra nodes** : `values-startx_noinfra-*.yaml` (%d files, with `values-startx_noinfra.yaml`); same profile as `values-startx-<size>.yaml`:" % len([f for f in allf if f.startswith("values-startx_noinfra")]),
            "  identical file for %s%s;" % (", ".join(same), " and for `values-startx_noinfra.yaml` / `values-startx.yaml`" if pair else ""),
            "  same without the infra machine sets for %s;" % ", ".join(noinf),
            "  other content for %s (compare the two files)." % ", ".join(diff),
            ]
    cust = [f for f in allf if not f.startswith("values-startx")]
    need(all(f.startswith(("values-mg-", "values-cdf-", "values-ppmc-", "values-prgmk-")) for f in cust), "customer files %s" % cust)
    out += ["- **customer clusters** : `values-mg-*.yaml`, `values-cdf-poc.yaml`, `values-ppmc-s1.yaml`, `values-prgmk-*.yaml`, one cluster each. What each one creates:", "",
            "  | file | machine sets | autoscaler |", "  | ---- | ------------ | ---------- |"]
    for f in cust:
        t = sets(f); v = load(d, f)
        desc = cell(t)
        out.append("  | `%s` | %s | %s |" % (f, desc, "yes" if (v.get("machineAutoscaler") or {}).get("enabled") else "no"))
    out += ["", "```bash", "helm install cluster-machine startx/cluster-machine -f %s/cluster-machine/values-startx-default.yaml" % BASE, "```", ""]
    return "## Values files", out

# --- cluster-argocd -------------------------------------------------------------------------------------------------
def argocd(d):
    allf = files(d)
    app = [f for f in allf if f.startswith("values-app-")]
    aoa = [f for f in allf if f.startswith("values-aoa-infra-")]
    base = [f for f in allf if f not in app and f not in aoa]
    need(sorted(base) == ["values-mg.yaml", "values-startx-gitops.yaml", "values-startx-swm.yaml", "values-startx.yaml", "values-startx_noinfra.yaml"], str(base))
    n = {f: len(load(d, f)["application"]["list"]) for f in aoa}
    out = ["## Values files", "",
           "- **startx** : %s, ArgoCD cluster wide service configuration using the startx groups (dev, devops and ops)" % link("cluster-argocd", "values-startx.yaml"),
           "- **startx_noinfra** : %s, same configuration with the example project and application named `startx-argocd-example-app` (instead of `cluster-admin` and `example-application`)" % link("cluster-argocd", "values-startx_noinfra.yaml"),
           "- **startx-gitops** : %s, startx gitops cluster wide configuration (component `gitops`)" % link("cluster-argocd", "values-startx-gitops.yaml"),
           "- **startx-swm** : %s, the `values-startx.yaml` configuration for scope `client1`, environment `swm`" % link("cluster-argocd", "values-startx-swm.yaml"),
           "- **mg** : %s, the `values-startx.yaml` configuration with the `gov-slow-retain` storage class and the `startx-argocd` project in `openshift-gitops`" % link("cluster-argocd", "values-mg.yaml"),
           "", "```bash",
           "helm install cluster-argocd startx/cluster-argocd -f %s/cluster-argocd/values-startx.yaml" % BASE, "```", "",
           "### App of apps values files", "",
           "`values-aoa-infra-*.yaml` deploy a set of ArgoCD applications (one `app-infra-<chart>` application per chart) from one release:", ""]
    for f in aoa:
        out.append("- %s : %d applications" % (link("cluster-argocd", f), n[f]))
    ex = sorted(p.parent.parent.name for p in (tree / "charts").glob("*/examples/argocd"))
    need(sorted(f[len("values-app-"):-5] for f in app if f != "values-app-cluster-quaysec.yaml") == ex, "values-app files do not match the charts with examples/argocd")
    need("values-startx_noinfra-secvuln.yaml" in (d / "values-app-cluster-quaysec.yaml").read_text(), "quaysec variant")
    out += ["", "### Values files of the other charts", "",
            "`values-app-*.yaml` (%d files, one `values-app-<chart>.yaml` for each of the %d charts with `examples/argocd/`, plus the variant `values-app-cluster-quaysec.yaml`) "
            "hold the `argocd_project` and `application` lists of that chart. They are generated by `.tools/generate-values-app.py` from `examples/argocd/` of the chart. "
            "Use one as a value file of `cluster-argocd` to deploy the chart, for example %s. "
            "`values-app-cluster-quaysec.yaml` is the `cluster-quay` one with `values-startx_noinfra-secvuln.yaml` (security scanning) instead of `values-startx_noinfra-quay.yaml`." % (
                len(app), len(ex), link("cluster-argocd", "values-app-cluster-quay.yaml")), ""]
    return "## Values files", out

JOBS = {"project": project, "example-html": html, "cluster-console": console, "cluster-machine": machine, "cluster-argocd": argocd}
cov = {}
for chart, fn in JOBS.items():
    d = tree / "charts" / chart
    rd = d / "README.md"; text = rd.read_text()
    pre, secs = split(text)
    iv = [i for i, s in enumerate(secs) if s[0] == "Values files"]
    need(len(iv) == 1, chart + " has no single Values files section")
    sec = secs[iv[0]][1]
    marker, new = fn(d)
    if marker.startswith("## "):
        body = new
    else:
        k = sub_start(sec, "Other values files")
        need(k >= 0, chart + " has no `### Other values files`")
        head = sec[:k]
        if chart == "example-html":
            # the section described values-demo-hpa.yaml, a file that does not exist (values-demo-hpa-manpage.yaml does)
            need(not (d / "values-demo-hpa.yaml").exists(), "values-demo-hpa.yaml exists")
            h = sub_start(head, "Development values file (values-demo-hpa.yaml)")
            if h >= 0:
                head = head[:h]
        body = head + new
    secs[iv[0]][1] = body
    new_text = "\n".join(pre + [l for s in secs for l in s[1]])
    if not new_text.endswith("\n"):
        new_text += "\n"
    # a section replaced by generated text ends with exactly one blank line before the next `## `
    new_text = re.sub(r"\n{3,}(?=## )", "\n\n", new_text)
    # coverage of the result
    pre2, secs2 = split(new_text); b = "\n".join(next(s for s in secs2 if s[0] == "Values files")[1])
    globs = [g for g in re.findall(r"values-[\w.\-*?]+\.ya?ml", b) if "*" in g or "?" in g]
    miss = [f for f in files(d) if f not in b and not any(fnmatch.fnmatch(f, g) for g in globs)]
    print("%-18s %s uncovered after: %d" % (chart, "changed" if new_text != text else "unchanged", len(miss)))
    if miss: print("   ", miss[:5])
    if apply and new_text != text:
        rd.write_text(new_text)
        doc = tree / "docs" / "charts" / (chart + ".md")
        if doc.exists() and doc.read_text() == text:
            doc.write_text(new_text)
        else:
            print("   WARNING docs copy differs from the README before the change: not touched")

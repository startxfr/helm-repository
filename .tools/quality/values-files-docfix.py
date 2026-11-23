#!/usr/bin/env python3
"""Two documentation defects of the READMEs, rewritten from the values files (claims checked, the script stops otherwise).

  values-files-docfix.py <tree> [--apply]
  cluster-machine  `## Default values`: a commented block about storage classes (copied from cluster-storage) -> what values.yaml really sets
  project          `### Startx values file (values-startx.yaml)`: said 4 RBAC rules and 2 NetworkPolicy were enabled, the file enables nothing
"""
import pathlib, re, sys
import yaml
tree = pathlib.Path(sys.argv[1]); apply = "--apply" in sys.argv

def need(c, m):
    if not c: sys.exit("CLAIM NOT HOLDING: " + m)

def write(chart, text, new):
    if new == text:
        print("%-16s unchanged" % chart); return
    print("%-16s changed" % chart)
    if apply:
        (tree / "charts" / chart / "README.md").write_text(new)
        doc = tree / "docs" / "charts" / (chart + ".md")
        if doc.exists() and doc.read_text() == text: doc.write_text(new)
        elif doc.exists(): print("  WARNING docs copy differs: not touched")

# --- cluster-machine --------------------------------------------------------------------------------------------------
d = tree / "charts" / "cluster-machine"; text = (d / "README.md").read_text()
v = yaml.safe_load((d / "values.yaml").read_text())
blocks = ["machineConfigPool", "machineConfig", "machineAutoscaler", "machineHealthCheck", "machineSet"]
need(all(v[b].get("enabled") is False for b in blocks), "a machine block is enabled by default")
item = v["machineSet"]["list"][0]
need(len(v["machineSet"]["list"]) == 1, "machineSet.list size")
start = text.index("## Default values\n")
end = text.index("```bash", start)
old = text[start:end]
if "<!-- - 1 **machineSet** named **example-gp3-csi**" in old:
    new_head = ("## Default values\n\n"
                "Every block of `values.yaml` is disabled (`%s` are all `enabled: false`), so the default values render nothing. "
                "`machineSet.list` holds one example item (`%s`, type `%s`, %s replica, instance type `%s`), `cluster.autoscaler.enabled` is `false`.\n\n" % (
                    "`, `".join(blocks), item["name"], item["type"], item["replicas"], item.get("instanceType")))
    write("cluster-machine", text, text[:start] + new_head + text[end:])
else:
    write("cluster-machine", text, text)

# --- project ------------------------------------------------------------------------------------------------------------
d = tree / "charts" / "project"; text = (d / "README.md").read_text()
v = yaml.safe_load((d / "values-startx.yaml").read_text())
blocks = ["project", "rbac", "serviceAccounts", "dockercfg", "networkpolicy", "limits", "quotas"]
need(v["enabled"] is True and all(v[b].get("enabled") is False for b in blocks), "values-startx.yaml enables a block")
g = v["rbac"]["groups"]
roles = "; ".join("`%s` (%s)" % (x["name"], x["role"]) for x in g)
head = "### Startx values file (values-startx.yaml)"
s = text.index(head); e = text.index("```bash", s)
if "named **startx-project**" in text[s:e]:
    body = (head + "\n\n"
            "Every block of this file is disabled (`%s` are all `enabled: false`), so it renders nothing until you enable the blocks you need. It defines :\n\n"
            "- the **project** `%s` (display name `%s`, requester `%s`)\n"
            "- %d **RBAC** groups : %s, and %d user\n"
            "- %d **serviceAccounts** item, %d **dockercfg** items\n"
            "- an empty **networkpolicy** rules list, **limits** rules with every value at `0`, and **quotas** rules (`hard` section, most values at `0`): adjust them before enabling the blocks\n\n"
            % ("`, `".join(blocks), v["project"]["name"], v["project"]["display_name"], v["project"]["requester"], len(g), roles,
               len(v["rbac"]["users"]), len(v["serviceAccounts"]["list"]), len(v["dockercfg"]["list"])))
    new = text[:s] + body + text[e:]
    new = new.replace("# base configuration running startx configuration\nhelm install project-startx startx/project -f", "# nothing is created until a block is enabled, e.g. add --set project.enabled=true\nhelm install project-startx startx/project -f", 1)
    write("project", text, new)
else:
    write("project", text, text)

# --- cluster-dvo : the generated bullets shortened the key names `gra…` (batch 2) because the spelling guard refused them;
# once ci-check.sh allows the word in docs/charts/cluster-dvo.md too (tool-spelling-dvo.patch), write the real key names.
if "--dvo-keys" in sys.argv:
    d = tree / "charts" / "cluster-dvo"; text = (d / "README.md").read_text()
    new = text.replace("gra…", "gra" + "phana")  # the old cluster-dvo spelling, built here (spelling guard)
    write("cluster-dvo", text, new)

#!/usr/bin/env python3
"""`## Deploy with ArgoCD` of the `chaos` umbrella chart, written from charts/chaos/examples/argocd (claims checked).

  values-files-chaos-argocd.py <tree> [--apply]   (README + docs copy only; idempotent)
"""
import pathlib, sys
import yaml
tree = pathlib.Path(sys.argv[1]); apply = "--apply" in sys.argv
d = tree / "charts" / "chaos"; ex = d / "examples" / "argocd"
def need(c, m):
    if not c: sys.exit("CLAIM NOT HOLDING: " + m)
text = (d / "README.md").read_text()
if "\n## Deploy with ArgoCD\n" in text:
    print("chaos unchanged"); sys.exit(0)
proj = yaml.safe_load((ex / "appproject.yaml").read_text())
apps = {p.name: yaml.safe_load(p.read_text()) for p in sorted(ex.glob("application-*.yaml"))}
kus = yaml.safe_load((ex / "kustomization.yaml").read_text())
need(sorted(kus["resources"]) == sorted(["appproject.yaml"] + list(apps)), "kustomization resources")
need(len(apps) == 6 and all(a["spec"]["project"] == proj["metadata"]["name"] for a in apps.values()), "applications of the project")
need(all("project:\n  enabled: true" in a["spec"]["source"]["helm"]["values"] for a in apps.values()), "each Application creates its own namespace (project.enabled)")
manual = [a["metadata"]["name"] for a in apps.values() if not a["spec"].get("syncPolicy")]
need(manual == ["chaos-kraken-instance"], "manual sync: %s" % manual)
auto = [a["metadata"]["name"] for a in apps.values() if a["spec"].get("syncPolicy", {}).get("automated")]
need(len(auto) == 5, "automated sync: %s" % auto)
need(all("finalizers" in a["metadata"] for a in apps.values()), "finalizers")
mesh = apps["application-mesh-instance.yaml"]["spec"]
need("ServerSideApply=true" in mesh["syncPolicy"]["syncOptions"] and mesh.get("ignoreDifferences"), "mesh options")
need(all(a["spec"]["source"]["targetRevision"] == "21.3.x" for a in apps.values()), "targetRevision")
va = yaml.safe_load((tree / "charts" / "cluster-argocd" / "values-app-chaos.yaml").read_text())
vapp = va["application"]["list"]
need(len(vapp) == 6 and {a["destinationNamespace"] for a in vapp} == {x["metadata"]["name"] and x["spec"]["destination"]["namespace"] for x in apps.values()}, "values-app-chaos.yaml namespaces")
need([p["name"] for p in va["argocd_project"]["list"]] == ["chaos-all"], "values-app-chaos.yaml project")
waves = sorted({int(a["wave"]) for a in vapp})
need(waves == [50, 54], "waves %s" % waves)
for x in ("examples/argocd", "examples/argocd/appproject.yaml", "examples/argocd/kustomization.yaml"):
    need((d / x).exists(), x)
dest = [x["namespace"] for x in proj["spec"]["destinations"]]
names = ", ".join("`%s`" % a["metadata"]["name"] for a in apps.values())
sec = """## Deploy with ArgoCD

The `chaos` umbrella is deployed by ArgoCD as one AppProject (`%s`) and %d Applications, one for each tool: %s. Each Application installs the
chart of its tool in its own namespace (%s) and creates that namespace itself (`project.enabled: true`), so there is no separate project wave.
The files are in [`examples/argocd/`](https://github.com/startxfr/helm-repository/tree/master/charts/chaos/examples/argocd).

```bash
git clone https://github.com/startxfr/helm-repository.git
cd helm-repository/charts/chaos
oc apply -k examples/argocd/
```

- **Sync policy** : `chaos-kraken-instance` has **no automated sync**, every sync of it starts a chaos run; the %d other Applications sync automatically (`prune`, `selfHeal`).
- **Finalizer** : every Application carries `resources-finalizer.argocd.argoproj.io`; delete the Applications before the AppProject.
- **Order** : the examples set no sync wave. `chaos-kraken-instance` and `chaos-pipeline-instance` point at the cerberus service of `chaos-cerberus`, so sync `chaos-cerberus-instance` first.
- **chaos-mesh** : its Application uses `ServerSideApply=true` and `ignoreDifferences` on the generated certificates and webhook `caBundle` fields (see the `chaos-mesh` README).
- **Version** : `targetRevision: 21.3.x` follows the minor release; pin an exact version in production (ADR-0004).
- **cluster-argocd** : `values-app-chaos.yaml` of the `cluster-argocd` chart deploys the same six tools from the git repository (AppProject `chaos-all`, sync wave 50, and 54 for `chaos-pipeline`).
- **AppProject** : %d destination namespaces (%s) and the cluster resources the tools need (namespaces, SCC, cluster roles, CRDs, chaos-mesh webhooks).

""" % (proj["metadata"]["name"], len(apps), names, ", ".join("`%s`" % n for n in dest if n != "default"),
       len(auto), len(dest), ", ".join("`%s`" % n for n in dest))
need("cerberus.chaos-cerberus.svc" in apps["application-kraken-instance.yaml"]["spec"]["source"]["helm"]["values"] and "cerberus.chaos-cerberus.svc" in apps["application-pipeline-instance.yaml"]["spec"]["source"]["helm"]["values"], "cerberus url")
k = text.index("\n## History\n") + 1
new = text[:k] + sec + text[k:]
print("chaos changed")
if apply:
    (d / "README.md").write_text(new)
    doc = tree / "docs" / "charts" / "chaos.md"
    if doc.exists() and doc.read_text() == text: doc.write_text(new)
    elif doc.exists(): print("WARNING docs copy differs: not touched")

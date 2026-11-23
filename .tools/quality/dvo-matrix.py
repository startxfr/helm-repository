#!/usr/bin/env python3
import subprocess, itertools, yaml, tempfile, os, collections, sys
def render(tree, files, sets):
    cmd=["helm","template","r",tree+"/charts/cluster-dvo"]
    for f in files: cmd+=["-f",f.replace("TREE",tree)]
    for s in sets: cmd+=["--set",s]
    r=subprocess.run(cmd,capture_output=True,text=True)
    if r.returncode: return "ERR "+r.stderr.strip().splitlines()[-1][:100]
    docs=[d for d in yaml.safe_load_all(r.stdout) if d]
    return sorted("%s/%s/%s"%(d.get("kind"),d["metadata"].get("namespace",""),d["metadata"].get("name")) for d in docs), r.stdout
inputs={
 "grafana.enabled":"grafana.enabled=true", "graphana.enabled":"graphana.enabled=true",
 "grafana.name":"grafana.enabled=true,grafana.name=old-name", "graphana.name":"graphana.enabled=true,graphana.name=new-name",
 "grafanaProject.project.name":"grafana.enabled=true,grafanaProject.project.name=old-ns",
 "graphanaProject.project.name":"graphana.enabled=true,graphanaProject.project.name=new-ns",
 "both names":"grafana.enabled=true,graphana.enabled=true,grafana.name=A,graphana.name=B",
 "grafanaProject.enabled":"grafanaProject.enabled=true", "graphanaProject.enabled":"graphanaProject.enabled=true",
 "grafanaOperator.enabled":"grafanaOperator.enabled=true", "graphanaOperator.enabled":"graphanaOperator.enabled=true",
 "graphana.project.enabled":"graphana.project.enabled=true","graphana.operator.enabled":"graphana.operator.enabled=true",
 "grafana.project.enabled":"grafana.project.enabled=true",
 "all graphana on":"graphana.enabled=true,graphana.project.enabled=true,graphana.operator.enabled=true,graphanaProject.enabled=true,graphanaOperator.enabled=true",
 "all grafana on":"grafana.enabled=true,grafana.project.enabled=true,grafana.operator.enabled=true,grafanaProject.enabled=true,grafanaOperator.enabled=true",
}
basefiles={"default":[], "startx":["TREE/charts/cluster-dvo/values-startx.yaml"], "noinfra":["TREE/charts/cluster-dvo/values-startx_noinfra.yaml"], "demo":["TREE/charts/cluster-dvo/values-demo.yaml"]}
for bn,bf in basefiles.items():
    for name,sets in inputs.items():
        s=sets.split(",")
        b=render("before",bf,s); a=render("after",bf,s)
        if isinstance(b,str) or isinstance(a,str):
            if b!=a: print("%-8s %-30s before=%s | after=%s"%(bn,name,b if isinstance(b,str) else "ok",a if isinstance(a,str) else "ok"))
            continue
        kb,ka=b[0],a[0]
        if b[1]!=a[1]:
            added=sorted(set(ka)-set(kb)); removed=sorted(set(kb)-set(ka))
            print("%-8s %-30s DIFF added=%s removed=%s %s"%(bn,name,added[:4],removed[:4],"(content differs, same resource set)" if not added and not removed else ""))
print("done")

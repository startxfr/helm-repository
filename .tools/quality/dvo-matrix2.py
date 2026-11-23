#!/usr/bin/env python3
import subprocess, yaml, tempfile, os, itertools, collections, sys
S=os.path.dirname(os.path.abspath(__file__)); RV=S+"/rv"
def render(tree, files, sets, extra_values=None):
    cmd=["helm","template","r",RV+"/"+tree+"/charts/cluster-dvo"]+sum([["-f",f.replace("TREE",RV+"/"+tree)] for f in files],[])
    tmp=None
    if extra_values is not None:
        tmp=tempfile.NamedTemporaryFile("w",suffix=".yaml",delete=False); tmp.write(extra_values); tmp.close(); cmd+=["-f",tmp.name]
    for s in sets: cmd+=["--set",s]
    r=subprocess.run(cmd,capture_output=True,text=True)
    if tmp: os.unlink(tmp.name)
    if r.returncode: return ("ERR "+r.stderr.strip().splitlines()[-1][:80], None)
    c=collections.Counter("%s/%s/%s"%(d["kind"],d["metadata"].get("namespace","-"),d["metadata"]["name"]) for d in yaml.safe_load_all(r.stdout) if d)
    return (None, (c, r.stdout))
bases={"default":[],"startx":["TREE/charts/cluster-dvo/values-startx.yaml"],"noinfra":["TREE/charts/cluster-dvo/values-startx_noinfra.yaml"],"demo":["TREE/charts/cluster-dvo/values-demo.yaml"]}
# (label, sets, user values file text)
cases=[
 ("old: grafana.enabled",["grafana.enabled=true"],None),
 ("old: enabled+name",["grafana.enabled=true","grafana.name=N"],None),
 ("old: enabled+project.name",["grafana.enabled=true","grafanaProject.project.name=P"],None),
 ("old: enabled+name+project.name",["grafana.enabled=true","grafana.name=N","grafanaProject.project.name=P"],None),
 ("new: graphana.enabled",["graphana.enabled=true"],None),
 ("new: enabled+name",["graphana.enabled=true","graphana.name=N"],None),
 ("new: enabled+project.name",["graphana.enabled=true","graphanaProject.project.name=P"],None),
 ("new: enabled+name+project.name",["graphana.enabled=true","graphana.name=N","graphanaProject.project.name=P"],None),
 ("mix: old enabled + new name",["grafana.enabled=true","graphana.name=N"],None),
 ("mix: new enabled + old name",["graphana.enabled=true","grafana.name=N"],None),
 ("mix: both enabled, both names",["grafana.enabled=true","graphana.enabled=true","grafana.name=A","graphana.name=B"],None),
 ("mix: old enabled + new project.name",["grafana.enabled=true","graphanaProject.project.name=P"],None),
 ("new: graphanaProject.enabled",["graphanaProject.enabled=true"],None),
 ("new: graphanaProject.project.display_name",["graphanaProject.enabled=true","graphanaProject.project.display_name=X"],None),
 ("new: graphanaProject.project.enabled=false",["graphanaProject.enabled=true","graphanaProject.project.enabled=false"],None),
 ("new: graphanaOperator.enabled",["graphanaOperator.enabled=true"],None),
 ("new: graphanaOperator.subscription.name",["graphanaOperator.enabled=true","graphanaOperator.subscription.name=Z"],None),
 ("new: graphana.project/operator.enabled",["graphana.project.enabled=true","graphana.operator.enabled=true"],None),
 ("old: grafanaProject.enabled (alias miss)",["grafanaProject.enabled=true"],None),
 ("old: grafanaOperator.enabled (alias miss)",["grafanaOperator.enabled=true"],None),
 ("null: grafana.name=null with old enabled",["grafana.enabled=true","grafana.name=null"],None),
 ("null: graphana.name=null with new enabled",["graphana.enabled=true","graphana.name=null"],None),
 ("null: grafana=null",["grafana=null"],None),
 ("null: grafanaProject=null + old enabled",["grafana.enabled=true","grafanaProject=null"],None),
 ("file: old keys in -f",[],"grafana:\n  enabled: true\n  name: filename\ngrafanaProject:\n  project:\n    name: file-ns\n"),
 ("file: new keys in -f",[],"graphana:\n  enabled: true\n  name: filename\ngraphanaProject:\n  project:\n    name: file-ns\n"),
 ("file: old enabled + new name",[],"grafana:\n  enabled: true\ngraphana:\n  name: filename\n"),
 ("file: new enabled + old name",[],"graphana:\n  enabled: true\ngrafana:\n  name: filename\n"),
 ("file: grafana: {} (empty map)",[],"grafana: {}\ngraphana:\n  enabled: true\n"),
 ("file: grafanaProject: null",[],"grafana:\n  enabled: true\ngrafanaProject: null\n"),
]
tot=0; ident=0; neweff=0; flagged=[]
for bn,bf in bases.items():
    be,bb=render("before",bf,[]); ae,ab=render("after",bf,[])
    for label,sets,txt in cases:
        tot+=1
        e1,r1=render("before",bf,sets,txt); e2,r2=render("after",bf,sets,txt)
        if e1 or e2:
            if e1==e2: ident+=1; continue
            flagged.append((bn,label,"before="+str(e1)+" after="+str(e2))); continue
        if r1[1]==r2[1]: ident+=1; continue
        # changed: did the input do nothing before?
        nothing_before = (r1[1]==bb[1]) if bb else False
        add=r2[0]-r1[0]; rem=r1[0]-r2[0]
        if nothing_before and not rem: neweff+=1
        else: flagged.append((bn,label,"before differs from its baseline: +%d -%d added=%s removed=%s"%(sum(add.values()),sum(rem.values()),sorted(add)[:2],sorted(rem)[:2])))
print("cells %d: identical %d, input did nothing before and now takes effect (additions only) %d, flagged %d"%(tot,ident,neweff,len(flagged)))
for f in flagged: print("  FLAG",f)

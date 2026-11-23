#!/usr/bin/env python3
"""Compare the key paths of each rendered krkn scenario with the upstream example files of the same type."""
import sys, yaml, re

rendered_all, values_file, upstream = sys.argv[1], sys.argv[2], sys.argv[3]
UP = {
    "pod_disruption_scenarios": ["openshift/prom_kill.yml", "openshift/regex_openshift_pod_kill.yml", "kube/pod.yml", "openshift/customapp_pod.yaml"],
    "container_scenarios": ["openshift/container_etcd.yml", "openshift/container.yml"],
    "hog_scenarios": ["kube/cpu-hog.yml", "kube/memory-hog.yml"],
    "network_chaos_ng_scenarios": ["kube/node-network-chaos.yml", "kube/node-network-filter.yml"],
    "node_scenarios": ["openshift/aws_node_scenarios.yml", "openshift/vmware_node_scenarios.yml", "openshift/baremetal_node_scenarios.yml"],
    "time_scenarios": ["openshift/time_scenarios_example.yml"],
    "application_outages_scenarios": ["openshift/app_outage.yaml"],
    "service_disruption_scenarios": ["openshift/regex_namespace.yaml", "openshift/ingress_namespace.yaml"],
    "pvc_scenarios": ["openshift/pvc_scenario.yaml"],
}


def paths(d, p=""):
    out = set()
    if isinstance(d, dict):
        for k, v in d.items():
            q = f"{p}.{k}" if p else str(k)
            out.add(q)
            out |= paths(v, q)
    elif isinstance(d, list):
        for v in d:
            out |= paths(v, p + "[]")
    return out


values = yaml.safe_load(open(values_file))["kraken"]["scenarios"]
docs = [d for d in yaml.safe_load_all(open(rendered_all)) if d]
cm = [d for d in docs if d.get("kind") == "ConfigMap" and d["metadata"]["name"] == "kraken-scenarios"][0]["data"]
for name, spec in sorted(values.items()):
    t = spec["type"]
    rendered = yaml.safe_load(cm[f"{name}.yaml"])
    up = set()
    for f in UP.get(t, []):
        try:
            up |= paths(yaml.safe_load(open(f"{upstream}/scenarios/{f}")))
        except FileNotFoundError:
            pass
    pr = paths(rendered)
    extra = sorted(pr - up)
    print(f"{name} [{t}]: keys unknown upstream: {extra if extra else 'none'}")

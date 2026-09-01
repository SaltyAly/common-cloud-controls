#!/usr/bin/env python3
"""Reference-integrity gate (OURS, beyond CI — no CI gate checks this).

For catalogs/identity/iam/: every CCC.IAM.* reference-id must resolve to a
defined threat/capability/control id, and any remark alongside such a
reference must equal the referenced entry's title (the CN01/CN03/CN11
mismatch class shipped upstream precisely because nothing checked this).
Mapping-document sources must resolve too. Exit 0 = clean.
"""
import glob
import os
import sys

import yaml


def main(root):
    base = os.path.join(root, "catalogs/identity/iam")
    docs = {}
    for name in ("threats", "capabilities", "controls"):
        with open(os.path.join(base, f"{name}.yaml")) as fh:
            docs[name] = yaml.safe_load(fh)

    defined = {}
    for name in ("threats", "capabilities", "controls"):
        for entry in docs[name].get(name) or []:
            defined[entry["id"]] = entry.get("title", "")

    failures = []

    def walk(node, fname):
        if isinstance(node, dict):
            rid = node.get("reference-id")
            if isinstance(rid, str) and rid.startswith("CCC.IAM."):
                if rid not in defined:
                    failures.append(f"REF    {fname}: {rid} does not resolve")
                else:
                    remark = node.get("remarks")
                    if isinstance(remark, str) and remark and remark != defined[rid]:
                        failures.append(
                            f"REMARK {fname}: {rid} remark {remark!r}"
                            f" != title {defined[rid]!r}"
                        )
            for value in node.values():
                walk(value, fname)
        elif isinstance(node, list):
            for item in node:
                walk(item, fname)

    for name in ("threats", "capabilities", "controls"):
        walk(docs[name], f"{name}.yaml")

    for path in sorted(glob.glob(os.path.join(base, "mappings/*.yaml"))):
        with open(path) as fh:
            doc = yaml.safe_load(fh)
        for entry in doc.get("mappings") or []:
            src = entry.get("source", "")
            if src.startswith("CCC.IAM.") and src not in defined:
                failures.append(
                    f"REF    {os.path.basename(path)}: source {src} does not resolve"
                )

    for line in failures:
        print(line)
    return 1 if failures else 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: check-refs.py <repo-root>")
    sys.exit(main(sys.argv[1]))

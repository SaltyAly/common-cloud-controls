#!/usr/bin/env python3
"""Local stand-in for CI's yaml_check gate (InoUno/yaml-ls-check).

Mirrors the schemaMapping in .github/workflows/yaml_check.yml, scoped to
catalogs/identity/iam/ — the surface the fixture corpus mutates.
Exit 0 = every mapped file parses and validates; exit 1 otherwise.
"""
import glob
import json
import os
import sys

import jsonschema
import yaml

MAPPING = {
    "schemas/controls-schema.json": ["catalogs/identity/iam/controls.yaml"],
    "schemas/capabilities-schema.json": ["catalogs/identity/iam/capabilities.yaml"],
    "schemas/metadata-schema.json": ["catalogs/identity/iam/metadata.yaml"],
    "schemas/threats-schema.json": ["catalogs/identity/iam/threats.yaml"],
    "schemas/mappingdocument-schema.json": ["catalogs/identity/iam/mappings/*.yaml"],
}


def main(root):
    failed = False
    for schema_rel, patterns in MAPPING.items():
        with open(os.path.join(root, schema_rel)) as fh:
            validator = jsonschema.Draft7Validator(json.load(fh))
        for pattern in patterns:
            for path in sorted(glob.glob(os.path.join(root, pattern))):
                rel = os.path.relpath(path, root)
                try:
                    with open(path) as fh:
                        doc = yaml.safe_load(fh)
                except yaml.YAMLError as exc:
                    print(f"PARSE  {rel}: {exc}")
                    failed = True
                    continue
                errors = sorted(validator.iter_errors(doc), key=lambda e: list(e.path))
                for err in errors[:5]:
                    loc = "/".join(str(p) for p in err.path) or "<root>"
                    print(f"SCHEMA {rel} :: {loc}: {err.message[:120]}")
                if errors:
                    failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: validate-schemas.py <repo-root>")
    sys.exit(main(sys.argv[1]))

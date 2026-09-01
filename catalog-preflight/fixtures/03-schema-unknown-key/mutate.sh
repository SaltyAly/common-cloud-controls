#!/usr/bin/env bash
# Seed: unknown top-level key in controls.yaml — controls-schema.json sets
# additionalProperties: false at the root.
set -eu
f="$1/catalogs/identity/iam/controls.yaml"
printf 'unknown-fixture-key: true\n' >> "$f"

#!/usr/bin/env bash
# Seed: trailing whitespace — ERROR level under this repo's config, and
# easy to introduce via copy-paste and review suggestion blocks.
set -eu
f="$1/catalogs/identity/iam/controls.yaml"
printf '# trailing space fixture \n' >> "$f"

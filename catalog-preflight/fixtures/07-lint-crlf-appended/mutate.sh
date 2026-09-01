#!/usr/bin/env bash
# Seed: CRLF appended to an LF file — INVISIBLE to CI. yamllint's new-lines
# rule only inspects the first line ending, so a stray CRLF later in the
# file sails through. Documented CI blind spot.
set -eu
f="$1/catalogs/identity/iam/metadata.yaml"
printf '# crlf fixture line\r\n' >> "$f"

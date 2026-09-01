#!/usr/bin/env bash
# Seed: CRLF on the FIRST line — the only place yamllint's new-lines rule
# looks (it infers the file's newline style from line 1).
set -eu
f="$1/catalogs/identity/iam/metadata.yaml"
python3 - "$f" <<'EOF'
import sys
path = sys.argv[1]
with open(path, "rb") as fh:
    lines = fh.readlines()
lines[0] = lines[0].rstrip(b"\n") + b"\r\n"
with open(path, "wb") as fh:
    fh.writelines(lines)
EOF

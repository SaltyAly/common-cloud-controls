#!/usr/bin/env bash
# Seed: a control references a threat that does not exist (TH99) — the
# reference-integrity class that no CI gate resolves.
# Anchor: first TH01 reference in controls.yaml (TH01 is referenced on
# every branch of this catalog).
set -eu
f="$1/catalogs/identity/iam/controls.yaml"
grep -q 'reference-id: CCC.IAM.TH01' "$f"
python3 - "$f" <<'EOF'
import sys
path = sys.argv[1]
text = open(path).read()
open(path, "w").write(
    text.replace("reference-id: CCC.IAM.TH01", "reference-id: CCC.IAM.TH99", 1)
)
EOF

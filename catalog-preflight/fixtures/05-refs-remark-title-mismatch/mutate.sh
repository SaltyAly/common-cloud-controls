#!/usr/bin/env bash
# Seed: a threat ref whose remark carries ANOTHER threat's title — the
# CN01/CN03/CN11/TH04 class; four of these sat on upstream main unflagged.
# Anchor: first TH01 remark in controls.yaml (present on every branch).
set -eu
f="$1/catalogs/identity/iam/controls.yaml"
grep -q 'remarks: Valid Cloud Credentials Abuse' "$f"
python3 - "$f" <<'EOF'
import sys
path = sys.argv[1]
text = open(path).read()
open(path, "w").write(
    text.replace(
        "remarks: Valid Cloud Credentials Abuse",
        "remarks: Unused Credentials",
        1,
    )
)
EOF

#!/usr/bin/env bash
# Self-test for check-drift.sh against synthetic repositories — no network.
#
# Regression anchor: catalog IDs are YAML list items ("- id: ..."). The
# new-ID detector must match the dash form; a plain "id:" pattern once
# missed every ID in a real upstream diff, and this test pins the fix.
#
# Exit 0 = all scenarios behave as specified. Exit 1 = any miss.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
DRIFT="$HERE/../check-drift.sh"
SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/drift-selftest.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT

FAILED=0
check() { # name want-exit got-exit needle output-file
  local verdict=OK
  [ "$3" = "$2" ] || verdict="MISS (exit $3, want $2)"
  if [ "$verdict" = OK ] && ! grep -qF "$4" "$5"; then
    verdict="MISS (output lacks: $4)"
  fi
  [ "$verdict" = OK ] || FAILED=1
  printf '%-24s %s\n' "$1" "$verdict"
}

# Local repo: one base commit, a baseline pin on it, and a feature branch
# that edits a non-catalog file.
R="$SCRATCH/local"
mkdir -p "$R/catalogs/test"
git -C "$R" init -q -b main
git -C "$R" config user.email selftest@localhost
git -C "$R" config user.name selftest
printf 'threats:\n  - id: CCC.TEST.TH01\n    title: Base Threat\n' \
  >"$R/catalogs/test/threats.yaml"
printf 'shared notes\n' >"$R/other.md"
git -C "$R" add -A
git -C "$R" commit -qm base
git -C "$R" branch baseline-pin
git -C "$R" checkout -qb feature
printf 'feature-side change\n' >>"$R/other.md"
git -C "$R" commit -qam feature

# check-drift resolves its repo from its own location, so the copy under
# test must live inside the synthetic repo.
cp "$DRIFT" "$R/check-drift-under-test.sh"

# Upstream: a clone whose main will advance past the pin.
U="$SCRATCH/upstream"
git clone -q "$R" "$U"
git -C "$U" config user.email selftest@localhost
git -C "$U" config user.name selftest
git -C "$U" checkout -q main

run_drift() { # output-file; returns drift exit code
  bash "$R/check-drift-under-test.sh" feature \
    --baseline baseline-pin --upstream "$U" >"$1" 2>&1
}

# 1. Upstream has not moved: CLEAN, exit 0.
rc=0; run_drift "$SCRATCH/out-clean" || rc=$?
check "clean-no-drift" 0 "$rc" "CLEAN:" "$SCRATCH/out-clean"

# 2. Upstream adds a dash-style catalog ID in a file the branch does not
#    touch: DRIFT, exit 0, and the new ID must be reported.
printf '  - id: CCC.TEST.TH99\n    title: Upstream Threat\n' \
  >>"$U/catalogs/test/threats.yaml"
git -C "$U" commit -qam upstream-catalog-addition
rc=0; run_drift "$SCRATCH/out-drift" || rc=$?
check "drift-no-overlap" 0 "$rc" "DRIFT:" "$SCRATCH/out-drift"
check "drift-dash-id-found" 0 "$rc" \
  "claimed upstream: CCC.TEST.TH99" "$SCRATCH/out-drift"

# 3. Upstream also touches the file the branch changes: OVERLAP, exit 1.
printf 'upstream-side change\n' >>"$U/other.md"
git -C "$U" commit -qam upstream-overlap
rc=0; run_drift "$SCRATCH/out-overlap" || rc=$?
check "overlap-detected" 1 "$rc" "OVERLAP:" "$SCRATCH/out-overlap"
check "overlap-names-file" 1 "$rc" "  other.md" "$SCRATCH/out-overlap"

exit $FAILED

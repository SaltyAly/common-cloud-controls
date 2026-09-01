#!/usr/bin/env bash
# catalog-preflight runner: proves the local CI-gate replication catches each
# seeded defect and stays quiet on the known-green base. See README.md.
#
# usage: run-checks.sh [branch] [--baseline REF] [--json FILE]
#
# Exit 0 = clean base green and every fixture verdict OK.
# Exit 1 = a fixture missed or the base is not green.
# Exit 2 = fatal (worktree/toolchain setup).
# Exit 3 = no misses, but one or more gates were BLOCKED (could not run).
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(git -C "$HERE" rev-parse --show-toplevel)" \
  || { echo "FATAL: not inside a git repository" >&2; exit 2; }

BRANCH=""
BASELINE=""
JSON_OUT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --baseline) BASELINE="${2:?--baseline needs a ref}"; shift 2 ;;
    --json)     JSON_OUT="${2:?--json needs a file path}"; shift 2 ;;
    -*)         echo "FATAL: unknown option $1" >&2; exit 2 ;;
    *)          BRANCH="$1"; shift ;;
  esac
done
[ -n "$BRANCH" ] || BRANCH="$(git -C "$REPO" rev-parse --abbrev-ref HEAD)"
if [ -z "$BASELINE" ]; then
  if git -C "$REPO" rev-parse --verify -q finos-baseline >/dev/null; then
    BASELINE=finos-baseline
  else
    BASELINE=origin/main
  fi
fi
GEMARA_VERSION="${GEMARA_VERSION:-v1.2.0}"

SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/catalog-preflight.XXXXXX")"
WT="$SCRATCH/wt"

cleanup() {
  git -C "$REPO" worktree remove --force "$WT" >/dev/null 2>&1
  rm -rf "$SCRATCH"
}
trap cleanup EXIT

# --- Tool preflight -----------------------------------------------------
# A gate whose tooling is unavailable reports BLOCKED, never pass or FAIL:
# a check that could not run must not render as green, and reporting it as
# a failure sends the reader debugging the wrong thing.
have() { command -v "$1" >/dev/null 2>&1; }
pymod() { python3 -c "import $1" >/dev/null 2>&1; }

LINT_READY=1;   have python3 && pymod yamllint            || LINT_READY=0
SCHEMA_READY=1; have python3 && pymod jsonschema && pymod yaml || SCHEMA_READY=0
REFS_READY=1;   have python3 && pymod yaml                || REFS_READY=0
GEMARA_READY=1; have go && have cue                       || GEMARA_READY=0

git -C "$REPO" worktree add --detach "$WT" "$BRANCH" >/dev/null 2>&1 \
  || { echo "FATAL: could not create worktree for $BRANCH" >&2; exit 2; }

TOOLKIT="$SCRATCH/delivery-toolkit"
if [ "$GEMARA_READY" = 1 ]; then
  ( cd "$WT/delivery-toolkit" && go build -o "$TOOLKIT" . ) \
    >"$SCRATCH/toolkit-build.log" 2>&1 || GEMARA_READY=0
fi

# --- Fingerprint --------------------------------------------------------
# A result is only worth as much as what surrounds it. Every run is stamped
# with exactly what was checked, against what baseline, with which tools —
# a result with no fingerprint cannot be compared to any other run.
BRANCH_SHA="$(git -C "$REPO" rev-parse --short "$BRANCH")"
BASELINE_SHA="$(git -C "$REPO" rev-parse --short "$BASELINE" 2>/dev/null || echo unknown)"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
GO_V="$(go version 2>/dev/null | awk '{print $3}')";        : "${GO_V:=unavailable}"
CUE_V="$(cue version 2>/dev/null | head -1 | awk '{print $NF}')"; : "${CUE_V:=unavailable}"
YAMLLINT_V="$(python3 -m yamllint --version 2>/dev/null | awk '{print $NF}')"; : "${YAMLLINT_V:=unavailable}"

echo "catalog-preflight @ $STAMP"
echo "  branch:   $BRANCH @ $BRANCH_SHA"
echo "  baseline: $BASELINE @ $BASELINE_SHA"
echo "  tools:    go $GO_V · cue $CUE_V · yamllint $YAMLLINT_V · gemara $GEMARA_VERSION"
for pair in "lint:$LINT_READY" "schema:$SCHEMA_READY" "gemara:$GEMARA_READY" "refs:$REFS_READY"; do
  [ "${pair#*:}" = 0 ] && echo "  BLOCKED:  ${pair%%:*} gate tooling unavailable — its results will not render as pass"
done
echo

# --- Gates --------------------------------------------------------------
gate_lint() {
  ( cd "$WT" && python3 -m yamllint -c ./.config/.yamllint . ) \
    >"$SCRATCH/lint.log" 2>&1
}

gate_schema() {
  python3 "$HERE/validate-schemas.py" "$WT" >"$SCRATCH/schema.log" 2>&1
}

gate_gemara() {
  local out="$SCRATCH/compiled" asset def
  rm -rf "$out"; mkdir -p "$out"
  : >"$SCRATCH/gemara.log"
  (
    cd "$WT" || exit 1
    for asset in capabilities threats controls; do
      "$TOOLKIT" compile --build-target identity/iam --type "$asset" \
        --catalogs-dir catalogs --output-dir "$out" --version v0.0.0-ci \
        >>"$SCRATCH/gemara.log" 2>&1 || exit 1
    done
    for asset in capabilities threats controls; do
      case "$asset" in
        capabilities) def='#CapabilityCatalog' ;;
        threats)      def='#ThreatCatalog' ;;
        controls)     def='#ControlCatalog' ;;
      esac
      cue vet -d "$def" "github.com/gemaraproj/gemara@$GEMARA_VERSION" \
        "$out/identity/iam/$asset.yaml" >>"$SCRATCH/gemara.log" 2>&1 || exit 1
    done
  )
}

# Refs gate is diff-aware: violations already present on the baseline are
# waived (surfaced as info), only NEW violations fail — mirroring the PR
# policy that pre-existing defects are fixed/disclosed only in touched files.
: >"$SCRATCH/refs-baseline.txt"
if [ "$REFS_READY" = 1 ]; then
  git -C "$WT" checkout -q --detach "$BASELINE" 2>/dev/null && {
    python3 "$HERE/check-refs.py" "$WT" 2>/dev/null | sort >"$SCRATCH/refs-baseline.txt" || true
    git -C "$WT" checkout -q --detach "$BRANCH"
  }
  if [ -s "$SCRATCH/refs-baseline.txt" ]; then
    echo "note: $(wc -l <"$SCRATCH/refs-baseline.txt" | tr -d ' ') pre-existing refs finding(s) on $BASELINE are waived for this run:"
    sed 's/^/  waived: /' "$SCRATCH/refs-baseline.txt"
    echo
  fi
fi

gate_refs() {
  python3 "$HERE/check-refs.py" "$WT" 2>"$SCRATCH/refs-err.log" | sort >"$SCRATCH/refs-now.txt"
  comm -23 "$SCRATCH/refs-now.txt" "$SCRATCH/refs-baseline.txt" >"$SCRATCH/refs.log"
  [ ! -s "$SCRATCH/refs.log" ] && [ ! -s "$SCRATCH/refs-err.log" ]
}

run_gates() { # sets L S G R to pass|FAIL|BLOCKED
  if [ "$LINT_READY" = 1 ];   then gate_lint   && L=pass || L=FAIL;   else L=BLOCKED; fi
  if [ "$SCHEMA_READY" = 1 ]; then gate_schema && S=pass || S=FAIL;   else S=BLOCKED; fi
  if [ "$GEMARA_READY" = 1 ]; then gate_gemara && G=pass || G=FAIL;   else G=BLOCKED; fi
  if [ "$REFS_READY" = 1 ];   then gate_refs   && R=pass || R=FAIL;   else R=BLOCKED; fi
}

reset_wt() { git -C "$WT" checkout -q -- . && git -C "$WT" clean -fdq; }

FMT="%-34s %-8s %-8s %-8s %-8s %-13s %s\n"
printf "$FMT" FIXTURE LINT SCHEMA GEMARA REFS EXPECT VERDICT
printf "$FMT" ------- ---- ------ ------ ---- ------ -------

ROWS="$SCRATCH/rows.tsv"
: >"$ROWS"
record() { printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" "$6" "$7" >>"$ROWS"; }

MISS=0
ANY_BLOCKED=0

run_gates
BASE_VERDICT=OK
case "$L$S$G$R" in
  *FAIL*)    BASE_VERDICT="BASE NOT GREEN" ;;
  *BLOCKED*) BASE_VERDICT=BLOCKED; ANY_BLOCKED=1 ;;
esac
printf "$FMT" "clean-base ($BRANCH)" "$L" "$S" "$G" "$R" "all-pass" "$BASE_VERDICT"
record "clean-base" "$L" "$S" "$G" "$R" "all-pass" "$BASE_VERDICT"
if [ "$BASE_VERDICT" = "BASE NOT GREEN" ]; then
  echo "aborting: fixtures are only meaningful against a green base" >&2
  cat "$SCRATCH/refs.log" 2>/dev/null >&2
  MISS=1
else
  for dir in "$HERE"/fixtures/*/; do
    name="$(basename "$dir")"
    expect="$(head -1 "$dir/expect" 2>/dev/null || echo MISSING-EXPECT)"
    reset_wt
    if ! bash "$dir/mutate.sh" "$WT" >"$SCRATCH/mutate.log" 2>&1; then
      printf "$FMT" "$name" "-" "-" "-" "-" "$expect" "MUTATOR ERROR (anchor drift?)"
      record "$name" "-" "-" "-" "-" "$expect" "MUTATOR-ERROR"
      MISS=1
      continue
    fi
    run_gates
    verdict=MISS
    case "$expect" in
      fail:lint)   g="$L" ;;
      fail:schema) g="$S" ;;
      fail:gemara) g="$G" ;;
      fail:refs)   g="$R" ;;
      invisible)   g="" ;;
      *)           g="?" ;;
    esac
    if [ "$expect" = invisible ]; then
      case "$L$S$G$R" in
        passpasspasspass) verdict=OK ;;
        *BLOCKED*)        verdict=BLOCKED; ANY_BLOCKED=1 ;;
      esac
    elif [ "$g" = FAIL ]; then
      verdict=OK
    elif [ "$g" = BLOCKED ]; then
      verdict=BLOCKED; ANY_BLOCKED=1
    fi
    [ "$verdict" = MISS ] && MISS=1
    printf "$FMT" "$name" "$L" "$S" "$G" "$R" "$expect" "$verdict"
    record "$name" "$L" "$S" "$G" "$R" "$expect" "$verdict"
  done
fi

EXIT=0
[ "$ANY_BLOCKED" = 1 ] && EXIT=3
[ "$MISS" = 1 ] && EXIT=1

if [ -n "$JSON_OUT" ]; then
  python3 - "$ROWS" "$JSON_OUT" <<EOF
import json, sys
rows = []
for line in open(sys.argv[1]):
    name, lint, schema, gemara, refs, expect, verdict = line.rstrip("\n").split("\t")
    rows.append({"name": name, "gates": {"lint": lint, "schema": schema,
                 "gemara": gemara, "refs": refs}, "expect": expect,
                 "verdict": verdict})
out = {
    "tool": "catalog-preflight",
    "timestamp": "$STAMP",
    "branch": {"ref": "$BRANCH", "sha": "$BRANCH_SHA"},
    "baseline": {"ref": "$BASELINE", "sha": "$BASELINE_SHA"},
    "toolchain": {"go": "$GO_V", "cue": "$CUE_V",
                  "yamllint": "$YAMLLINT_V", "gemara": "$GEMARA_VERSION"},
    "results": rows,
    "exit": $EXIT,
}
json.dump(out, open(sys.argv[2], "w"), indent=2)
print(f"json report: {sys.argv[2]}")
EOF
fi

exit $EXIT

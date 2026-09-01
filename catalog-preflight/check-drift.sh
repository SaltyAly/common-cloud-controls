#!/usr/bin/env bash
# Upstream drift check: has upstream main moved past the pinned baseline,
# and does any of that movement touch files this branch changes?
#
# Contribution branches here are based on a pinned baseline ref so the
# preview diff equals the eventual upstream diff. That guarantee silently
# expires the moment upstream main moves under the pin — this script says
# whether it has, and whether the movement matters for a given branch.
#
# usage: check-drift.sh [branch] [--baseline REF] [--upstream REMOTE-OR-URL]
#
# Exit 0 = no drift, or drift that does not touch this branch's files.
# Exit 1 = drift overlaps files this branch changes — rebase before any
#          upstream PR, and re-run the preflight afterward.
# Exit 2 = fatal (fetch/ref resolution).
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(git -C "$HERE" rev-parse --show-toplevel)" \
  || { echo "FATAL: not inside a git repository" >&2; exit 2; }

BRANCH=""
BASELINE=""
UPSTREAM=""
while [ $# -gt 0 ]; do
  case "$1" in
    --baseline) BASELINE="${2:?--baseline needs a ref}"; shift 2 ;;
    --upstream) UPSTREAM="${2:?--upstream needs a remote or URL}"; shift 2 ;;
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
if [ -z "$UPSTREAM" ]; then
  if git -C "$REPO" remote get-url upstream >/dev/null 2>&1; then
    UPSTREAM=upstream
  else
    UPSTREAM=https://github.com/finos/common-cloud-controls.git
  fi
fi

git -C "$REPO" fetch --quiet "$UPSTREAM" main \
  || { echo "FATAL: could not fetch main from $UPSTREAM" >&2; exit 2; }
UP="$(git -C "$REPO" rev-parse FETCH_HEAD)"
BASE="$(git -C "$REPO" rev-parse "$BASELINE")" \
  || { echo "FATAL: baseline ref $BASELINE does not resolve" >&2; exit 2; }

echo "check-drift @ $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "  branch:   $BRANCH @ $(git -C "$REPO" rev-parse --short "$BRANCH")"
echo "  baseline: $BASELINE @ $(git -C "$REPO" rev-parse --short "$BASE")"
echo "  upstream: $UPSTREAM main @ $(git -C "$REPO" rev-parse --short "$UP")"
echo

if [ "$UP" = "$BASE" ] || git -C "$REPO" merge-base --is-ancestor "$UP" "$BASE"; then
  echo "CLEAN: upstream main has not moved past the pinned baseline."
  exit 0
fi

AHEAD="$(git -C "$REPO" rev-list --count "$BASE..$UP")"
echo "DRIFT: upstream main is $AHEAD commit(s) past the baseline pin:"
git -C "$REPO" log --oneline "$BASE..$UP" | sed 's/^/  /'
echo

SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/check-drift.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT
git -C "$REPO" diff --name-only "$BASE..$UP"      | sort >"$SCRATCH/upstream-files"
git -C "$REPO" diff --name-only "$BASE..$BRANCH"  | sort >"$SCRATCH/branch-files"
comm -12 "$SCRATCH/upstream-files" "$SCRATCH/branch-files" >"$SCRATCH/overlap"

# New catalog IDs claimed upstream since the pin: a branch that assumed
# "next free ID" may now collide with them.
git -C "$REPO" diff "$BASE..$UP" -- 'catalogs/' 2>/dev/null \
  | grep -E '^\+ *(- )?id: ' | sed -E 's/^\+ *(- )?id: */  claimed upstream: /' | sort -u \
  >"$SCRATCH/new-ids"
if [ -s "$SCRATCH/new-ids" ]; then
  echo "catalog IDs added upstream since the pin (check against any next-free-ID assumptions):"
  cat "$SCRATCH/new-ids"
  echo
fi

if [ -s "$SCRATCH/overlap" ]; then
  echo "OVERLAP: upstream changed file(s) this branch also changes:"
  sed 's/^/  /' "$SCRATCH/overlap"
  echo
  echo "The preview diff no longer equals the future upstream diff."
  echo "Rebase the baseline pin, replay the branch, and re-run run-checks.sh."
  exit 1
fi

echo "No file overlap with this branch. The branch's own diff is unaffected,"
echo "but refresh the baseline pin before opening an upstream PR."
exit 0

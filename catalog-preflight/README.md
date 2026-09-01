# catalog-preflight — self-testing pre-flight checks for catalog changes

Two tools for anyone editing CCC catalogs:

1. **`run-checks.sh`** replicates the repository's CI gates locally, adds a
   reference-integrity gate CI does not have, and — the important part —
   **self-tests the whole apparatus against a corpus of seeded defects** on
   every run. A checking apparatus that never fails is indistinguishable from
   one that checks nothing; the fixture corpus is how this one proves it
   still catches what it claims to catch.
2. **`check-drift.sh`** reports whether upstream `main` has moved past the
   pinned baseline a contribution branch is built on, and whether that
   movement touches the branch's files or claims catalog IDs the branch
   assumed were free.

## Quick start

```bash
# Full pre-flight on the current branch, self-test included:
bash catalog-preflight/run-checks.sh

# A specific branch, with a machine-readable report for CI:
bash catalog-preflight/run-checks.sh my-branch --json report.json

# Has upstream moved under my branch?
bash catalog-preflight/check-drift.sh my-branch
```

Requirements: `go`, `cue`, and `python3` with `yamllint`, `jsonschema`, and
`pyyaml`, all on `PATH`. A gate whose tooling is missing reports `BLOCKED` —
never `pass` — and the run exits non-zero (see *Verdicts*). The runner works
in a throwaway git worktree and never touches your checkout.

## Gates

| Gate | Replicates | Command |
|---|---|---|
| LINT | CI `linting_check` exactly | `yamllint -c ./.config/.yamllint .` repo-wide |
| SCHEMA | CI `yaml_check` (local stand-in) | `validate-schemas.py` — same schemaMapping, python jsonschema, scoped to `catalogs/identity/iam/` |
| GEMARA | CI `gemara_check` exactly | delivery-toolkit compile + `cue vet` against gemara (version pinned via `GEMARA_VERSION`, default `v1.2.0`), three asset types |
| REFS | **nothing — CI has no equivalent** | `check-refs.py` — every `CCC.IAM.*` reference-id must resolve, and remarks must equal the referenced entry's title. Diff-aware: violations already present on the baseline ref are waived (printed as info); only new violations fail. |

## Every run is fingerprinted

The header of every run records the branch and commit checked, the baseline
ref and commit the refs gate diffed against, and the exact toolchain versions
used. A green run with no fingerprint cannot be compared with any other run —
"it passed yesterday" is only meaningful if you can say what it passed *on*.
The `--json` report carries the same fingerprint, so a result file separated
from its terminal output stays self-describing.

## Verdicts

Per fixture: `OK` (the expected gate caught the defect), `MISS` (it did not —
the apparatus has a hole), `BLOCKED` (the relevant gate could not run, so
nothing is known), `MUTATOR ERROR` (the fixture could not be applied, usually
because its content anchor drifted).

A blocked check is not a passed check. Exit codes keep the three outcomes
distinct: `0` all OK, `1` any MISS or base not green, `3` no misses but at
least one gate BLOCKED. CI should treat anything non-zero as a stop.

## Fixtures

Each fixture directory holds a `mutate.sh` that applies exactly one seeded
defect to a known-green copy of the `identity/iam` catalog, and an `expect`
file naming the gate that must catch it. Mutators anchor on content present
on every branch of this catalog; a mutator that cannot find its anchor
reports `MUTATOR ERROR` rather than silently passing.

| Fixture | Seeded defect | Expect |
|---|---|---|
| 01-lint-overlength-line | 132-char breakable line | fail:lint |
| 02-lint-crlf-first-line | CRLF on line 1 | fail:lint |
| 03-schema-unknown-key | unknown top-level key | fail:schema |
| 04-refs-dangling-threat-ref | control references a nonexistent threat | fail:refs |
| 05-refs-remark-title-mismatch | reference remark carries another entry's title | fail:refs |
| 07-lint-crlf-appended | CRLF appended to an LF file | invisible |
| 08-lint-trailing-space | trailing whitespace | fail:lint |

`invisible` means all gates MUST pass: the defect is real but mechanically
undetectable, and the fixture pins that blind spot as a measured fact rather
than a suspicion.

## Known blind spots (empirically verified)

1. **`line-length` ignores unbreakable overflows.** `allow-non-breakable-words`
   (inherited from yamllint's `relaxed` preset) permits lines over 120
   characters when the overflow is a single long token. A long URL or ID will
   sail through CI; only lines with breakable content fail.
2. **`new-lines` only inspects the first line ending.** A stray CRLF later in
   an LF file is invisible to CI (fixture 07 pins this).
3. **No CI gate resolves references.** A control can cite a nonexistent
   threat, or carry another entry's title in its remark, and pass every CI
   gate. This is why the REFS gate exists; it has found real, previously
   unflagged mismatches in this catalog.
4. **Trailing spaces are ERROR level under this repo's config** — worth
   knowing because copy-paste and review suggestion blocks introduce them
   easily.
5. **Semantic style rules** (compound MUST statements, vocabulary drift,
   rationale placement) are invisible to all mechanical gates and remain a
   human-review responsibility.

## Working practice: finding → fixture

When a review or CI run surfaces a defect class these gates should have
caught but did not, add a fixture reproducing it *before* shipping the fix.
Each miss then becomes a permanent regression check on the checking apparatus
itself, and the corpus grows exactly as fast as its blind spots are found.

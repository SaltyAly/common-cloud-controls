# FINOS CCC — Consolidation & Review Round 1 — 2026-08-25

> FINOS-side facts only. Baseline unchanged: fork `finos-baseline` = finos
> upstream `9bda372` (2026-08-19).

## Fork / PR state

- **PR #6 `feat/iam-catalog-enhancements` (OPEN, active):** the single
  consolidated preview PR requested by the reviewer. After review round 1 it
  carries CN03.AR03 (confused deputy), CN14/CN15 (role hygiene), CN16 +
  TH13/TH14 (lifecycle states), CN08 broadened (verified reactivation,
  AR02/AR03), metadata `mapping-references`. Head `9e8d332`; 4 files,
  +347/−13 vs baseline.
- **PR #7 `feat/iam-consent-controls` (OPEN, new):** CN12 (consent-form
  fidelity) + CN13 (revocation propagation), split out of #6 per review —
  no capability in `capabilities.yaml` models an authorization server or
  consent surface, so the WG scope ruling proceeds without blocking #6.
  Head `01730ba`; 1 file, +185/−0 vs baseline.
- **PRs #4/#5: CLOSED**, superseded by #6. **PRs #1/#2 (.feature tests):
  still ON HOLD** pending Rob's usage verdict.

## Review round 1 (2026-08-25, PR #6)

Reviewer verdict: "well above the bar for a first upstream contribution";
1 critical / 3 major / 3 minor / 1 nit, all verified against source and all
addressed same day (commit `9e8d332` on #6; CN12/CN13 fixes carried into #7):

- **Critical:** one 124-char line in the MITRE mapping — resolved by the
  TH13 split (remark no longer needs the qualifying parenthetical).
- **TH13 split into TH13 (fail-open, maps to T1078.004) + TH14 (transient
  denials mistaken for permanent revocation, deliberately unmapped).**
  Per-threat mapping honesty instead of a per-facet footnote.
- **CN08** title/objective broadened so the reactivation ARs are
  discoverable from the title; AR02 recommendation restated as imperative
  implementation guidance; AR03 examples moved into the catalog's
  vocabulary (group membership, assumable roles, MFA enrollment, policy
  conditions).
- **CN13** AR02 "propagated" → "published"; AR03 restated fully
  service-side (report revoked grants as revoked on query) — obligations
  must be observable from the service under assessment.
- **CN12** AR04 recommendation distinguishes the UI obligation from AR05's
  protocol obligation.
- Numbering position: preview IDs frozen; upstream PR renumbers
  CN14/CN15/CN16 → CN12/CN13/CN14 so upstream never sees a gap.

## CI gates — now three, not two

`linting_check.yml` (yamllint, `-c ./.config/.yamllint`, line-length 120
as error) was missed in earlier pre-flights. Full local gate replication is
now: (1) `yaml_check` JSON schemas, (2) `gemara_check` = delivery-toolkit
compile + `cue vet -d '#<Type>Catalog' github.com/gemaraproj/gemara@v1.2.0`,
(3) `yamllint -c ./.config/.yamllint .` repo-wide. All three PASS on both
PR heads (local; fork PRs do not run Actions).

## Reviewer conventions distilled from round 1 (apply to every future PR body)

- Every claim in the description must survive independent verification —
  gate counts, AR counts, convention claims ("examples in recommendation"
  was an overclaim: empty recommendations are fine, just don't claim it).
- Disclose incidental fixes to pre-existing content, even beneficial ones —
  unexplained hunks stop reviewers.
- No fork-local PR numbers in anything destined upstream.
- "Needs your judgment" sections are welcome, but state a position with
  evidence, not an open question.
- MUST text: only obligations observable from the service under assessment.
- `recommendation`: imperative how-to guidance; rationale belongs in threat
  descriptions or the PR body.
- Examples must use the catalog's own vocabulary (capability surface), not
  an adjacent domain's.

## Open questions (FINOS side)

1. **WG ruling on consent-surface scope** (PR #7): add a consent/
   authorization-grant capability, or rule it out of scope for identity/iam.
   Owner: Eddie Knight → Security WG.
2. **Rob's verdict on `.feature` usage** — unchanged, still open.

## Addendum — 2026-08-25 evening (self-review round + pre-flight hardening)

- **PR #6 advanced to `0e08671`** after a structured self-review of both
  PRs: `85c07ff` completes the CN08 discoverability fix (objective now also
  names AR03's attribute re-evaluation), `0e08671` corrects TH04's
  temporary-credentials capability ref CP11→CP13 — a fourth pre-existing
  reference/remark mismatch of the same class as the CN01/CN03/CN11 fixes,
  missed by every prior human pass. PR bodies tightened (CN14/CN15 bullet
  precision, complete incidental-fix disclosure, provenance, PR #7
  merge-order note).
- **Pre-flight now includes a fourth, local-only gate:** reference
  integrity (every `CCC.IAM.*` reference-id resolves; remarks match the
  referenced entry's title), diff-aware against the finos baseline. No CI
  gate checks this — a control citing a nonexistent threat passes all
  three upstream gates.
- **Verified CI gate semantics** (via a seeded-defect fixture corpus, local):
  yamllint's `line-length` permits unbreakable over-length tokens
  (`allow-non-breakable-words` via the relaxed preset); `new-lines` checks
  only the first line ending, so a stray CRLF later in a file passes;
  trailing spaces are error-level under this repo's config.
- **Consent-controls direction (PR #7):** maintainer guidance (DM) is to
  model the capability and threat(s) before the controls — rework queued:
  add a consent/authorization-grant capability + a purpose-built
  misrepresented-scope threat, then rewire CN12/CN13 references.

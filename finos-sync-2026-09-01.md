# FINOS CCC — Consent-Surface Rework & Pre-flight Tooling — 2026-09-01

> FINOS-side facts only. Baseline pin unchanged: fork `finos-baseline` =
> finos upstream `9bda372` (2026-08-19). Upstream main has moved past the
> pin — see Drift below.

## Fork / PR state

- **PR #6 `feat/iam-catalog-enhancements`:** unchanged at `0e08671`,
  awaiting review round 2.
- **PR #7 `feat/iam-consent-controls` reworked** per the maintainer's
  guidance to model the consent surface in the capability and threat
  catalogs before the controls. Head `68cc862`; 4 files, +221/−0 vs
  baseline:
  - **CP19 "User Consent and Authorization Grant Management"** — new
    capability the consent controls hang off. Deployed anchors named in the
    PR body: Microsoft Entra ID's consent framework, Amazon Cognito's
    hosted UI, Google's OAuth consent screen.
  - **TH15 "Authorization Grant Diverges from Displayed Consent"** — one
    purpose-built failure class with two manifestations: grant-time scope
    misrepresentation (CN12's territory) and post-revocation continued
    access (CN13's). The body offers a per-facet split (TH13/TH14 style) if
    the WG prefers.
  - **TH15 → MITRE ATT&CK T1528** in the standalone MappingDocument —
    grant-time facet only; the divergence facet is deliberately unmapped,
    the same position TH14 takes in PR #6.
  - **CN12/CN13 threat refs rewired** off TH01/TH10 (ill-fitting stand-ins,
    flagged in self-review) onto TH15.
  - **CN13.AR05 narrowed to `tlp-red`** per the CN10.AR01 precedent
    (alerting obligations are red-tier in this catalog); AR04's logging
    obligation keeps green/amber/red, matching CN10.AR02.
  - Coordination note: #6 and #7 both append to
    `mappings/threats-mitre-attack.yaml`; whichever lands second re-merges
    that file trivially.
- Preview IDs CP19/TH15 assume #6 (TH13/TH14) merges first; everything
  renumbers to next free upstream IDs on acceptance.
- All four pre-flight gates green on `68cc862` before and after push
  (three CI gates + reference-integrity), fingerprinted JSON verdict
  reports retained locally.

## Pre-flight tooling now versioned on the fork

Branch `feat/catalog-preflight-tooling` @ `8a0fbe8` adds a
`catalog-preflight/` module (sibling to `cfi-testing/`):

- Local replication of the three CI gates plus a **diff-aware
  reference-integrity gate CI does not have** (every `CCC.IAM.*` reference
  resolves; remarks equal the referenced entry's title — the gate that
  found the pre-existing TH04 CP11→CP13 mismatch fixed in PR #6).
- **Self-testing:** every run replays a corpus of seeded-defect fixtures
  (single-defect mutator scripts — no broken YAML sits on any branch) and
  reports OK/MISS per fixture, so the checking apparatus proves it still
  catches what it claims.
- **Fingerprinted results** (branch + baseline SHAs, toolchain versions)
  and `--json` CI-consumable verdict reports carrying the same fingerprint.
- **BLOCKED ≠ FAIL ≠ pass:** a gate whose tooling is unavailable reports
  BLOCKED and the run exits distinctly (3) — a blocked check never renders
  green.
- **`check-drift.sh`** reports whether upstream main moved past the
  baseline pin, whether the movement touches a branch's files, and which
  catalog IDs upstream claimed since the pin. Covered by a synthetic-repo
  self-test that pins the dash-form (`- id:`) detection regression;
  verified to fire by temporarily reverting the fix.

Offered upstream if FINOS wants any tier of it; deliberately not a PR.

## Drift

`check-drift.sh` first run found finos main @ `5a0878d` = pin +2 commits:
object-storage catalog additions (#1195, claiming 17 `CCC.ObjStor.*` IDs —
none in `identity/iam`, so no numbering impact on the open PRs) and website
cleanup (#1215). No file overlap with either open PR branch. Plan: refresh
the `finos-baseline` pin immediately before cutting the upstream PR, after
review round 2 — never mid-review, so the preview diff stays byte-stable
under review.

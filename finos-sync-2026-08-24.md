# FINOS CCC — Sync & Repo State — 2026-08-24

> FINOS-side facts only. Epic-facing analysis lives in
> `knowledge/finos-ccc-contribution-pipeline.md` (internal; never shared
> upstream). Nothing in this file or elsewhere in `ccc/` may contain
> Epic-internal or partner-confidential material.

## Sync baseline

- Fork `main` merge commit `db1a748` = finos upstream `9bda372` (2026-08-19).
  Synced 2026-08-24. Fork merge commits record the finos merge point in their
  message: `Merge finos/common-cloud-controls main (<sha>, <date>)`.
- Upstream delta reviewed: `fca168e..9bda372` — 26 commits, 167 files,
  +7,746/−4,118.
- Fork `main` carries content FINOS has not accepted (commit `679c33f`,
  IAM consent/revocation controls) — fork `main` ≠ accepted standard.

## Upstream conventions (as of 9bda372 — follow or CI fails)

- **No inline `external-mappings` in catalog YAML.** External framework
  references live in standalone Gemara MappingDocuments at
  `catalogs/<category>/<service>/mappings/threats-<framework>.yaml`,
  validated by `schemas/mappingdocument-schema.json`.
  (Evidence: `docs/mapping-documents.md`, commit `555e347`.)
- **Core catalog path is `catalogs/core/core/`** (renamed from
  `catalogs/core/ccc/`, commit `6da27e6`).
- **Schemas follow Gemara v1.2.0 shapes.** Two CI gates: `gemara_check`
  (delivery-toolkit compile + `cue vet` against
  `github.com/gemaraproj/gemara@v1.2.0`, cue v0.16.0) and `yaml_check`
  (raw YAML vs `schemas/*.json`).
- Authoring style (reviewer-confirmed): one assertion per assessment
  requirement — split AND-compounds; examples and parentheticals go in
  `recommendation`, never in MUST text.

## Fork / PR state

- **PR #4 `feat/iam-catalog-controls` (OPEN, active):** CN12 consent-form
  fidelity + CN13 revocation propagation + CN03.AR03/TH12 confused-deputy
  constraint + CN14/CN15 role hygiene; metadata `mapping-references` for
  CCC.Core v2025.10, NIST-CSF 2.0, NIST 800-53 Rev.5, PCI-DSS v4.0.1.
  Successor to closed finos PR #1154 (wrong-base). Awaiting Eddie Knight's
  preview → then reopen against finos.
- **PRs #1 (relational tests) / #2 (object-storage tests): ON HOLD** — all
  `.feature` behavioral-test work paused until FINOS confirms whether anyone
  uses those files (Rob, via Eddie, asked 2026-07-06; no verdict yet).
- **PR #3 (core tests): CLOSED** — core catalog out of scope; branch retained
  on the fork.
- All open branches merged with synced main 2026-08-24; PRs report
  MERGEABLE/CLEAN.

## CI pre-flight (2026-08-24, local)

- Gemara gate replicated exactly (compile + `cue vet` v1.2.0): **PASS** for
  identity/iam capabilities, threats, controls.
- `yaml_check` JSON-schema validation: **PASS** for the two files PR #4
  touches (controls.yaml, metadata.yaml).
- Threat reference integrity: all TH01–TH12 references in controls.yaml
  resolve in post-merge threats.yaml.
- Local tooling: cue v0.16.0 (`~/.local/bin/cue`), Go 1.25.0
  (`~/.local/sdk/go`), delivery-toolkit builds from `delivery-toolkit/`.

## Open questions (FINOS side)

1. **PR #4 review timing; will CN12–CN15 IDs/text survive review?** —
   Owner: Alyse + FINOS Security WG via Eddie Knight.
2. **Rob's verdict on `.feature` file usage** — decides whether PRs #1/#2
   revive or are formally shelved. Owner: Eddie Knight → Rob.
3. **Fork↔finos sync cadence ownership** — without a cadence, conventions
   drift silently and each review re-derives everything. Owner: Alyse.
   (Upstream grc.store mapping publication "not wired up yet" — repo files
   are the only citable artifact form.)

## Upstream areas reviewed, no action needed

New CCC.K8S catalog (`3138cc1`); AI/ML catalogs; mechanical
inline→MappingDocument migrations across compute/crypto/database/devtools/
management/networking/storage; website/docs restructuring (~100 of 167 files);
CFI config bumps; `delivery-toolkit compile --type mappings`; core
`groups.yaml` `observability` group.

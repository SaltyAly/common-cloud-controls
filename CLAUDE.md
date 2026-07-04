# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

FINOS Common Cloud Controls (CCC) is an open standard defining consistent security,
resiliency, and compliance controls for common cloud services across AWS, Azure, and
GCP. The repo holds both **the standard itself** (human-authored catalog YAML) and **the
tooling** that compiles, validates, tests, and publishes it.

## Two halves of the repo

1. **The catalogs** (`catalogs/`) — the standard as data. Per-service YAML authored by
   contributors, grouped `catalogs/<category>/<service>/` (e.g. `catalogs/storage/object/`).
   A service folder holds `metadata.yaml`, `capabilities.yaml`, and where applicable
   `threats.yaml`, `controls.yaml`, and Gherkin `tests/*.feature`. `catalogs/core/ccc/`
   holds shared capabilities/threats/controls that services import by reference (never
   duplicate); `catalogs/categories.yaml` defines the category taxonomy.
2. **The tooling** — a Go workspace under `modules/` (plus `delivery-toolkit/`) and a
   Docusaurus website under `website/`, which together compile, validate, behaviourally
   test, and render the catalogs.

`AGENTS.md` is the companion instruction file (skills, catalog authoring conventions,
style guides). Read it before authoring or editing catalog content — that guidance is not
repeated here. Authoring skills live in `skills/`; the onboarding order for a new service
is capability → threat → control → behavioural-test-analysis → features-and-cloud-api.

## Catalog compile & validation pipeline

Source YAML is ergonomic (split metadata, imports-by-reference) and is **not** what gets
published. `delivery-toolkit` compiles each asset into one self-describing **Gemara**
artifact, which is then validated against the Gemara CUE schema with `cue vet`.

```bash
# Compile one catalog asset (run from delivery-toolkit/, which is in the go workspace)
go run . compile --build-target storage/object --type controls \
  --catalogs-dir ../catalogs --output-dir /tmp/out --version v0.0.0-dev
# --type is one of: capabilities | threats | controls
```

CI (`.github/workflows/gemara_check.yml`) compiles every touched build target and runs
`cue vet` against the pinned Gemara spec. Editing shared/core files
(`catalogs/categories.yaml`, `catalogs/core/ccc/**`) cascades re-validation to **every**
service, because all catalogs depend on them.

> **Version-sync gotcha:** the Gemara spec version is pinned in two places that must be
> bumped together — `gemaraSpecVersion` in `delivery-toolkit/cmd/compile.go` and
> `GEMARA_SPEC_REF` in `.github/workflows/gemara_check.yml`.

Two independent validation layers apply to catalog YAML — keep both green:
- **JSON Schema** (`schemas/*.json`) validates raw source YAML in-editor (VSCode Red Hat
  YAML) and in CI (`yaml_check.yml`).
- **Gemara CUE** validates the *compiled* artifact.

## Go workspace (`modules/`)

`modules/go.work` links the modules for local dev and CI (`GOWORK` enabled). Members:
`cloud-api` (provider APIs + shared types), `cloud-testing-dsl` (Cucumber/Godog steps),
`cloud-api-test` (live integration tests), `reporters` (HTML/OCSF/summary formatters),
`runner` (behavioural test runner lib + `ccc-compliance` CLI), `ccc-behavioural-plugin`
(Privateer plugin running the same tests), and `../delivery-toolkit`.

```bash
./modules/build.sh                 # build every workspace module
./modules/build.sh runner --compliance-bin ./runner/ccc-compliance   # build one + a binary
go test ./...                      # unit tests — run inside a module dir (workspace resolves deps)
```

## Behavioural / CFI compliance testing

Behavioural tests assert a **live cloud deployment** against CCC control requirements via
[Privateer](https://github.com/privateerproj/privateer). Requires Go, the `pvtr` CLI, and
authenticated cloud credentials (`aws`/`az`/`gcloud`). Configs live in
`cfi-testing/privateer-config/`; `actions-config/*.yaml` drives the CI matrix.

```bash
# Generate DEV catalogs first (runner fails pointing here if missing)
npm ci --prefix website && npm run generate:catalogs --prefix website

# Run against a fixture (paths in -c are relative to cfi-testing/)
./cfi-testing/run-compliance-tests.sh -c privateer-config/finos-integration/vpc/aws-vpc-good.yml \
  -S awsVpcGood -s vpc -g '@Behavioural'
# --debug runs the plugin in-process (no pvtr); --skip-build skips the Go build
```

`cloud-api` integration tests are separate (build-tagged, hit real cloud resources against
applied terraform fixtures):

```bash
cd modules/cloud-api-test
./run-integration-tests.sh <aws|azure|gcp|all>   # go test -tags=integration, merges coverage
```

## Website (`website/`, Docusaurus, published to ccc.finos.org)

```bash
npm ci --prefix website
npm run generate:catalogs --prefix website   # compile catalog assets into src/data/
npm run fetch:cfi --prefix website           # download CFI test artifacts (needs GITHUB_TOKEN)
npm start --prefix website                   # dev server at localhost:3000
npm run build --prefix website               # production build (runs prebuild: fetch + generate)
```

## Linting (CI-enforced)

```bash
markdownlint '**/*.md' --config ./.config/.markdownlint.yaml
yamllint -c ./.config/.yamllint .
```

PR **titles** must follow Conventional Commits (`pr_title.yaml` runs semantic-pull-request).
The `main` branch is an iterative development branch; PRs target it directly.

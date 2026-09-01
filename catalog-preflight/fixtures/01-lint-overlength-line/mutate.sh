#!/usr/bin/env bash
# Seed: a 132-char BREAKABLE line (contains spaces) — the long-line class
# hand-edited prose most often introduces.
# NB: a single unbreakable long token is NOT flagged
# (allow-non-breakable-words, inherited from yamllint's relaxed preset) —
# that discovery is why this mutator uses spaced words.
set -eu
f="$1/catalogs/identity/iam/controls.yaml"
printf '# %sword\n' "$(printf 'word %.0s' $(seq 1 26))" >> "$f"

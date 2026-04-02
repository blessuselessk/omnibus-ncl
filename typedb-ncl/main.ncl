# typedb-ncl — TypeDB knowledge graph schema layer
#
# The master schema for git + GitHub + Algora bounties.
#
# Base: git-metrics/schema.tql provides git internals, GitHub,
#   GitLab, code analysis, security, CI/CD (1,433 lines of TypeQL).
#
# This subproject provides:
#   1. Meta layer (types.ncl, schema.ncl, builders.ncl) —
#      reusable Nickel contracts for TypeDB 3.0 schema generation.
#   2. Algora module (algora.ncl) — bounties, payouts, claims,
#      completions, plus wiring to git-metrics entities.
#   3. Composition — merge base + extensions into a unified schema.
#
# Export:
#   nickel export --format text → TypeQL define blocks
#   nickel export --format json → structured schema for tooling
{
  lib = import "lib/main.ncl",
}

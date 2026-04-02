# git-metrics-ncl — Git repository knowledge graph as Nickel
#
# Comprehensive TypeDB 3.x schema for representing every meaningful datapoint
# of a git repository: internal objects, history, code analysis, and platform
# collaboration.
#
# Architecture:
#   1. Meta layer (from typedb-ncl): contracts, builders, TypeQL renderer
#   2. Domain modules: attributes, git-core, repository, filesystem, diff-blame,
#      history, code-analysis, contributors, github, gitlab, security, rules
#   3. Assembly: lib/main.ncl merges all domains into a single SchemaDef
#
# Export:
#   nickel export --format text examples/schema-export.ncl   → TypeQL define block
#   nickel export --format json examples/schema-json.ncl     → structured JSON
#   nickel export --format text examples/full-export.ncl     → base + Algora extension
{
  lib = import "lib/main.ncl",
}

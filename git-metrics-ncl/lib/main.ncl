# git-metrics-ncl — hub module
#
# Re-exports all domain modules and assembles the full schema.
# Uses typedb-ncl's meta layer for types, builders, and rendering.
let _Meta = import "../../typedb-ncl/lib/main.ncl" in
let _merge = _Meta.builders.merge_schemas in

let _attributes = import "attributes.ncl" in
let _git_core = import "git-core.ncl" in
let _repository = import "repository.ncl" in
let _filesystem = import "filesystem.ncl" in
let _diff_blame = import "diff-blame.ncl" in
let _history = import "history.ncl" in
let _code_analysis = import "code-analysis.ncl" in
let _contributors = import "contributors.ncl" in
let _github = import "github.ncl" in
let _gitlab = import "gitlab.ncl" in
let _security = import "security.ncl" in
let _rules = import "rules.ncl" in

let _base = { attributes = _attributes.all, entities = [], relations = [], rules = [] } in
let _domain_schemas = [
  _git_core.schema,
  _repository.schema,
  _filesystem.schema,
  _diff_blame.schema,
  _history.schema,
  _code_analysis.schema,
  _contributors.schema,
  _github.schema,
  _gitlab.schema,
  _security.schema,
  _rules.schema,
] in

{
  meta = _Meta,
  attributes = _attributes,
  git_core = _git_core,
  repository = _repository,
  filesystem = _filesystem,
  diff_blame = _diff_blame,
  history = _history,
  code_analysis = _code_analysis,
  contributors = _contributors,
  github = _github,
  gitlab = _gitlab,
  security = _security,
  rules = _rules,

  # Full assembled schema — all domain modules merged
  schema = std.array.fold_left _merge _base _domain_schemas,

  # Ingestion templates — TypeQL insert statements by domain
  ingestion = import "ingestion/main.ncl",
}

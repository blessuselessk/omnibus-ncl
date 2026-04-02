# Export git-metrics base + Algora bounty extension as TypeQL
#
# Replaces the old `cat schema.tql && nickel export algora` workflow
# with native Nickel composition.
let Lib = import "../lib/main.ncl" in
let Algora = import "../../typedb-ncl/lib/algora.ncl" in
let merged = Lib.meta.builders.merge_schemas Lib.schema Algora.algora_schema in
merged |> Lib.meta.schema.to_typeql

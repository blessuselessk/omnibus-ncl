# Export Algora module as TypeQL
#
# Compose with git-metrics base: just tdb-full
# Usage: nickel export --format text typedb-ncl/examples/algora-export.ncl
let Lib = import "../lib/main.ncl" in

Lib.algora.algora_schema |> Lib.schema.to_typeql

# Export Algora module as JSON
# Usage: nickel export --format json typedb-ncl/examples/algora-json.ncl
let Lib = import "../lib/main.ncl" in

Lib.algora.algora_schema |> Lib.schema.to_json

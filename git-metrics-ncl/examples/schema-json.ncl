# Export the full git-metrics schema as JSON
let Lib = import "../lib/main.ncl" in
Lib.schema |> Lib.meta.schema.to_json

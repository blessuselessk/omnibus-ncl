# Export the full git-metrics schema as TypeQL
let Lib = import "../lib/main.ncl" in
Lib.schema |> Lib.meta.schema.to_typeql

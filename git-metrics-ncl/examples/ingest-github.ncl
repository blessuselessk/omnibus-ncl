# Export GitHub platform ingestion templates
let S = import "../../typedb-ncl/lib/schema.ncl" in
let I = import "../lib/ingestion/main.ncl" in
S.render_queries I.github

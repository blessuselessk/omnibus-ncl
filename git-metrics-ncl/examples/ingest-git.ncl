# Export git-core ingestion templates (commits, refs, files, blame)
let S = import "../../typedb-ncl/lib/schema.ncl" in
let I = import "../lib/ingestion/main.ncl" in
S.render_queries (I.repo @ I.commits @ I.refs @ I.files)

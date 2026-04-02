# Preload → validate → compose — the full gated workflow
#
# Both nodes are complete with schemas, so ComposableManifest passes
# and compose_validated produces a Pipeline with ValidChain enforcement.
let B = import "../lib/builders.ncl" in
let PL = import "../lib/preload.ncl" in

let fetch =
  B.bash "fetch" "curl -s https://api.github.com/repos/porkg/porkg"
  |> B.with_schemas
    { type = 'null }
    { type = 'object }
  |> B.networked
in

let transform =
  B.bash "transform" "jq '{name: .name, stars: .stargazers_count}'"
  |> B.with_schemas
    { type = 'object }
    { type = 'object, properties = { name = {}, stars = {} } }
  |> B.sandboxed
in

let manifest = PL.preload_all "fetch-transform" [fetch, transform] in

# This succeeds because both nodes are composable (ready + have schemas).
# If any node lacked schemas, ComposableManifest would reject it.
PL.compose_validated manifest

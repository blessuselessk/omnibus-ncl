# Basic preload — diagnose + enrich nodes, get a manifest
let B = import "../lib/builders.ncl" in
let PL = import "../lib/preload.ncl" in

let fetch =
  B.bash "fetch" "curl -s https://api.github.com/repos/porkg/porkg"
  |> B.with_schemas
    { type = 'null }
    { type = 'object, description = "GitHub repo JSON" }
  |> B.networked
in

let transform =
  B.bash "transform" "jq '{name: .name, stars: .stargazers_count}'"
  |> B.with_schemas
    { type = 'object }
    { type = 'object, properties = { name = { type = 'string }, stars = { type = 'number } } }
  |> B.sandboxed
in

PL.preload_all "fetch-and-transform" [fetch, transform]

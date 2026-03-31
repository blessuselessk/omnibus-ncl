# Fetch-and-process pipeline
#
# Two nodes:
# 1. curl: fetch JSON from an API (needs network)
# 2. jq: extract and transform (sandboxed, no network)
#
# Shows how constraints differ per node — the fetch node gets
# network access, the transform node gets locked down.
let B = import "../lib/builders.ncl" in
let P = import "../lib/pipe.ncl" in

let fetch =
  B.bash "fetch" "curl -s https://api.github.com/repos/porkg/porkg"
  |> B.with_schemas
    { type = "null", description = "No input" }
    { type = "object", description = "GitHub repo JSON" }
  |> B.networked
  & {
    description = "Fetch repo metadata from GitHub API",
    constraints = {
      fs = { mode = 'none },
      resources = { timeout_seconds = 10 },
    },
  }
in

let transform =
  B.bash "transform" "jq '{name: .name, stars: .stargazers_count, lang: .language, description: .description}'"
  |> B.with_schemas
    { type = "object", description = "GitHub repo JSON" }
    {
      type = "object",
      properties = {
        name = { type = "string" },
        stars = { type = "number" },
        lang = { type = "string" },
      },
    }
  |> B.sandboxed
  & { description = "Extract key fields" }
in

P.pipeline "fetch-and-process" [fetch, transform]

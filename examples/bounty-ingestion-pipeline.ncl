# Bounty ingestion pipeline — connects tooling-ncl to typedb-ncl
#
# A preloaded CodeNode pipeline that:
#   1. Fetches active bounties from Algora API
#   2. Transforms JSON response → TypeQL insert statements
#   3. Loads into TypeDB via console
#
# Preload validates each node individually, then compose_validated
# wires them into a schema-checked Pipeline. Export as shell script
# or process-compose config for execution.
let B = import "../tooling-ncl/lib/builders.ncl" in
let PL = import "../tooling-ncl/lib/preload.ncl" in
let P = import "../tooling-ncl/lib/pipe.ncl" in

# --- Node 1: Fetch bounties from Algora API ---
let fetch_bounties =
  B.bash
    "fetch-bounties"
    "curl -s \"https://console.algora.io/api/orgs/${ALGORA_ORG}/bounties?limit=100\""
  |> B.with_schemas
    { type = 'null, description = "No input — fetches from API" }
    {
      type = 'object,
      description = "Algora API response",
      properties = {
        items = { type = 'array },
        next_cursor = { type = 'string },
      },
    }
  |> B.networked
  |> B.with_env { ALGORA_ORG = "ghostty-org" }
in

# --- Node 2: Transform bounties → TypeQL inserts ---
let to_typeql =
  B.bash
    "to-typeql"
    m%"
jq -r '.items[] | "insert $b isa bounty, has bounty-id \"\(.id)\", has amount-cents \(.amount), has currency \"\(.currency)\", has bounty-status \"\(.status)\";"'
    "%
  |> B.with_schemas
    {
      type = 'object,
      description = "Algora API response with items array",
      properties = { items = { type = 'array } },
    }
    { type = 'string, description = "TypeQL insert statements, one per line" }
  |> B.sandboxed
in

# --- Node 3: Load into TypeDB ---
let load_typedb =
  B.bash
    "load-typedb"
    m%"
while IFS= read -r stmt; do
  echo "$stmt" | typedb console --command="transaction ${TYPEDB_DB} data write" 2>&1
done
    "%
  |> B.with_schemas
    { type = 'string, description = "TypeQL insert statements" }
    { type = 'string, description = "TypeDB console output" }
  |> B.networked
  |> B.with_env { TYPEDB_DB = "bounty-graph" }
in

# --- Preload all nodes, validate, compose ---
let _manifest = PL.preload_all "bounty-ingestion" [fetch_bounties, to_typeql, load_typedb] in
let _pipeline = PL.compose_validated _manifest in

{
  # Preload manifest — shows validation state of each node
  preload = {
    stats = _manifest.stats,
    fingerprint = PL.manifest_fingerprint _manifest,
  },

  # Composed pipeline (only if all nodes are composable)
  pipeline = _pipeline,

  # Export as executable shell script
  script = P.to_shell_script _pipeline,

  # Export as process-compose config
  processes = P.to_process_compose _pipeline,
}

# Export the PROSE composability graph as JSON.
# Usage: nickel export --format json prose-ncl/examples/graph-export.ncl
let G = import "../lib/graph.ncl" in

{
  tiers = G.tiers,
  valid_edges = G.valid_edges,
  invalid_edges = G.invalid_edges,
  feedback_loops = G.feedback_loops,
}

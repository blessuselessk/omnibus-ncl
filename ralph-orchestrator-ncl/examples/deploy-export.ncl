# Deploy a ralph loop to GitHub Actions via massless-driver
#
# Takes the omnibus-ncl ralph config and produces a GHA workflow
# that runs the loop on an ubuntu runner for up to 2 hours.
#
# Usage: nickel export --format json ralph-orchestrator-ncl/examples/deploy-export.ncl
#   → produces workflow JSON, save as .github/workflows/ralph-loop.json
let D = import "../lib/deploy.ncl" in
let ralph_config = import "omnibus-ncl-config.ncl" in

D.to_workflow "ralph-omnibus-ncl" "blessuselessk" ralph_config

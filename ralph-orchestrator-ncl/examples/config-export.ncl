# Export wrapper — validates omnibus-ncl config against RalphConfig
# Usage: nickel export --format json ralph-orchestrator-ncl/examples/config-export.ncl
let { RalphConfig, .. } = import "../lib/config.ncl" in
let config = import "omnibus-ncl-config.ncl" in

config | RalphConfig

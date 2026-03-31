# Export wrapper — validates rust project config
# Usage: nickel export --format json ralph-orchestrator-ncl/examples/rust-export.ncl
let { RalphConfig, .. } = import "../lib/config.ncl" in
let config = import "rust-project.ncl" in

config | RalphConfig

# Export wrapper — validates standalone config against ComposeConfig
# Usage: nickel export --format json process-compose-ncl/examples/standalone-export.ncl
let { ComposeConfig, .. } = import "../lib/config.ncl" in
let config = import "standalone.ncl" in

config | ComposeConfig

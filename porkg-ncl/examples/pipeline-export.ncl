# Export wrapper — validates locked-down config
# Usage: nickel export --format json porkg-ncl/examples/pipeline-export.ncl
let { PorkgConfig, .. } = import "../lib/config.ncl" in
let config = import "locked-down.ncl" in

config | PorkgConfig

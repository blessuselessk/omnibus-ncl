# Export wrapper — validates nix-pipeline against PorkgConfig
# Usage: nickel export --format json porkg-ncl/examples/config-export.ncl
let { PorkgConfig, .. } = import "../lib/config.ncl" in
let config = import "nix-pipeline.ncl" in

config | PorkgConfig

# Export wrapper — validates full manifest against ApmManifest contract.
# Usage: nickel export --format json apm-ncl/examples/manifest-export.ncl
let { ApmManifest, .. } = import "../lib/manifest.ncl" in
let manifest = import "full-manifest.ncl" in

manifest | ApmManifest

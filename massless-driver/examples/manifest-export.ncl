# Export wrapper — validates full-job and transforms to runtime manifest.
# Usage: nickel export --format json massless-driver/examples/manifest-export.ncl
let { Job, .. } = import "../lib/job.ncl" in
let B = import "../lib/builders.ncl" in
let job = import "full-job.ncl" in

let validated = job | Job in
B.to_manifest validated

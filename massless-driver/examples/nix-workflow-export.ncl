# Export wrapper — validates nix-job and transforms to Workflow.
# Usage: nickel export --format json massless-driver/examples/nix-workflow-export.ncl
let { Job, .. } = import "../lib/job.ncl" in
let { Workflow, .. } = import "../lib/workflow.ncl" in
let B = import "../lib/builders.ncl" in
let job = import "nix-job.ncl" in

let validated = job | Job in
B.to_workflow validated | Workflow

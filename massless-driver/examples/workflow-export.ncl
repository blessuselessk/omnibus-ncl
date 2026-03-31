# Export wrapper — validates full-job against Job contract,
# transforms to Workflow, and validates the output.
# Usage: nickel export --format json massless-driver/examples/workflow-export.ncl
let { Job, .. } = import "../lib/job.ncl" in
let { Workflow, .. } = import "../lib/workflow.ncl" in
let B = import "../lib/builders.ncl" in
let job = import "full-job.ncl" in

let validated = job | Job in
B.to_workflow validated | Workflow

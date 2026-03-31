# Export wrapper — macOS job → workflow JSON
# Usage: nickel export --format json massless-driver/examples/macos-workflow-export.ncl
let { Job, .. } = import "../lib/job.ncl" in
let { Workflow, .. } = import "../lib/workflow.ncl" in
let B = import "../lib/builders.ncl" in
let job = import "macos-job.ncl" in

let validated = job | Job in
B.to_workflow validated | Workflow

# Multi-arch build — same job on three different runners
#
# Uses massless-driver to define a build job, then generates
# three workflow variants for different platforms.
let B = import "../massless-driver/lib/builders.ncl" in
let R = import "../massless-driver/lib/runner.ncl" in
let { Job, .. } = import "../massless-driver/lib/job.ncl" in
let { Workflow, .. } = import "../massless-driver/lib/workflow.ncl" in

let base_job = {
  owner = "myorg",
  script = "scripts/build.sh",
  artifacts = { enabled = true, retention_days = 7 },
  secrets = {
    entries = [
      { name = "SIGNING_KEY" },
      { name = "DOCKER_TOKEN" },
    ],
  },
}
in

let mk_workflow = fun _name =>
  fun _runner =>
    let validated = (base_job & { name = _name, runner = _runner }) | Job in
    B.to_workflow validated | Workflow
in

{
  linux_x64 = mk_workflow "build-linux-x64" R.ubuntu_latest,
  linux_arm = mk_workflow "build-linux-arm" { label = "ubuntu-24.04-arm" },
  macos_arm = mk_workflow "build-macos-arm" R.macos_14,
}

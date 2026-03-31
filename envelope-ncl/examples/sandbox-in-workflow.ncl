# Sandbox-in-Workflow: a sandboxed process running on a GitHub Actions runner
#
# Layer 1 (outer): GHA workflow — ubuntu runner, full network, secrets
# Layer 2 (inner): nsjail sandbox — restricted network, read-only fs
#
# The sandbox can't exceed the workflow's constraints.
# The workflow provides the VM; the sandbox provides process isolation within it.
let A = import "../lib/adapters.ncl" in
let N = import "../lib/nesting.ncl" in

let workflow =
  A.from_workflow {
    name = "sandboxed-build",
    owner = "myorg",
    script = "run-sandboxed.sh",
    runner = { label = "ubuntu-latest" },
    secrets = { entries = [{ name = "NPM_TOKEN" }] },
    timeout_seconds = 600,
  }
in

let sandbox =
  A.from_sandbox
    "build-sandbox"
    'nsjail
    {
      network = { mode = 'localhost },
      fs = { mode = 'whitelist, allowed_paths = ["/tmp", "/workspace", "/nix"] },
      resources = {
        max_memory_mb = 512,
        max_cpu_seconds = 300,
        max_file_descriptors = 256,
        timeout_seconds = 500,
      },
      command = "npm run build",
      description = "Sandboxed npm build",
    }
in

N.nest workflow sandbox

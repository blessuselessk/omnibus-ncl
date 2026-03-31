# Tool-in-Sandbox: a codemode tool running inside an nsjail sandbox
#
# Layer 1 (outer): nsjail sandbox — denies network, read-only fs
# Layer 2 (inner): jq tool — processes JSON, no network needed
#
# The tool's constraints are clamped to not exceed the sandbox's.
let A = import "../lib/adapters.ncl" in
let N = import "../lib/nesting.ncl" in

let jq_tool =
  A.from_tool
    "jq"
    "Process JSON with jq expressions"
    {
      type = "object",
      properties = {
        expression = { type = "string", description = "jq filter expression" },
        input = { type = "string", description = "JSON input" },
      },
      required = ["expression", "input"],
    }
in

let sandbox =
  A.from_sandbox
    "jq-sandbox"
    'nsjail
    {
      network = { mode = 'deny },
      fs = { mode = 'ro, allowed_paths = ["/tmp", "/nix"] },
      resources = {
        max_memory_mb = 64,
        max_cpu_seconds = 10,
        max_file_descriptors = 32,
        timeout_seconds = 30,
      },
      command = "jq",
      description = "Sandboxed jq execution",
    }
in

N.nest sandbox jq_tool

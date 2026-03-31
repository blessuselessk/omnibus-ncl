# Three-Layer Nesting: tool → sandbox → workflow
#
# Layer 1 (outermost): GHA workflow on macos-14, with secrets
# Layer 2 (middle): seatbelt sandbox, restricted fs and network
# Layer 3 (innermost): nix tool (jq), strict constraints
#
# Each inner layer's constraints are clamped by its parent.
# The jq tool ends up with the intersection of all three layers' permissions.
let A = import "../lib/adapters.ncl" in
let N = import "../lib/nesting.ncl" in

# Layer 3: the tool itself
let tool =
  A.from_nix_tool
    "jq"
    {
      flakeRef = "nixpkgs#jq",
      securityLevel = "strict",
      description = "Process JSON with jq",
    }
in

# Layer 2: sandbox wrapping the tool
let sandbox =
  A.from_sandbox
    "macos-sandbox"
    'seatbelt
    {
      network = { mode = 'deny },
      fs = { mode = 'ro, allowed_paths = ["/tmp", "/nix", "/usr/bin"] },
      resources = {
        max_memory_mb = 128,
        max_cpu_seconds = 30,
        max_file_descriptors = 64,
        timeout_seconds = 60,
      },
      description = "Seatbelt sandbox for macOS",
    }
in

# Layer 1: workflow wrapping the sandbox
let workflow =
  A.from_workflow {
    name = "sandboxed-jq",
    owner = "myorg",
    runner = { label = "macos-14" },
    timeout_seconds = 120,
  }
in

# Compose: tool inside sandbox inside workflow
let sandbox_with_tool = N.nest sandbox tool in
N.nest workflow sandbox_with_tool

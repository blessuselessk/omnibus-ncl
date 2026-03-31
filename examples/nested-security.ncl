# Nested security — show how constraints clamp at each layer
#
# A curl tool (needs network) nested inside a strict sandbox (denies network).
# The sandbox wins — inner constraints get clamped to the outer's.
# This demonstrates that you can't escalate permissions by nesting.
let A = import "../envelope-ncl/lib/adapters.ncl" in
let N = import "../envelope-ncl/lib/nesting.ncl" in

# curl wants full network access
let curl_tool =
  A.from_nix_tool
    "curl"
    {
      flakeRef = "nixpkgs#curl",
      securityLevel = "network",
      description = "Wants full network access",
      allowedHosts = ["api.github.com"],
    }
in

# But we put it in a strict sandbox — no network
let strict_sandbox =
  A.from_sandbox
    "lockdown"
    'nsjail
    {
      network = { mode = 'deny },
      fs = { mode = 'ro },
      resources = {
        max_memory_mb = 32,
        max_cpu_seconds = 5,
        max_file_descriptors = 16,
        timeout_seconds = 10,
      },
      description = "Maximum restriction sandbox",
    }
in

let nested = N.nest strict_sandbox curl_tool in

# Show what happened to curl's permissions
{
  before_nesting = {
    curl_requested = {
      network = "full",
      memory_mb = 256,
      timeout = 300,
    },
  },
  after_nesting = {
    curl_got = {
      network = nested.inner.constraints.network.mode,
      memory_mb = nested.inner.constraints.resources.max_memory_mb,
      timeout = nested.inner.constraints.resources.timeout_seconds,
    },
  },
  verdict = "curl wanted full network but got deny — sandbox wins",
}

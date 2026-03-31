# Sandboxed tool server — three nix tools with different security levels
#
# Each tool runs in an envelope with constraints matching its needs:
# - jq: strict (no network, read-only, 64MB, 10s)
# - curl: network allowed (needs outbound HTTP)
# - pandoc: io allowed (needs to write output files)
#
# Export produces a process-compose config where each tool is a
# sandboxed process, ready to accept input via stdin.
let A = import "../envelope-ncl/lib/adapters.ncl" in
let N = import "../envelope-ncl/lib/nesting.ncl" in
let bridge = import "../process-compose-ncl/lib/bridge.ncl" in

let jq_envelope =
  A.from_nix_tool
    "jq"
    {
      flakeRef = "nixpkgs#jq",
      securityLevel = "strict",
      description = "Process JSON — no network, read-only, minimal resources",
    }
in

let curl_envelope =
  A.from_nix_tool
    "curl"
    {
      flakeRef = "nixpkgs#curl",
      securityLevel = "network",
      description = "HTTP client — outbound network, read-only filesystem",
      allowedHosts = ["api.github.com", "registry.npmjs.org"],
    }
in

let pandoc_envelope =
  A.from_nix_tool
    "pandoc"
    {
      flakeRef = "nixpkgs#pandoc",
      securityLevel = "io",
      description = "Document converter — filesystem write, no network",
      allowedPaths = ["/tmp/pandoc-work", "/tmp/output"],
    }
in

# Show what each tool's constraints look like
{
  tools = {
    jq = jq_envelope,
    curl = curl_envelope,
    pandoc = pandoc_envelope,
  },
  summary = {
    jq = {
      network = jq_envelope.constraints.network.mode,
      fs = jq_envelope.constraints.fs.mode,
      memory_mb = jq_envelope.constraints.resources.max_memory_mb,
    },
    curl = {
      network = curl_envelope.constraints.network.mode,
      fs = curl_envelope.constraints.fs.mode,
      memory_mb = curl_envelope.constraints.resources.max_memory_mb,
      allowed_hosts = curl_envelope.constraints.network.allowed_hosts,
    },
    pandoc = {
      network = pandoc_envelope.constraints.network.mode,
      fs = pandoc_envelope.constraints.fs.mode,
      memory_mb = pandoc_envelope.constraints.resources.max_memory_mb,
      allowed_paths = pandoc_envelope.constraints.fs.allowed_paths,
    },
  },
}

# apm-ncl — Nickel contracts for Microsoft's Agent Package Manager (APM)
#
# Models the apm.yml manifest and apm.lock.yaml lockfile schemas,
# including dependencies (APM + MCP), compilation config, and lock entries.
{
  lib = import "lib/main.ncl",
  manifest = import "examples/full-manifest.ncl",
  lockfile = import "examples/lockfile-example.ncl",
}

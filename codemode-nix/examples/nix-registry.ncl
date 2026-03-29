# Full Nix tool registry — includes sandbox config for each tool.
# Consumed by nix-tool-runner.sh to resolve, sandbox, and execute tools.
# Usage: nickel export --format json codemode-nix/examples/nix-registry.ncl
let SB = import "../lib/sandbox.ncl" in
let tools = import "nix-tools.ncl" in

std.record.map (fun name tool => SB.registry_entry name tool) tools

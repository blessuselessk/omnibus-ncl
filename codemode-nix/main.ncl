# codemode-nix — Nix packages as LLM-callable tools with sandbox enforcement
#
# Defines a tool registry where each tool is a Nix flake reference
# with an LLM-facing schema and a security level that maps to a
# sandbox profile (seatbelt on macOS, nsjail on Linux).
#
# Usage:
#   nickel export --format json codemode-nix/examples/nix-tools-export.ncl  # LLM-facing schemas
#   nickel export --format json codemode-nix/examples/nix-registry.ncl      # Full registry with sandbox
{
  lib = import "lib/main.ncl",
  nix_tools = import "examples/nix-tools.ncl",
  provider_config = import "examples/provider-config.ncl",
}

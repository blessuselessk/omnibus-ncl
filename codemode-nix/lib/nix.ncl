# Nix tool aspect contracts — the nix.* namespace
#
# Each tool maps a Nix flake reference to an LLM-callable tool
# with input schema, security level, and sandbox enforcement.
let { JsonSchema, .. } = import "schema.ncl" in
let { SecurityLevel, .. } = import "security.ncl" in

{
  FlakeRef
    | doc "A Nix flake reference (e.g., 'nixpkgs#ripgrep', 'github:owner/repo#pkg')"
    | not_exported
    =
      std.contract.from_predicate (fun val =>
        std.is_string val
        && std.string.length val > 0
        && std.string.is_match "^[a-zA-Z0-9_./:+-]+#[a-zA-Z0-9._-]+$" val
      ),

  NixToolDescriptor
    | doc m%"
      A single Nix tool exposed to the LLM.
      Combines the tool's LLM-facing schema with its Nix resolution
      and sandbox security configuration.
    "%
    | not_exported
    = {
      description | String,
      flakeRef | FlakeRef,
      inputSchema | JsonSchema,
      outputSchema | JsonSchema | optional,
      securityLevel | SecurityLevel,
      allowedPaths | Array String | optional,
      allowedHosts | Array String | optional,
      timeout | Number | optional,
      env | { _ : String } | optional,
    },

  NixToolSet
    | doc "Record of Nix tool descriptors keyed by tool name"
    | not_exported
    = { _ : NixToolDescriptor },

  NixAspectConfig
    | doc m%"
      Configuration for the nix aspect.
      Fits into the multi-aspect pattern alongside state.*, git.*.
    "%
    | not_exported
    = {
      name | String | default = "nix",
      positionalArgs | Bool | default = false,
      tools | NixToolSet,
    },
}

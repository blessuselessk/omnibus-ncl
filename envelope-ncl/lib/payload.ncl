# Payload — what a runtime envelope executes
#
# The payload is the "what" — a script, a flake reference, a tool
# invocation, or an opaque reference to another system's definition.
{
  PayloadKind
    | doc "Discriminator for payload type"
    | not_exported
    = [| 'script, 'nix_flake, 'tool, 'mcp_tool, 'workflow, 'reference |],

  Payload
    | doc m%"
      Execution payload — what the envelope runs.

      Use `kind` to discriminate, then the corresponding field
      carries the specific payload data.

      # Examples

      ```nickel
      ({ kind = 'script, script = "echo hello" } | Payload)
      ({ kind = 'nix_flake, flake_ref = "nixpkgs#jq" } | Payload)
      ({ kind = 'tool, tool_name = "add", input_schema = { type = "object" } } | Payload)
      ```
    "%
    | not_exported
    = {
      kind
        | doc "Payload type discriminator"
        | PayloadKind,
      script
        | doc "Shell script content or path (when kind = 'script)"
        | String
        | optional,
      flake_ref
        | doc "Nix flake reference (when kind = 'nix_flake)"
        | String
        | optional,
      tool_name
        | doc "Tool name for codemode tools (when kind = 'tool or 'mcp_tool)"
        | String
        | optional,
      input_schema
        | doc "JSON Schema for tool input (when kind = 'tool or 'mcp_tool)"
        | { .. }
        | optional,
      description
        | doc "Human-readable description of what this payload does"
        | String
        | optional,
      ref
        | doc "Opaque reference to external definition (when kind = 'reference)"
        | String
        | optional,
    },
}

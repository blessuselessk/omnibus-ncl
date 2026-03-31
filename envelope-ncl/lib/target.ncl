# Target — where a runtime envelope executes
#
# The target is the "where" — local sandbox, GitHub Actions runner,
# MCP server, or a generic remote executor.
{
  TargetKind
    | doc "Discriminator for execution target"
    | not_exported
    = [| 'local, 'sandbox, 'workflow, 'mcp_server |],

  Target
    | doc m%"
      Execution target — where the envelope runs.

      # Examples

      ```nickel
      ({ kind = 'sandbox, sandbox_backend = 'nsjail } | Target)
      ({ kind = 'workflow, runner_label = "ubuntu-latest" } | Target)
      ({ kind = 'mcp_server, server_name = "demo-tools" } | Target)
      ```
    "%
    | not_exported
    = {
      kind
        | doc "Target type discriminator"
        | TargetKind,
      sandbox_backend
        | doc "Sandbox backend (when kind = 'sandbox)"
        | [| 'nsjail, 'seatbelt, 'hyperlight |]
        | optional,
      runner_label
        | doc "GitHub Actions runner label (when kind = 'workflow)"
        | String
        | optional,
      server_name
        | doc "MCP server name (when kind = 'mcp_server)"
        | String
        | optional,
    },
}

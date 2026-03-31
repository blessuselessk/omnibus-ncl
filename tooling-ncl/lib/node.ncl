# CodeNode — a typed box for arbitrary code execution
#
# Fields are progressive — start with just a name, iterate toward
# a complete definition. Use `diagnose` to see what's missing.
{
  Lang
    | doc "Supported code languages"
    | not_exported
    = [| 'bash, 'nickel, 'nushell, 'python, 'javascript |],

  CodeNode
    | doc m%"
      A typed box for code execution.

      Only `name` is required. Everything else can be filled in
      incrementally — use diagnose to see what's missing and what
      completeness percentage you're at.

      # Examples

      ```nickel
      # Minimal — just a name
      ({ name = "filter" } | CodeNode)

      # Partial — name + code
      ({ name = "filter", lang = 'bash, code = "jq '.name'" } | CodeNode)

      # Complete — all fields specified
      ({
        name = "filter",
        lang = 'bash,
        code = "jq '.name'",
        input_schema = { type = 'object },
        output_schema = { type = 'string },
        description = "Extract name field",
        constraints = { network = { mode = 'deny }, fs = { mode = 'ro } },
      } | CodeNode)
      ```
    "%
    | not_exported
    = {
      name
        | doc "Node identifier (required)"
        | String,
      lang
        | doc "Code language"
        | Lang
        | optional,
      code
        | doc "The code to execute"
        | String
        | optional,
      input_schema
        | doc "JSON Schema for what the node accepts"
        | { .. }
        | optional,
      output_schema
        | doc "JSON Schema for what the node produces"
        | { .. }
        | optional,
      description
        | doc "What this node does"
        | String
        | optional,
      constraints
        | doc "Runtime constraints (network, fs, resources, secrets)"
        | {
          network
            | { mode | [| 'deny, 'localhost, 'whitelist, 'full |] | default = 'deny, .. }
            | default
            = {},
          fs
            | { mode | [| 'none, 'ro, 'whitelist, 'rw |] | default = 'ro, .. }
            | default
            = {},
          resources
            | {
              max_memory_mb | Number | default = 256,
              max_cpu_seconds | Number | default = 60,
              timeout_seconds | Number | default = 300,
              ..
            }
            | default
            = {},
          secrets | Array String | default = [],
          ..
        }
        | optional,
      env
        | doc "Environment variables to set"
        | { _ : String }
        | optional,
    },
}

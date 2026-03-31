# CodeNode — a typed box for arbitrary code execution
#
# A CodeNode has:
#   - code: what to run (a string in some language)
#   - input/output schemas: what goes in, what comes out
#   - constraints: what the code can touch (network, fs, resources)
#   - lang: what language the code is in
#
# Composition: nodeA.output_schema must be compatible with nodeB.input_schema.
{
  Lang
    | doc "Supported code languages"
    | not_exported
    = [| 'bash, 'nickel, 'nushell, 'python, 'javascript |],

  CodeNode
    | doc m%"
      A typed box for code execution.

      The code string runs in the specified language, receives input
      matching input_schema, and must produce output matching output_schema.
      Constraints control what the code can touch at runtime.

      # Examples

      ```nickel
      ({
        name = "parse-json",
        lang = 'bash,
        code = "jq '.name' < input.json",
        input_schema = { type = "object", properties = { file = { type = "string" } } },
        output_schema = { type = "string" },
      } | CodeNode)
      ```
    "%
    | not_exported
    = {
      name
        | doc "Node identifier"
        | String,
      lang
        | doc "Code language"
        | Lang,
      code
        | doc "The code to execute — a string in the specified language"
        | String,
      input_schema
        | doc "JSON Schema for what the node accepts"
        | { .. }
        | default
        = { type = "object" },
      output_schema
        | doc "JSON Schema for what the node produces"
        | { .. }
        | default
        = { type = "object" },
      description
        | doc "What this node does"
        | String
        | optional,
      constraints
        | doc m%"
          Runtime constraints (from envelope-ncl vocabulary).
          Controls network, filesystem, resources, secrets.
        "%
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
        | default
        = {},
      env
        | doc "Environment variables to set"
        | { _ : String }
        | default
        = {},
    },
}

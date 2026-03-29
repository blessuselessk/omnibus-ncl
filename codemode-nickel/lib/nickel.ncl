# Nickel tool provider contracts — the nickel.* namespace
#
# Models the custom tool provider for Nickel operations:
# export, validate, format, typecheck, query.
# These run on the host (not sandbox) since they invoke the nickel CLI.
let { JsonSchema, .. } = import "schema.ncl" in

{
  ExportFormat
    | doc "Valid nickel export formats"
    | not_exported
    =
      std.contract.from_predicate (fun val =>
        std.is_string val
        && std.array.elem val ["json", "yaml", "toml", "text"]
      ),

  NickelToolDescriptor
    | doc "A single nickel.* tool"
    | not_exported
    = {
      description | String,
      inputSchema | JsonSchema,
    },

  NickelToolSet
    | doc "Record of nickel tool descriptors"
    | not_exported
    = { _ : NickelToolDescriptor },

  NickelProviderConfig
    | doc m%"
      Configuration for the nickel ToolProvider.
      Tools invoke the nickel CLI on the host side.
    "%
    | not_exported
    = {
      name | String | default = "nickel",
      positionalArgs | Bool | default = false,
      tools | NickelToolSet,
    },
}

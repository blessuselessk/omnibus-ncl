# Tool descriptor contracts — models JsonSchemaToolDescriptor(s) from @cloudflare/codemode
let { JsonSchema, .. } = import "schema.ncl" in

{
  ToolDescriptor
    | doc m%"
      A single tool descriptor: description + inputSchema + optional outputSchema.
      Maps to `JsonSchemaToolDescriptor` from `@cloudflare/codemode`.
    "%
    | not_exported
    = {
      description | String | optional,
      inputSchema | JsonSchema,
      outputSchema | JsonSchema | optional,
    },

  ToolSet
    | doc m%"
      A record of tool descriptors keyed by tool name.
      Maps to `JsonSchemaToolDescriptors` (Record<string, JsonSchemaToolDescriptor>).
    "%
    | not_exported
    = { _ : ToolDescriptor },

  ProviderConfig
    | doc m%"
      Provider configuration for codemode tool namespacing.
      Maps to `ToolProvider` from `@cloudflare/codemode`.
    "%
    | not_exported
    = {
      name | String | optional,
      positionalArgs | Bool | optional,
    },
}

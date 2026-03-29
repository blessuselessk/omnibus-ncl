# MCP tool and server contracts
#
# Models McpServer tool registration and the codeMcpServer() wrapper
# from @cloudflare/codemode/mcp.
let { JsonSchema, .. } = import "schema.ncl" in

{
  McpToolDescriptor
    | doc m%"
      A single MCP tool as registered with server.registerTool().
      Has description and inputSchema (JSON Schema for the tool's parameters).
    "%
    | not_exported
    = {
      description | String,
      inputSchema | JsonSchema,
    },

  McpToolSet
    | doc "Record of MCP tool descriptors keyed by tool name"
    | not_exported
    = { _ : McpToolDescriptor },

  McpServerConfig
    | doc m%"
      Configuration for `new McpServer({ name, version })`.
    "%
    | not_exported
    = {
      name | String,
      version | String | default = "1.0.0",
    },

  CodeMcpServerConfig
    | doc m%"
      Full configuration for codeMcpServer() — server metadata + tools.
      The executor and transport are runtime concerns not modeled here.
    "%
    | not_exported
    = {
      server | McpServerConfig,
      tools | McpToolSet,
    },
}

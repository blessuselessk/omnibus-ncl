# Full codeMcpServer config — server metadata + tools.
# Models the complete configuration for wrapping an MCP server with codemode.
# Usage: nickel export --format json codemode-mcp/examples/server-config.ncl
let { CodeMcpServerConfig, .. } = import "../lib/mcp.ncl" in

{
  server = {
    name = "demo-tools",
    version = "1.0.0",
  },
  tools = import "demo-tools.ncl",
}
  | CodeMcpServerConfig

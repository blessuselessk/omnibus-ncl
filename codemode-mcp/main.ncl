# codemode-mcp — Nickel contracts for MCP tool wrapping via codeMcpServer()
#
# Models the pattern from @cloudflare/codemode/mcp where an MCP server's
# tools are wrapped into a single `code` tool for LLM code execution.
{
  lib = import "lib/main.ncl",
  demo_tools = import "examples/demo-tools.ncl",
  server_config = import "examples/server-config.ncl",
}

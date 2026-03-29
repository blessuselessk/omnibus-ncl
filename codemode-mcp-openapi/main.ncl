# codemode-mcp-openapi — Nickel contracts for MCP tool wrapping and OpenAPI→MCP
#
# Models two patterns from @cloudflare/codemode/mcp:
#   1. codeMcpServer()    — wrap MCP tools with a single code tool
#   2. openApiMcpServer() — wrap OpenAPI specs as search + execute tools
{
  lib = import "lib/main.ncl",
  mcp_tools = import "examples/mcp-tools.ncl",
  mcp_server = import "examples/mcp-server.ncl",
  openapi_server = import "examples/openapi-server.ncl",
  request_examples = import "examples/request-examples.ncl",
}

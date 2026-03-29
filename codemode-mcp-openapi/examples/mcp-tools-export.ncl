# Export wrapper — validates MCP tools against McpToolSet contract.
# Usage: nickel export --format json codemode-mcp-openapi/examples/mcp-tools-export.ncl
let { McpToolSet, .. } = import "../lib/mcp.ncl" in
let tools = import "mcp-tools.ncl" in

tools | McpToolSet

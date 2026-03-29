# Export wrapper — validates demo tools against McpToolSet contract.
# Usage: nickel export --format json codemode-mcp/examples/demo-tools-export.ncl
let { McpToolSet, .. } = import "../lib/mcp.ncl" in
let tools = import "demo-tools.ncl" in

tools | McpToolSet

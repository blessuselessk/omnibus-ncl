# Export wrapper — validates PM tools against ToolSet contract and exports as JSON.
# Usage: nickel export --format json codemode/examples/pm-tools-export.ncl
let { ToolSet, .. } = import "../lib/tool.ncl" in
let tools = import "pm-tools.ncl" in

tools | ToolSet

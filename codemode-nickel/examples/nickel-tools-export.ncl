# Export wrapper — validates nickel tools and exports as JsonSchemaToolDescriptors.
# Usage: nickel export --format json codemode-nickel/examples/nickel-tools-export.ncl
let { ToolSet, .. } = import "../lib/tool.ncl" in
let tools = import "nickel-tools.ncl" in

tools | ToolSet

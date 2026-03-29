# Base field builders from codemode-ncl + MCP-specific builders
let base = import "../_deps/codemode-ncl/lib/builders.ncl" in

base
& {
  mcp_tool
    | doc m%"
      Build an MCP tool descriptor from description and input schema.

      Example:
        mcp_tool "Add two numbers" (object_schema { a = number_field "First" } ["a"])
    "%
    | not_exported
    = fun desc =>
      fun input =>
        {
          description = desc,
          inputSchema = input,
        },
}

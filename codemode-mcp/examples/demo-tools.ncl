# MCP demo tools — Nickel replica of examples/codemode-mcp/src/server.ts
#
# Three tools: add, greet, list_items — registered with the upstream McpServer,
# then wrapped by codeMcpServer() into a single code tool.
let B = (import "../lib/builders.ncl") in

{
  add =
    B.mcp_tool
      "Add two numbers together"
      (
        B.object_schema
          {
            a = B.number_field "First number",
            b = B.number_field "Second number",
          }
          ["a", "b"]
      ),

  greet =
    B.mcp_tool
      "Generate a greeting message"
      (
        B.object_schema
          {
            name = B.string_field "Name to greet",
            language =
              B.enum_field
                "Language for the greeting"
                ["en", "es", "fr"],
          }
          ["name"]
      ),

  list_items =
    B.mcp_tool
      "List items with optional filtering"
      (
        B.object_schema
          {
            category = B.string_field "Filter by category",
            limit = B.number_field "Max items to return",
          }
          []
      ),
}

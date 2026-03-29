# Minimal single-tool example showing codemode-ncl usage.
# Usage: nickel export --format json codemode/examples/single-tool.ncl
let B = (import "../lib/builders.ncl") in
let { ToolSet, .. } = import "../lib/tool.ncl" in

{
  greet =
    B.tool
      "Greet a user by name"
      (
        B.object_schema
          {
            name = B.string_field "The user's name",
            greeting = B.string_field "Optional greeting prefix",
          }
          ["name"]
      ),
}
  | ToolSet

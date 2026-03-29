# codemode-ncl — Nickel contracts and builders for @cloudflare/codemode tool definitions
#
# Export as JSON to produce valid JsonSchemaToolDescriptors for
# generateTypesFromJsonSchema(). See examples/ for usage.
{
  lib = import "lib/main.ncl",
  pm_tools = import "examples/pm-tools.ncl",
}

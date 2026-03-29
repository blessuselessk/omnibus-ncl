# OpenAPI MCP server config — models the openApiMcpServer() call
# from examples/codemode-mcp-openapi/src/server.ts.
# Usage: nickel export --format json codemode-mcp-openapi/examples/openapi-server.ncl
let { OpenApiServerConfig, .. } = import "../lib/openapi.ncl" in

{
  name = "cloudflare",
  description = "This server wraps the Cloudflare API. Replace path parameters like {account_id} and {zone_id} with real values from a prior search or list call.",
  spec_url = "https://raw.githubusercontent.com/cloudflare/api-schemas/main/openapi.json",
}
  | OpenApiServerConfig

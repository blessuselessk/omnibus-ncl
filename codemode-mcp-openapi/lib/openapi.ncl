# OpenAPI MCP server contracts
#
# Models the openApiMcpServer() configuration from @cloudflare/codemode/mcp.
# The OpenAPI spec itself is not validated here (it's huge); we model the
# server config and the RequestOptions interface that the sandbox uses.
{
  HttpMethod
    | doc "Valid HTTP methods for API requests"
    | not_exported
    =
      std.contract.from_predicate (fun val =>
        std.is_string val
        && std.array.elem val ["GET", "POST", "PUT", "PATCH", "DELETE"]
      ),

  RequestOptions
    | doc m%"
      Options for the `codemode.request()` function available in the sandbox.
      Maps to `RequestOptions` from @cloudflare/codemode/mcp.

      Auth is handled on the host — the sandbox never sees tokens.
    "%
    | not_exported
    = {
      method | HttpMethod,
      path | String,
      query | { _ : Dyn } | optional,
      body | Dyn | optional,
      contentType | String | optional,
      rawBody | Bool | optional,
    },

  OpenApiServerConfig
    | doc m%"
      Configuration for openApiMcpServer().
      The `spec` field references the OpenAPI spec (not embedded in Nickel).
      The `request` callback is host-side code (not modeled in Nickel).
    "%
    | not_exported
    = {
      name | String | default = "openapi",
      version | String | default = "1.0.0",
      description | String | optional,
      spec_url | String | optional,
    },
}

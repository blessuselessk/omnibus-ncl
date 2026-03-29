# MCP builders from codemode-mcp-ncl (includes base from codemode-ncl) + OpenAPI builders
let mcp = import "../_deps/codemode-mcp-ncl/lib/builders.ncl" in

mcp
& {
  openapi_server
    | doc m%"
      Build an openApiMcpServer configuration.

      Example:
        openapi_server "cloudflare" "Cloudflare API" "https://...openapi.json"
    "%
    | not_exported
    = fun name =>
      fun desc =>
        fun spec_url =>
          {
            name = name,
            description = desc,
            spec_url = spec_url,
          },

  request
    | doc "Build a RequestOptions record for codemode.request()"
    | not_exported
    = fun method =>
      fun path =>
        {
          method = method,
          path = path,
        },

  request_with_body
    | doc "Build a RequestOptions with body"
    | not_exported
    = fun method =>
      fun path =>
        fun body =>
          {
            method = method,
            path = path,
            body = body,
          },
}

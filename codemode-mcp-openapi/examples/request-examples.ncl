# RequestOptions examples — models the codemode.request() calls
# that run in the sandbox. Validates against the RequestOptions contract.
# Usage: nickel export --format json codemode-mcp-openapi/examples/request-examples.ncl
let { RequestOptions, .. } = import "../lib/openapi.ncl" in

{
  list_zones =
    { method = "GET", path = "/zones" }
      | RequestOptions,

  create_dns_record =
    {
      method = "POST",
      path = "/zones/{zone_id}/dns_records",
      body = {
        type = "A",
        name = "example.com",
        content = "1.2.3.4",
        ttl = 3600,
      },
    }
      | RequestOptions,

  list_workers =
    {
      method = "GET",
      path = "/accounts/{account_id}/workers/scripts",
      query = { page = 1, per_page = 20 },
    }
      | RequestOptions,

  update_worker =
    {
      method = "PUT",
      path = "/accounts/{account_id}/workers/scripts/{script_name}",
      body = "addEventListener('fetch', e => e.respondWith(new Response('ok')))",
      contentType = "application/javascript",
      rawBody = true,
    }
      | RequestOptions,
}

# APM and MCP dependency contracts
#
# Models both string shorthand and object forms of dependencies
# used in apm.yml's `dependencies` and `devDependencies` sections.
{
  McpTransport
    | doc "MCP server transport protocol"
    | not_exported
    = [| 'stdio, 'sse, 'http, 'streamable-http |],

  McpPackageType
    | doc "Package manager for MCP server installation"
    | not_exported
    = [| 'npm, 'pypi, 'oci |],

  ApmDependencyObject
    | doc m%"
      Object form of an APM dependency.
      String form (`owner/repo[/path][#ref]`) is also valid but
      cannot be contract-checked beyond String.
    "%
    | not_exported
    = {
      git | String,
      path | String | optional,
      ref | String | optional,
      alias | String | optional,
      ..
    },

  ApmDependency
    | doc "An APM dependency — either a string shorthand or an object"
    | not_exported
    = std.contract.any_of [ String, ApmDependencyObject],

  McpDependencyObject
    | doc m%"
      Object form of an MCP server dependency.
      Covers stdio, SSE, HTTP, and streamable-http transports.
    "%
    | not_exported
    = {
      name | String,
      transport | McpTransport | optional,
      env | { _ : String } | optional,
      args | Dyn | optional,
      version | String | optional,
      registry | Dyn | optional,
      package | McpPackageType | optional,
      headers | { _ : String } | optional,
      tools | Array String | optional,
      url | String | optional,
      command | String | optional,
      ..
    },

  McpDependency
    | doc "An MCP dependency — either a string shorthand or an object"
    | not_exported
    = std.contract.any_of [ String, McpDependencyObject],

  DependencySet
    | doc m%"
      A set of dependencies with separate APM and MCP lists.
      Used for both `dependencies` and `devDependencies`.
    "%
    | not_exported
    = {
      apm | Array ApmDependency | optional,
      mcp | Array McpDependency | optional,
      ..
    },
}

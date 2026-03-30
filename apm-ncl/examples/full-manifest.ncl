# Full APM manifest — exercises every field in the schema
#
# Demonstrates object-form dependencies, MCP servers, compilation,
# scripts, and devDependencies.
let B = import "../lib/builders.ncl" in

B.manifest_full
  "acme-support-agent"
  "2.1.0"
  "Production support agent with tool integrations"
  "acme-corp"
  "MIT"
& {
  target = 'claude,
  type = 'hybrid,

  scripts = {
    build = "apm compile",
    test = "apm validate",
    lint = "apm lint --fix",
  },

  dependencies = {
    apm = [
      "anthropics/courses",
      "acme-corp/shared-prompts#v1.2.0",
      B.apm_dep_ref "https://github.com/acme-corp/internal-tools.git" "main"
      & { path = "packages/agent-tools", alias = "tools" },
    ],
    mcp = [
      "@anthropic/mcp-github",
      B.mcp_dep "custom-db-server" 'stdio
      & {
        command = "npx",
        args = ["-y", "@acme/db-mcp-server"],
        env = {
          DB_HOST = "localhost",
          DB_PORT = "5432",
        },
        tools = ["query", "list_tables", "describe_table"],
      },
      {
        name = "api-gateway",
        transport = 'streamable-http,
        url = "https://mcp.acme.internal/v1",
        headers = {
          Authorization = "Bearer ${API_TOKEN}",
        },
        tools = ["search", "create_ticket"],
      },
    ],
  },

  devDependencies = {
    apm = [
      "anthropics/prompt-testing",
    ],
    mcp = [
      "@anthropic/mcp-inspector",
    ],
  },

  compilation = {
    target = 'claude,
    strategy = 'single-file,
    output = "AGENTS.md",
    resolve_links = true,
    source_attribution = true,
    exclude = [
      "tests/**",
      "*.test.md",
    ],
    placement = {
      min_instructions_per_file = 3,
    },
  },
}

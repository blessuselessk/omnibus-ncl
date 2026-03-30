# Sample APM lockfile — demonstrates the apm.lock.yaml schema
#
# Pins two APM dependencies and one MCP server reference.
let B = import "../lib/builders.ncl" in
let { ApmLockfile, .. } = import "../lib/lockfile.ncl" in

{
  lockfile_version = "1",
  generated_at = "2026-03-29T12:00:00Z",
  apm_version = "0.2.5",
  dependencies = [
    B.lock_entry
      "https://github.com/anthropics/courses"
      "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2"
      "main"
      "1.0.0"
      "instructions"
      "sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
      ["AGENTS.md", "prompts/core.md"],
    B.lock_entry
      "https://github.com/acme-corp/internal-tools"
      "f6e5d4c3b2a1f6e5d4c3b2a1f6e5d4c3b2a1f6e5"
      "main"
      "2.0.0"
      "skill"
      "sha256:d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"
      ["packages/agent-tools/AGENTS.md"]
    & {
      virtual_path = "packages/agent-tools",
      is_virtual = true,
    },
  ],
  mcp_servers = [
    "@anthropic/mcp-github",
    "@anthropic/mcp-inspector",
  ],
}
  | ApmLockfile

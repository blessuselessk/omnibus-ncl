# codemode-nickel — tool definitions for a Nickel project generator agent
#
# An LLM agent that creates Nickel projects using:
#   state.* — filesystem operations (from @cloudflare/shell)
#   nickel.* — Nickel CLI tools (export, validate, format, typecheck, query, eval)
#
# The agent reads Nickel style guides, plans a project structure,
# writes .ncl files, validates them, and exports the result.
{
  lib = import "lib/main.ncl",
  nickel_tools = import "examples/nickel-tools.ncl",
  sample_project = import "examples/sample-project.ncl",
  provider_config = import "examples/provider-config.ncl",
}

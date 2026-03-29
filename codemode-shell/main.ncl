# codemode-shell — Nickel contracts for @cloudflare/shell tool providers
#
# Models the stateTools() and gitTools() ToolProviders from @cloudflare/shell,
# including the multi-provider pattern for wiring them into codemode executors.
{
  lib = import "lib/main.ncl",
  state_tools = import "examples/state-tools.ncl",
  git_tools = import "examples/git-tools.ncl",
  workspace_config = import "examples/workspace-config.ncl",
  multi_provider = import "examples/multi-provider.ncl",
}

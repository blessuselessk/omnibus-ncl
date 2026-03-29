# Multi-provider pattern — models how stateTools + gitTools wire into codemode
#
# In the workspace-chat example, multiple ToolProviders are passed to
# createCodeTool or executor.execute as an array of ResolvedProviders.
# Each provider has its own namespace (state.*, git.*, codemode.*).
let { ToolSet, .. } = import "tool.ncl" in
let { StateProviderConfig, .. } = import "state.ncl" in
let { GitProviderConfig, .. } = import "git.ncl" in

{
  ProviderKind
    | doc "Known provider namespace kinds"
    | not_exported
    =
      std.contract.from_predicate (fun val =>
        std.is_string val
        && std.array.elem val ["codemode", "state", "git"]
      ),

  MultiProviderConfig
    | doc m%"
      Configuration for a codemode executor with multiple tool providers.
      Models the pattern: createCodeTool({ tools: [...providers], executor })
    "%
    | not_exported
    = {
      providers | Array { name | String, positionalArgs | Bool | optional, .. },
    },
}

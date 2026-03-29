# Multi-provider pattern — models how workspace-chat wires state + git + codemode
#
# This is the configuration shape for executor.execute(code, providers) where
# multiple tool providers are passed as an array.
let { MultiProviderConfig, .. } = import "../lib/provider.ncl" in

{
  providers = [
    {
      name = "codemode",
      positionalArgs = false,
    },
    {
      name = "state",
      positionalArgs = true,
    },
    {
      name = "git",
      positionalArgs = true,
    },
  ],
}
  | MultiProviderConfig

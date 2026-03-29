# Workspace configuration contracts — models Workspace constructor options
{
  WorkspaceConfig
    | doc m%"
      Configuration for `new Workspace(options)`.
      The sql field is a runtime binding (not modeled in Nickel).
    "%
    | not_exported
    = {
      namespace | String | default = "default",
      inlineThreshold | Number | optional,
      r2Prefix | String | optional,
      name | String | optional,
    },
}

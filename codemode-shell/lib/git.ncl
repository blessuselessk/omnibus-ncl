# Git tool contracts — models gitTools() from @cloudflare/shell/git
#
# 14 git commands. Uses positionalArgs: true like state tools.
{
  GitAuthor
    | doc "Git commit author"
    | not_exported
    = {
      name | String,
      email | String,
    },

  GitToolDescriptor
    | doc "A single git tool"
    | not_exported
    = {
      description | String,
      params | Array String | optional,
      category | String | optional,
    },

  GitToolSet
    | doc "Record of git tool descriptors keyed by command name"
    | not_exported
    = { _ : GitToolDescriptor },

  GitToolsOptions
    | doc "Options for gitTools() factory"
    | not_exported
    = {
      dir | String | optional,
      token | String | optional,
    },

  GitProviderConfig
    | doc m%"
      Configuration for the git ToolProvider.
      Maps to the return value of gitTools(workspace).
    "%
    | not_exported
    = {
      name | String | default = "git",
      positionalArgs | Bool | default = true,
      tools | GitToolSet,
    },
}

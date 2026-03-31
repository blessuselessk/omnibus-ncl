# Skill — injectable capabilities for hats
#
# Skills are markdown-based instructions that get injected into
# the agent prompt. Can be built-in or user-defined.
{
  Skill
    | doc m%"
      A skill injected into agent prompts.

      Skills add capabilities — memory management, task tracking,
      tool usage instructions, or domain-specific knowledge.

      # Examples

      ```nickel
      ({
        name = "nickel-tools",
        description = "How to use nickel export, validate, and format",
        content = "## Nickel Tools\n\nUse `nickel export --format json` to...",
        tags = ["nickel", "tooling"],
      } | Skill)
      ```
    "%
    | not_exported
    = {
      name | String,
      description | String,
      content
        | doc "Markdown content injected into prompt"
        | String,
      tags
        | doc "Tags for filtering and discovery"
        | Array String
        | default
        = [],
      visibility
        | doc "Which hats can see this skill (empty = all)"
        | Array String
        | default
        = [],
    },
}

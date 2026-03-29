# Multi-provider config — how the Nickel project agent wires its tools
#
# Three providers:
#   state.* — filesystem (read/write .ncl files, mkdir, glob)
#   nickel.* — Nickel CLI operations (export, validate, format, query)
#   git.* — version control (optional, for committing generated projects)
{
  providers = [
    {
      name = "state",
      positionalArgs = true,
    },
    {
      name = "nickel",
      positionalArgs = false,
    },
    {
      name = "git",
      positionalArgs = true,
    },
  ],
}

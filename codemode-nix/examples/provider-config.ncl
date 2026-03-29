# Agent aspects — namespaced tool groups
# Adds "nix" as an aspect alongside state and git
{
  aspects = [
    { name = "state", positionalArgs = true },
    { name = "nix", positionalArgs = false },
    { name = "git", positionalArgs = true },
  ],
}

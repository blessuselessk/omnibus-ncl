# prose-ncl — Nickel contracts for the PROSE specification's primitive types
#
# Models Agents, Instructions, Chatmodes, Prompts, Specs, Memories,
# Contexts, Skills, AgentsMd, and Workspaces for AI-native development.
# Includes the composability graph (valid edges, tiers, feedback loops).
{
  lib = import "lib/main.ncl",
  frontend_workspace = import "examples/frontend-workspace.ncl",
  single_skill = import "examples/single-skill.ncl",
  graph = import "examples/graph-export.ncl",
}

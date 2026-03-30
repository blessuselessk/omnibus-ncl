# PROSE primitive type contracts
#
# Models the PROSE specification primitives:
# Agent, Instruction, Chatmode, Prompt, Spec, Memory, Context, AgentsMd
#
# Each primitive has frontmatter (structured metadata) and a markdown body.
# Skill is defined separately in skill.ncl.
# The composability graph (valid/invalid edges) is in graph.ncl.
{
  PromptMode
    | doc "Prompt execution mode — agent, ask, or edit"
    | not_exported
    =
      std.contract.from_predicate (fun value =>
        value == 'agent || value == 'ask || value == 'edit
      ),

  Agent
    | doc m%"
      Role-based persona with bounded tool access (.agent.md).
      The top-level orchestrator in the composition hierarchy.
      Tier: active — can invoke, reference, produce, auto-load.
    "%
    | not_exported
    = {
      description
        | doc "What this agent persona does"
        | String,
      tools
        | doc "Available tool capabilities"
        | Array String
        | optional,
      handoffs
        | doc "Other agent files this agent can delegate to"
        | Array String
        | optional,
      mcp
        | doc "Required MCP servers for this agent"
        | Array String
        | optional,
      model
        | doc "Model override, e.g. \"Claude Sonnet 4\""
        | String
        | optional,
      body
        | doc "System prompt markdown for the agent"
        | String,
    },

  Instruction
    | doc m%"
      Scoped development instruction (.instructions.md).
      Applies rules to files matching a glob pattern.
    "%
    | not_exported
    = {
      apply_to
        | doc "Glob pattern for targeted files, e.g. \"**/*.{ts,tsx}\""
        | String,
      description
        | doc "Short summary of what this instruction enforces"
        | String,
      body
        | doc "Markdown content — the actual instruction text"
        | String,
    },

  Chatmode
    | doc m%"
      Custom chat mode (.chatmode.md).
      Configures a persona with specific tools and optional model override.
    "%
    | not_exported
    = {
      description
        | doc "What this chat mode does"
        | String,
      tools
        | doc "Available capabilities in this mode"
        | Array String,
      model
        | doc "Model override, e.g. \"Claude Sonnet 4\""
        | String
        | optional,
      body
        | doc "System prompt markdown for the chat mode"
        | String,
    },

  Prompt
    | doc m%"
      Reusable prompt template (.prompt.md).
      Supports parameterized input via ${input:param} placeholders.
      Per APM spec: focused, reusable, parameterized, testable.
    "%
    | not_exported
    = {
      description
        | doc "What this prompt does"
        | String,
      author
        | doc "Creator/maintainer identification"
        | String
        | optional,
      mode
        | doc "Execution mode"
        | PromptMode
        | optional,
      model
        | doc "Model override"
        | String
        | optional,
      tools
        | doc "Tools available during execution"
        | Array String
        | optional,
      mcp
        | doc "Required MCP servers for this prompt"
        | Array String
        | optional,
      input
        | doc "Parameter names for ${input:param} placeholders"
        | Array String
        | optional,
      body
        | doc "Markdown template body with optional ${input:param} placeholders"
        | String,
    },

  Spec
    | doc m%"
      Specification document (.spec.md).
      Structured markdown for problem definition, requirements,
      API contracts, and validation criteria.
    "%
    | not_exported
    = {
      title
        | doc "Specification title"
        | String,
      category
        | doc "Classification, e.g. \"feature\", \"architecture\""
        | String
        | optional,
      body
        | doc "Structured markdown with problem/requirements/API/validation sections"
        | String,
    },

  Memory
    | doc m%"
      Cross-session knowledge (.memory.md).
      Preserves learned context across assistant sessions.
    "%
    | not_exported
    = {
      title
        | doc "Memory entry title"
        | String,
      description
        | doc "Brief summary of what this memory contains"
        | String
        | optional,
      body
        | doc "Markdown content to persist"
        | String,
    },

  Context
    | doc m%"
      Strategic information retrieval (.context.md).
      Provides relevant project context on demand.
      Tier: passive — can only reference other context files.
    "%
    | not_exported
    = {
      title
        | doc "Context entry title"
        | String,
      description
        | doc "Brief summary of available context"
        | String
        | optional,
      body
        | doc "Markdown content for context retrieval"
        | String,
    },

  AgentsMd
    | doc m%"
      Compiled portable context (AGENTS.md).
      Produced by apm compile from instructions, context, and memory.
      Inherited by agents via directory tree walk — closest file wins.
      Tier: meta.
    "%
    | not_exported
    = {
      path
        | doc "Relative path where this AGENTS.md lives in the project tree"
        | String,
      body
        | doc "Compiled instruction content"
        | String,
    },
}

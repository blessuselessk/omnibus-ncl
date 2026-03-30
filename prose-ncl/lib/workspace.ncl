# PROSE Workspace contract
#
# Models the directory structure of a PROSE-enabled project.
# A workspace aggregates all primitive types into a single configuration.
# The composability graph (lib/graph.ncl) defines valid edges between them.
#
# Workspaces can declare explicit compositions — the wiring between
# primitives. The WiredWorkspace contract validates that every populated
# primitive type participates in at least one composition (no orphans).
let { Agent, Instruction, Chatmode, Prompt, Spec, Memory, Context, AgentsMd, .. } = import "primitives.ncl" in
let { Skill, .. } = import "skill.ncl" in
let G = import "graph.ncl" in

let
  # Collect which primitive types are populated (have at least one entry)
  populated_types = fun ws =>
    (if std.array.length ws.agents > 0 then ['agent] else [])
    @ (if std.array.length ws.instructions > 0 then ['instruction] else [])
    @ (if std.array.length ws.prompts > 0 then ['prompt] else [])
    @ (if std.array.length ws.specs > 0 then ['spec] else [])
    @ (if std.array.length ws.memories > 0 then ['memory] else [])
    @ (if std.array.length ws.contexts > 0 then ['context] else [])
    @ (if std.array.length ws.skills > 0 then ['skill] else [])
    @ (if std.array.length ws.agents_md > 0 then ['agents_md] else [])
in

let
  # Collect all primitive types that appear in any composition (from or to)
  wired_types = fun compositions =>
    let from_types = std.array.map (fun c => c.from) compositions in
    let to_types = std.array.map (fun c => c.to) compositions in
    from_types @ to_types
in

let
  # Check: every populated type appears in at least one composition
  all_types_wired = fun ws =>
    let populated = populated_types ws in
    let wired = wired_types ws.compositions in
    std.array.all
      (fun ptype => std.array.elem ptype wired)
      populated
in

{
  Workspace
    | doc m%"
      A PROSE workspace — the complete directory structure model.
      Aggregates all primitive types with optional root instructions.

      Primitives are organized into three tiers (see graph.ncl):
      - Active (agent, prompt): orchestrate execution, can invoke/produce
      - Passive (instruction, context, memory, spec): consumed by active
      - Meta (skill, agents_md): package or compile other primitives
    "%
    | not_exported
    = {
      root_instructions
        | doc "Path to copilot-instructions.md at project root"
        | String
        | optional,
      agents
        | doc "Role-based personas (active tier)"
        | Array Agent
        | default
        = [],
      instructions
        | doc "Scoped development instructions (passive tier)"
        | Array Instruction
        | default
        = [],
      chatmodes
        | doc "Custom chat mode definitions"
        | Array Chatmode
        | default
        = [],
      prompts
        | doc "Reusable prompt templates (active tier)"
        | Array Prompt
        | default
        = [],
      specs
        | doc "Specification documents (passive tier)"
        | Array Spec
        | default
        = [],
      memories
        | doc "Cross-session knowledge entries (passive tier)"
        | Array Memory
        | default
        = [],
      contexts
        | doc "Strategic context entries (passive tier)"
        | Array Context
        | default
        = [],
      skills
        | doc "Reusable capability packages (meta tier)"
        | Array Skill
        | default
        = [],
      agents_md
        | doc "Compiled AGENTS.md files (meta tier)"
        | Array AgentsMd
        | default
        = [],
      compositions
        | doc m%"
          Explicit wiring between primitives.
          Each edge is validated against the composability graph.
          Use WiredWorkspace to also enforce that no primitive type is orphaned.
        "%
        | Array G.ProposedEdge
        | default
        = [],
    },

  WiredWorkspace
    | doc m%"
      A Workspace with orphan detection.
      Every populated primitive type must appear in at least one composition.
      Compositions are validated against the composability graph.

      Usage:
        my_workspace | WiredWorkspace
    "%
    | not_exported
    =
      std.contract.from_predicate (fun ws =>
        # All compositions must be valid
        std.array.all
          (fun c =>
            G.is_direction_allowed c.from c.direction
            && !(G.matches_invalid_rule c.from c.to c.verb)
            && G.has_valid_edge c.from c.to c.direction
          )
          ws.compositions
        # Every populated type must be wired
        && all_types_wired ws
      ),
}

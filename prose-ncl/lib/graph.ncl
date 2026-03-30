# PROSE Composability Graph
#
# Encodes the valid directed edges between agent primitives,
# tier constraints, and feedback loops.
#
# Source: primitive-composability-schema.yaml
# If an edge isn't listed in valid_edges, it's invalid.
{
  PrimitiveType
    | doc "The eight PROSE primitive types"
    | not_exported
    =
      std.contract.from_predicate (fun value =>
        std.array.elem value [
          'agent,
          'instruction,
          'prompt,
          'context,
          'memory,
          'spec,
          'skill,
          'agents_md,
        ]
      ),

  Tier
    | doc "Three-tier classification: active orchestrates, passive is consumed, meta packages"
    | not_exported
    =
      std.contract.from_predicate (fun value =>
        value == 'active || value == 'passive || value == 'meta
      ),

  EdgeDirection
    | doc "How the edge is traversed at runtime"
    | not_exported
    =
      std.contract.from_predicate (fun value =>
        std.array.elem value [
          'invoke,
          'auto_load,
          'reference,
          'produce,
        ]
      ),

  Edge
    | doc "A valid directed edge between two primitive types"
    | not_exported
    = {
      from | PrimitiveType,
      to | PrimitiveType,
      verb | String,
      mechanism | String,
      direction | EdgeDirection,
      note | String | optional,
    },

  InvalidEdge
    | doc "A structurally invalid composition with reason"
    | not_exported
    = {
      from | PrimitiveType,
      to | Array PrimitiveType,
      verb | String,
      reason | String,
    },

  TierDef
    | doc "Tier definition with members and permitted directions"
    | not_exported
    = {
      members | Array PrimitiveType,
      can | Array EdgeDirection,
      cannot | Array EdgeDirection | optional,
      note | String,
    },

  FeedbackLoop
    | doc "A named cycle in the graph"
    | not_exported
    = {
      name | String,
      path | String,
      description | String,
    },

  # ──────────────────────────────────────────────
  # Tier definitions
  # ──────────────────────────────────────────────

  tiers
    | doc "The three-tier model governing what each primitive class can do"
    | not_exported
    = {
      active | TierDef = {
        members = ['agent, 'prompt],
        can = ['invoke, 'reference, 'produce, 'auto_load],
        note = "Active primitives orchestrate execution. Agents are top-level personas; prompts are the workflow layer.",
      },
      passive | TierDef = {
        members = ['instruction, 'context, 'memory, 'spec],
        can = ['reference],
        cannot = ['invoke, 'produce],
        note = "Passive primitives are consumed by active primitives. Exception: instruction compiles into agents_md at build time.",
      },
      meta | TierDef = {
        members = ['skill, 'agents_md],
        can = ['reference, 'auto_load],
        cannot = ['invoke],
        note = "Meta primitives package or compile other primitives. Skills are auto-discovered; AGENTS.md is inherited via tree walk.",
      },
    },

  # ──────────────────────────────────────────────
  # Valid edges
  # ──────────────────────────────────────────────

  valid_edges
    | doc "All valid directed edges between primitives"
    | not_exported
    | Array Edge
    = [
      # ── agent outbound ──
      {
        from = 'agent, to = 'agent,
        verb = "hands-off-to",
        mechanism = "handoffs: frontmatter field",
        direction = 'invoke,
        note = "Sequential delegation — agent A completes its phase, passes context to agent B.",
      },
      {
        from = 'agent, to = 'agent,
        verb = "spawns",
        mechanism = "agent/runSubagent tool",
        direction = 'invoke,
        note = "Parent-child — agent A creates a scoped subagent for a subtask. Concurrent.",
      },
      {
        from = 'agent, to = 'instruction,
        verb = "auto-loads",
        mechanism = "applyTo glob match on active files",
        direction = 'auto_load,
      },
      {
        from = 'agent, to = 'context,
        verb = "references",
        mechanism = "markdown links in body",
        direction = 'reference,
      },
      {
        from = 'agent, to = 'memory,
        verb = "reads",
        mechanism = "markdown links in body",
        direction = 'reference,
      },
      {
        from = 'agent, to = 'memory,
        verb = "updates",
        mechanism = "writes decisions after significant outcomes",
        direction = 'produce,
      },
      {
        from = 'agent, to = 'skill,
        verb = "auto-discovers",
        mechanism = "description match to current task",
        direction = 'auto_load,
      },
      {
        from = 'agent, to = 'agents_md,
        verb = "inherits",
        mechanism = "directory tree walk, closest file wins",
        direction = 'auto_load,
      },
      # ── prompt outbound ──
      {
        from = 'prompt, to = 'agent,
        verb = "activates",
        mechanism = "mode: or agent: frontmatter field",
        direction = 'invoke,
      },
      {
        from = 'prompt, to = 'context,
        verb = "references",
        mechanism = "markdown links in body",
        direction = 'reference,
      },
      {
        from = 'prompt, to = 'memory,
        verb = "reads",
        mechanism = "markdown links in body",
        direction = 'reference,
      },
      {
        from = 'prompt, to = 'memory,
        verb = "updates",
        mechanism = "learning integration phase output",
        direction = 'produce,
      },
      {
        from = 'prompt, to = 'spec,
        verb = "consumes",
        mechanism = "markdown links or ${specFile} parameter",
        direction = 'reference,
      },
      {
        from = 'prompt, to = 'spec,
        verb = "produces",
        mechanism = "specification workflow output",
        direction = 'produce,
      },
      {
        from = 'prompt, to = 'instruction,
        verb = "references",
        mechanism = "markdown links in body",
        direction = 'reference,
      },
      {
        from = 'prompt, to = 'instruction,
        verb = "updates",
        mechanism = "discovery-driven enhancement",
        direction = 'produce,
      },
      {
        from = 'prompt, to = 'prompt,
        verb = "chains-to",
        mechanism = "sequential invocation (human-mediated)",
        direction = 'invoke,
      },
      # ── instruction outbound ──
      {
        from = 'instruction, to = 'context,
        verb = "references",
        mechanism = "markdown links in body",
        direction = 'reference,
      },
      {
        from = 'instruction, to = 'memory,
        verb = "references",
        mechanism = "markdown links in body",
        direction = 'reference,
      },
      {
        from = 'instruction, to = 'agents_md,
        verb = "compiles-into",
        mechanism = "apm compile merges by applyTo group",
        direction = 'produce,
      },
      # ── context outbound ──
      {
        from = 'context, to = 'context,
        verb = "references",
        mechanism = "markdown cross-links",
        direction = 'reference,
      },
      # ── skill outbound ──
      {
        from = 'skill, to = 'context,
        verb = "references",
        mechanism = "links to references/ subdirectory",
        direction = 'reference,
      },
      # ── meta production ──
      {
        from = 'agents_md, to = 'agent,
        verb = "inherited-by",
        mechanism = "runtime directory tree walk",
        direction = 'auto_load,
      },
    ],

  # ──────────────────────────────────────────────
  # Invalid edges
  # ──────────────────────────────────────────────

  invalid_edges
    | doc "Structurally invalid compositions — an agent encountering these should refuse"
    | not_exported
    | Array InvalidEdge
    = [
      {
        from = 'instruction,
        to = ['agent, 'prompt, 'skill],
        verb = "invoke",
        reason = "Instructions are passive rules. They are injected via applyTo, never invoke anything.",
      },
      {
        from = 'context,
        to = ['agent, 'prompt, 'instruction, 'memory, 'spec, 'skill],
        verb = "invoke",
        reason = "Context is pure reference knowledge. No outbound edges except cross-references to other context.",
      },
      {
        from = 'memory,
        to = ['agent, 'prompt, 'instruction, 'context, 'spec, 'skill],
        verb = "invoke",
        reason = "Memory is pure state. Written to and read from, but never initiates action.",
      },
      {
        from = 'spec,
        to = ['agent, 'prompt, 'instruction, 'skill],
        verb = "invoke",
        reason = "Specs are blueprints consumed by prompts. They cannot invoke agents or trigger execution.",
      },
      {
        from = 'skill,
        to = ['prompt, 'instruction],
        verb = "invoke",
        reason = "Skills describe capabilities for auto-discovery. Agents mediate, not skills.",
      },
      {
        from = 'agent,
        to = ['spec],
        verb = "consumes",
        reason = "Agents do not directly consume specs. Prompts mediate the spec-to-agent path.",
      },
      {
        from = 'prompt,
        to = ['agent],
        verb = "hands-off-to",
        reason = "Only agents can declare handoffs. Prompts activate agents via mode/agent frontmatter.",
      },
    ],

  # ──────────────────────────────────────────────
  # Feedback loops
  # ──────────────────────────────────────────────

  feedback_loops
    | doc "The only two cycles in the graph — everything else is strictly top-down"
    | not_exported
    | Array FeedbackLoop
    = [
      {
        name = "learning",
        path = "prompt → memory → prompt",
        description = "Prompts update memory after execution. Future prompts read memory to avoid repeating mistakes. Human-mediated — same instance doesn't read its own writes.",
      },
      {
        name = "delegation",
        path = "agent → agent → agent",
        description = "Agents hand off to other agents via handoffs frontmatter or spawn subagents via tools. Enables specialization without monolithic personas.",
      },
    ],

  # ──────────────────────────────────────────────
  # Enforcement — library contracts
  #
  # These contracts validate proposed compositions
  # against the graph at export time.
  # ──────────────────────────────────────────────

  tier_of
    | doc m%"
      Lookup: primitive type → tier tag.
      Returns 'active, 'passive, or 'meta.
    "%
    | not_exported
    = fun ptype =>
      if std.array.elem ptype ['agent, 'prompt] then
        'active
      else if std.array.elem ptype ['instruction, 'context, 'memory, 'spec] then
        'passive
      else
        'meta,

  directions_for_tier
    | doc "Lookup: tier → allowed edge directions"
    | not_exported
    = fun tier =>
      if tier == 'active then
        ['invoke, 'reference, 'produce, 'auto_load]
      else if tier == 'passive then
        ['reference]
      else
        ['reference, 'auto_load],

  is_direction_allowed
    | doc "Check if a direction is permitted for a primitive's tier"
    | not_exported
    = fun ptype => fun dir =>
      let tier = tier_of ptype in
      let allowed = directions_for_tier tier in
      std.array.elem dir allowed,

  matches_invalid_rule
    | doc "Check if a proposed edge matches any invalid_edges rule"
    | not_exported
    = fun _from => fun _to => fun _verb =>
      std.array.any
        (fun rule =>
          rule.from == _from
          && std.array.elem _to rule.to
          && rule.verb == _verb
        )
        invalid_edges,

  has_valid_edge
    | doc "Check if a proposed edge exists in valid_edges"
    | not_exported
    = fun _from => fun _to => fun _direction =>
      std.array.any
        (fun edge =>
          edge.from == _from
          && edge.to == _to
          && edge.direction == _direction
        )
        valid_edges,

  ProposedEdge
    | doc m%"
      A proposed composition between two primitives.
      Use this to declare edges in your workspace.
    "%
    | not_exported
    = {
      from | PrimitiveType,
      to | PrimitiveType,
      direction | EdgeDirection,
      verb | String,
    },

  ValidComposition
    | doc m%"
      Contract for a proposed edge that enforces the composability graph.
      Validates:
      1. The direction is allowed for the source primitive's tier
      2. The edge doesn't match any invalid_edges rule
      3. A matching valid_edge exists in the graph

      Usage:
        { from = 'agent, to = 'instruction, direction = 'auto_load, verb = "auto-loads" }
          | ValidComposition
    "%
    | not_exported
    =
      std.contract.from_predicate (fun edge =>
        is_direction_allowed edge.from edge.direction
        && !(matches_invalid_rule edge.from edge.to edge.verb)
        && has_valid_edge edge.from edge.to edge.direction
      ),
}

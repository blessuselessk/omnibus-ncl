# Hat — agent persona with topic subscriptions
#
# Hats are specialized AI agent personas that coordinate through
# events. Each hat subscribes to topics, publishes to topics,
# and has custom instructions injected into its prompt.
{
  Backend
    | doc "AI backend for this hat"
    | not_exported
    = [| 'claude, 'gemini, 'codex, 'pi, 'kiro, 'amp, 'auto |],

  Hat
    | doc m%"
      Agent persona definition.

      Hats subscribe to event topics (glob patterns), publish events,
      and carry custom instructions that get injected into the AI prompt.

      # Examples

      ```nickel
      ({
        name = "planner",
        description = "Decomposes tasks into sub-tasks",
        subscriptions = ["task.start", "task.resume", "build.blocked"],
        publishes = ["build.task"],
        instructions = "Break work into granular, independently-testable sub-tasks.",
      } | Hat)
      ```
    "%
    | not_exported
    = {
      name
        | doc "Hat identifier"
        | String,
      description
        | doc "What this hat does"
        | String,
      subscriptions
        | doc "Topics this hat listens to (glob patterns like 'task.*')"
        | Array String
        | default
        = [],
      publishes
        | doc "Topics this hat emits"
        | Array String
        | default
        = [],
      instructions
        | doc "Custom prompt injections for this hat"
        | String
        | default
        = "",
      backend
        | doc "AI backend override (defaults to global)"
        | Backend
        | optional,
      timeout_secs
        | doc "Maximum execution time per iteration"
        | Number
        | optional,
      concurrency
        | doc "1 = sequential, >1 = concurrent wave execution"
        | Number
        | default
        = 1,
    },

  # -- Preset hats from ralph defaults --

  default_planner
    | doc "Default planner hat — reads specs, decomposes into sub-tasks"
    = {
      name = "planner",
      description = "Reads specifications and decomposes work into granular sub-tasks",
      subscriptions = ["task.start", "task.resume", "build.blocked"],
      publishes = ["build.task"],
    },

  default_builder
    | doc "Default builder hat — executes a single task"
    = {
      name = "builder",
      description = "Executes a single build task with backpressure validation",
      subscriptions = ["build.task"],
      publishes = ["build.done", "build.blocked"],
    },

  default_reviewer
    | doc "Default reviewer hat — validates implementation"
    = {
      name = "reviewer",
      description = "Validates implementation quality and test coverage",
      subscriptions = ["build.done"],
      publishes = ["review.approved", "review.rejected"],
    },

  default_finalizer
    | doc "Default finalizer hat — documents changes and recommends improvements"
    = {
      name = "finalizer",
      description = "Documents completed work and generates handoff",
      subscriptions = ["review.approved"],
      publishes = ["task.complete"],
    },
}

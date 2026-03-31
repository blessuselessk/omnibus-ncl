# Top-level ralph.yml configuration
#
# Assembles the full ralph-orchestrator config: loop settings,
# hat definitions, event routing, backpressure, skills, and hooks.
let { Hat, Backend, .. } = import "hat.ncl" in
let { EventBehavior, .. } = import "event.ncl" in
let { LoopConfig, .. } = import "loop.ncl" in
let { BackpressureConfig, .. } = import "backpressure.ncl" in
let { Skill, .. } = import "skill.ncl" in

{
  CliMode
    | doc "CLI execution mode"
    | not_exported
    = [| 'interactive, 'rpc, 'headless |],

  HookConfig
    | doc "Pre/post hook command"
    | not_exported
    = {
      cmd | String,
      on_failure
        | [| 'strict, 'warn, 'skip |]
        | default
        = 'strict,
    },

  RalphConfig
    | doc m%"
      Complete ralph.yml configuration.

      Defines the orchestration loop, agent hats, event routing,
      quality gates, skills, and lifecycle hooks.

      # Examples

      ```nickel
      ({
        event_loop = { max_iterations = 50 },
        cli = { backend = 'claude, mode = 'interactive },
        hats = { planner = default_planner, builder = default_builder },
      } | RalphConfig)
      ```
    "%
    | not_exported
    = {
      event_loop
        | doc "Core loop configuration"
        | LoopConfig
        | default
        = {},
      cli
        | doc "CLI settings"
        | {
          backend | Backend | default = 'auto,
          mode | CliMode | default = 'interactive,
          ..
        }
        | default
        = {},
      core
        | doc "Core settings"
        | {
          workspace_root | String | default = ".",
          guardrails | BackpressureConfig | optional,
          ..
        }
        | default
        = {},
      hats
        | doc "Hat definitions keyed by name"
        | { _ : Hat }
        | default
        = {},
      events
        | doc "Event behavior routing table"
        | { _ : EventBehavior }
        | default
        = {},
      skills
        | doc "Skill definitions or overrides"
        | Array Skill
        | default
        = [],
      hooks
        | doc "Lifecycle hooks"
        | {
          pre_loop_start | Array HookConfig | default = [],
          post_loop_end | Array HookConfig | default = [],
          ..
        }
        | default
        = {},
    },
}

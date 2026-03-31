# Loop — the core orchestration loop configuration
#
# Controls iteration limits, completion detection, termination,
# and workspace isolation.
{
  TerminationReason
    | doc "Why a loop ended"
    | not_exported
    = [|
      'completed,
      'max_iterations,
      'max_runtime,
      'max_cost,
      'interrupted,
      'error,
      'all_tasks_closed,
      'backpressure_limit,
      'stale
    |],

  LoopConfig
    | doc m%"
      Core event loop configuration.

      Controls when the loop stops, how completion is detected,
      and workspace isolation behavior.

      # Examples

      ```nickel
      ({
        max_iterations = 50,
        max_runtime_secs = 3600,
        completion_trigger = "LOOP_COMPLETE",
      } | LoopConfig)
      ```
    "%
    | not_exported
    = {
      max_iterations
        | doc "Maximum iterations before forced stop"
        | Number
        | default
        = 150,
      max_runtime_secs
        | doc "Maximum wall-clock time (default 8 hours)"
        | Number
        | default
        = 28800,
      max_cost
        | doc "Maximum cumulative cost in dollars (0 = unlimited)"
        | Number
        | default
        = 0,
      completion_trigger
        | doc "String that signals loop completion"
        | String
        | default
        = "LOOP_COMPLETE",
      stale_detection
        | doc "Abort if event signatures repeat consecutively"
        | Bool
        | default
        = true,
      use_worktree
        | doc "Run in isolated git worktree"
        | Bool
        | default
        = false,
      auto_merge
        | doc "Auto-merge worktree changes on completion"
        | Bool
        | default
        = true,
    },
}

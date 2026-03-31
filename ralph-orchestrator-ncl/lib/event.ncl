# Event — the fundamental messaging unit in ralph
#
# Events flow between Hats via topic-based pub/sub routing.
# Supports wave metadata for concurrent batch execution.
{
  Event
    | doc m%"
      A single event in the ralph event bus.

      Routes to Hats via topic-based subscriptions (glob patterns).
      Wave fields enable concurrent batch execution.

      # Examples

      ```nickel
      ({ topic = "build.task", payload = "Implement auth module" } | Event)
      ```
    "%
    | not_exported
    = {
      topic
        | doc "Routing topic (e.g. 'task.start', 'build.done'). Supports glob matching."
        | String,
      payload
        | doc "Event content"
        | String,
      source
        | doc "Sending Hat ID"
        | String
        | optional,
      target
        | doc "Direct recipient Hat ID (bypasses subscription routing)"
        | String
        | optional,
      wave_id
        | doc "Correlation ID for concurrent batch"
        | String
        | optional,
      wave_index
        | doc "Position within wave (0-based)"
        | Number
        | optional,
      wave_total
        | doc "Total events in this wave"
        | Number
        | optional,
    },

  EventBehavior
    | doc "Behavior associated with a topic in the event routing table"
    | not_exported
    = {
      behavior
        | doc "Named behavior to execute"
        | String,
      description
        | doc "What this behavior does"
        | String
        | optional,
    },
}

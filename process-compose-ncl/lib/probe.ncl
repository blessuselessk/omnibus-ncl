# Health check probe contracts
#
# Models Process Compose's readiness and liveness probes.
# Supports exec-based and HTTP GET-based checks.
{
  ExecProbe
    | doc "Execute a command — exit 0 = healthy"
    | not_exported
    = {
      command | String,
    },

  HttpGetProbe
    | doc "HTTP GET health check"
    | not_exported
    = {
      host
        | String
        | default
        = "localhost",
      port
        | String,
      path
        | String
        | default
        = "/health",
      scheme
        | [| 'http, 'https |]
        | default
        = 'http,
    },

  Probe
    | doc m%"
      Health check probe configuration.

      Either exec-based (run a command) or HTTP-based (GET request).
      Used for readiness_probe and liveness_probe.

      # Examples

      ```nickel
      ({ exec = { command = "pg_isready" }, period_seconds = 5 } | Probe)
      ```
    "%
    | not_exported
    = {
      exec
        | ExecProbe
        | optional,
      http_get
        | HttpGetProbe
        | optional,
      initial_delay_seconds
        | Number
        | default
        = 0,
      period_seconds
        | Number
        | default
        = 10,
      timeout_seconds
        | Number
        | default
        = 1,
      success_threshold
        | Number
        | default
        = 1,
      failure_threshold
        | Number
        | default
        = 3,
    },
}

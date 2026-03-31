# Process definition contracts
#
# Models a single process in a Process Compose configuration.
let { Probe, .. } = import "probe.ncl" in

{
  DependencyCondition
    | doc "When to consider a dependency satisfied"
    | not_exported
    = [|
      'process_started,
      'process_completed,
      'process_completed_successfully,
      'process_healthy,
      'process_log_ready,
    |],

  Dependency
    | doc "Dependency on another process"
    | not_exported
    = {
      condition
        | DependencyCondition
        | default
        = 'process_started,
      ready_log_line
        | doc "Log line to wait for (when condition = 'process_log_ready)"
        | String
        | optional,
    },

  RestartPolicy
    | doc "Process restart behavior"
    | not_exported
    = [| 'no, 'always, 'on_failure, 'exit_on_failure |],

  Availability
    | doc "Restart and backoff configuration"
    | not_exported
    = {
      restart
        | RestartPolicy
        | default
        = 'no,
      backoff_seconds
        | Number
        | default
        = 60,
    },

  Shutdown
    | doc "Shutdown signal and optional command"
    | not_exported
    = {
      signal
        | doc "Unix signal number (15=SIGTERM, 9=SIGKILL)"
        | Number
        | default
        = 15,
      command
        | doc "Optional shutdown command"
        | String
        | optional,
    },

  Process
    | doc m%"
      A single process in a Process Compose configuration.

      # Examples

      ```nickel
      ({
        command = "node server.js",
        working_dir = "/app",
        environment = ["PORT=3000"],
      } | Process)
      ```
    "%
    | not_exported
    = {
      command
        | doc "Command to execute"
        | String,
      description
        | doc "Human-readable description"
        | String
        | optional,
      working_dir
        | doc "Working directory"
        | String
        | optional,
      namespace
        | doc "Process namespace for grouping"
        | String
        | optional,
      environment
        | doc "Environment variables as KEY=VALUE strings"
        | Array String
        | default
        = [],
      depends_on
        | doc "Dependencies on other processes"
        | { _ : Dependency }
        | default
        = {},
      readiness_probe
        | Probe
        | optional,
      liveness_probe
        | Probe
        | optional,
      availability
        | Availability
        | default
        = {},
      shutdown
        | Shutdown
        | optional,
      replicas
        | doc "Number of instances"
        | Number
        | default
        = 1,
      disabled
        | doc "Skip execution"
        | Bool
        | default
        = false,
      is_daemon
        | doc "Background service"
        | Bool
        | default
        = false,
      is_foreground
        | doc "Foreground process (manual start)"
        | Bool
        | default
        = false,
      is_tty
        | doc "Allocate pseudo-TTY"
        | Bool
        | default
        = false,
      is_elevated
        | doc "Run with elevated privileges"
        | Bool
        | default
        = false,
      log_location
        | doc "Log file path"
        | String
        | optional,
    },
}

# Builder functions for process-compose-ncl
#
# Convenience constructors for Process Compose configurations.
{
  process
    | doc m%"
      Build a process from a command string.

      # Examples

      ```nickel
      process "node server.js"
      ```
    "%
    | not_exported
    = fun _command =>
      { command = _command },

  daemon
    | doc "Build a daemon process (requires explicit stop)"
    | not_exported
    = fun _command =>
      { command = _command, is_daemon = true },

  service
    | doc "Build a service with restart-on-failure"
    | not_exported
    = fun _command =>
      {
        command = _command,
        is_daemon = true,
        availability = { restart = 'on_failure },
      },

  with_health_check
    | doc "Add an exec-based readiness probe to a process"
    | not_exported
    = fun _check_cmd =>
      fun _proc =>
        _proc
        & {
          readiness_probe = {
            exec = { command = _check_cmd },
            period_seconds = 5,
            failure_threshold = 10,
          },
        },

  with_http_health
    | doc "Add an HTTP GET readiness probe"
    | not_exported
    = fun _port =>
      fun _path =>
        fun _proc =>
          _proc
          & {
            readiness_probe = {
              http_get = {
                host = "localhost",
                port = _port,
                path = _path,
                scheme = 'http,
              },
              period_seconds = 5,
            },
          },

  depends_on_started
    | doc "Add a started dependency"
    | not_exported
    = fun _dep_name =>
      fun _proc =>
        _proc
        & {
          depends_on = { "%{_dep_name}" = { condition = 'process_started } },
        },

  depends_on_healthy
    | doc "Add a healthy dependency"
    | not_exported
    = fun _dep_name =>
      fun _proc =>
        _proc
        & {
          depends_on = { "%{_dep_name}" = { condition = 'process_healthy } },
        },

  depends_on_completed
    | doc "Add a completed-successfully dependency"
    | not_exported
    = fun _dep_name =>
      fun _proc =>
        _proc
        & {
          depends_on = { "%{_dep_name}" = { condition = 'process_completed_successfully } },
        },

  compose
    | doc m%"
      Build a complete Process Compose config from a process record.

      # Examples

      ```nickel
      compose {
        web = process "python -m http.server",
        worker = process "celery worker" |> depends_on_healthy "web",
      }
      ```
    "%
    | not_exported
    = fun _processes =>
      {
        version = "0.5",
        processes = _processes,
        ordered_shutdown = true,
      },
}

# Top-level Process Compose configuration
#
# Models the complete process-compose.yaml structure.
let { Process, .. } = import "process.ncl" in

{
  LogConfig
    | doc "Log rotation settings"
    | not_exported
    = {
      max_size
        | doc "Max file size in MB"
        | Number
        | default
        = 1,
      max_age
        | doc "Retention in days"
        | Number
        | default
        = 3,
      max_backups
        | doc "Number of backup files"
        | Number
        | default
        = 3,
    },

  ShellConfig
    | doc "Shell configuration for process execution"
    | not_exported
    = {
      shell_command
        | String
        | default
        = "bash",
      shell_argument
        | String
        | default
        = "-c",
    },

  ComposeConfig
    | doc m%"
      Complete process-compose.yaml configuration.

      # Examples

      ```nickel
      ({
        version = "0.5",
        processes = {
          web = { command = "python -m http.server 8080" },
        },
      } | ComposeConfig)
      ```
    "%
    | not_exported
    = {
      version
        | doc "Schema version"
        | String
        | default
        = "0.5",
      is_strict
        | doc "Enable strict schema validation"
        | Bool
        | default
        = false,
      log_level
        | doc "Logging verbosity"
        | String
        | default
        = "info",
      log_configuration
        | LogConfig
        | optional,
      shell
        | ShellConfig
        | optional,
      environment
        | doc "Global environment variables"
        | Array String
        | default
        = [],
      processes
        | doc "Process definitions"
        | { _ : Process },
      ordered_shutdown
        | doc "Shutdown in dependency order"
        | Bool
        | default
        = false,
    },
}

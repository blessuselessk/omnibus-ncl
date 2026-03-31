# Top-level porkg configuration
#
# Assembles the full process hierarchy: a porkg instance with
# a Worker and a set of Jobs to execute.
let { WorkerConfig, .. } = import "worker.ncl" in
let { JobSpec, .. } = import "job.ncl" in
let { TagMap, .. } = import "proto.ncl" in

{
  LogLevel
    | doc "Logging verbosity"
    | not_exported
    = [| 'trace, 'debug, 'info, 'warn, 'error, 'fatal |],

  PorkgConfig
    | doc m%"
      Top-level porkg configuration.

      Defines the worker, its jobs, message protocol, and logging.

      # Examples

      ```nickel
      ({
        worker = { name = "builder" },
        jobs = [{ name = "build", command = ["make", "all"] }],
      } | PorkgConfig)
      ```
    "%
    | not_exported
    = {
      worker
        | doc "Worker process configuration"
        | WorkerConfig
        | default
        = {},
      jobs
        | doc "Jobs to execute"
        | Array JobSpec
        | default
        = [],
      tag_map
        | doc "Message protocol tag mapping"
        | TagMap
        | optional,
      log_level
        | doc "Logging verbosity"
        | LogLevel
        | default
        = 'info,
      log_timestamps
        | doc "Timestamp format for structured logs"
        | [| 'unix, 'iso8601, 'disabled |]
        | default
        = 'unix,
    },
}
